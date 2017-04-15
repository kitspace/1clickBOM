// The contents of this file are subject to the Common Public Attribution
// License Version 1.0 (the “License”); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
// License Version 1.1 but Sections 14 and 15 have been added to cover use of
// software over a computer network and provide for limited attribution for the
// Original Developer. In addition, Exhibit A has been modified to be consistent
// with Exhibit B.
//
// Software distributed under the License is distributed on an
// "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
// the License for the specific language governing rights and limitations under
// the License.
//
// The Original Code is 1clickBOM.
//
// The Original Developer is the Initial Developer. The Original Developer of
// the Original Code is Kaspar Emanuel.
const Promise = require('./bluebird')
Promise.config({cancellation:true})

const { RetailerInterface } = require('./retailer_interface')
const http = require('./http')
const { browser } = require('./browser')

const { rsOnline } = require('./rs_online')


const rsDelivers = {
    clearCart(callback) {
        const url = `http${this.site}/CheckoutServices/DeleteAllProductsInCart`
        return http.post(url, '', {json:true}, responseText => {
            if (callback != null) {
                callback({success: true}, this)
            }
            this.refreshSiteTabs()
            return this.refreshCartTabs()
        }
        , () => {
            return callback({success: false}, this)
        }
        )
    },


    _clear_invalid(callback) {
        return this._get_invalid_lines(parts => {
            return this._delete_invalid(parts, callback)
        })
    },


    _delete_invalid(parts, callback) {
        const url = `http${this.site}/CheckoutServices/UpdateDeleteProductsInCart`
        const promises = parts.map(part => {
            return http.promisePost(url, `stockCode=${part}&quantity=0`)
        })
        Promise.all(promises).then(callback)
    },


    _get_invalid_lines(callback) {
        const url = `http${this.site}/CheckoutServices/GetCartLinesHtml`
        return http.get(url, {}, function(responseText) {
            const html = JSON.parse(responseText).cartLinesHtml
            const doc = browser.parseDOM(html)
            const errors = doc.getElementsByClassName('errorOrderLine')
            const ids = []
            const parts = []
            for (let i = 0; i < errors.length; i++) {
                const error = errors[i]
                parts.push(error.parentElement.nextElementSibling
                    .querySelector('.descTd').firstElementChild
                    .nextElementSibling.firstElementChild.nextElementSibling
                    .innerText.trim().replace('-',''))
            }
            return callback(parts)
        }
        , () => callback([],[])
        )
    },


    addLines(lines, callback) {
        if (lines.length === 0) {
            callback({success: true, fails: []})
            return
        }
        return this._add_lines(lines, 0, {success:true, fails:[]}, result => {
            callback(result, this, lines)
            this.refreshCartTabs()
            return this.refreshSiteTabs()
        }
        )
    },


    //adds lines recursively in batches of 100 -- requests would timeout
    //otherwise
    _add_lines(lines_incoming, i, result, callback) {
        if (i < lines_incoming.length) {
            const lines = lines_incoming.slice(i, i + 99 + 1)
            return this._clear_invalid(() => {
                const url = `http${this.site}/CheckoutServices/BulkAddProducts`
                let params = 'productString='
                lines.forEach(line => {
                    params += `${line.part},${line.quantity},"${line.reference}"\n`
                })
                return http.post(url, params, responseText => {
                    return callback({success:true})
                    const doc = browser.parseDOM(JSON.parse(responseText).html)
                    const success = doc.querySelector('#hidErrorAtLineLevel')
                        .value === '0'
                    if (!success) {
                        return this._get_invalid_lines(parts => {
                            const invalid = []
                            for (let k = 0; k < lines.length; k++) {
                                const line = lines[k]
                                if (__in__(line.part, parts)) {
                                    invalid.push(line)
                                }
                            }
                            return this._add_lines(lines_incoming
                            , i + 100
                            , {
                                success:false,
                                fails:result.fails.concat(invalid)
                            }
                            , callback)
                        }
                        )
                    } else {
                        return this._add_lines(lines_incoming, i + 100, result, callback)
                    }
                }
                , () => {
                    return this._add_lines(lines_incoming
                    , i + 100
                    , {success:false, fails:result.fails.concat(lines)}
                    , callback)
                }
                )
            }
            )
        } else {
            return callback(result)
        }
    }
}


class RS extends RetailerInterface {
    constructor(country_code, settings, callback) {
        super('RS', country_code, 'data/rs.json', settings)
        if (/web\/ca/.test(this.cart)) {
            for (var name in rsOnline) {
                var method = rsOnline[name]
                this[name] = method
            }
        } else {
            for (var name in rsDelivers) {
                var method = rsDelivers[name]
                this[name] = method
            }
        }
        __guardFunc__(callback, f => f())
    }
}


exports.RS = RS

function __guardFunc__(func, transform) {
    return typeof func === 'function' ? transform(func) : undefined
}
function __guard__(value, transform) {
    return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined
}
function __in__(needle, haystack) {
    return haystack.indexOf(needle) >= 0
}
