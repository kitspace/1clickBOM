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

const {RetailerInterface} = require('./retailer_interface')
const http = require('./http')
const {browser} = require('./browser')
const Promise = require('./bluebird')
Promise.config({cancellation: true})

class Mouser extends RetailerInterface {
    constructor(country_code, settings) {
        super('Mouser', country_code, 'data/mouser.json', settings)
        this.protocol = 'https'
        //posting our sub-domain as the sites are all linked and switching
        //countries would not register properly otherwise
        const split = this.site.split('.')
        let s = split[0].slice(3)
        http.post(
            `https://www.mouser.com/api/Preferences/SetSubdomain?subdomainName=${s}`,
            '',
            {notify: false},
            function() {},
            function() {}
        )
    }
    addLines(lines, callback) {
        if (lines.length === 0) {
            callback({success: true, fails: []})
            return
        }
        let count = 0
        const big_result = {success: true, fails: []}
        return this._get_token(token => {
            return this._clear_errors(token, () => {
                return this._get_adding_token(token => {
                    const result = []
                    for (let i = 0; i < lines.length; i += 99) {
                        const _99_lines = lines.slice(i, i + 99)
                        count += 1
                        result.push(
                            this._add_lines(_99_lines, token, result => {
                                if (big_result.success) {
                                    big_result.success = result.success
                                }
                                big_result.fails = big_result.fails.concat(
                                    result.fails
                                )
                                count -= 1
                                if (count <= 0) {
                                    callback(big_result, this, lines)
                                    return this.refreshCartTabs()
                                }
                            })
                        )
                    }
                    return result
                })
            })
        })
    }
    _add_lines(lines, token, callback) {
        let params = '__RequestVerificationToken=' + token
        params += '&NumRows=94'
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            params +=
                '&' +
                encodeURIComponent(`ListItems[${i}].BackgroundColor`) +
                '=' +
                '&' +
                encodeURIComponent(`ListItems[${i}].PartNumber`) +
                '=' +
                line.part +
                '&' +
                encodeURIComponent(`ListItems[${i}].CustomerPartNumber`) +
                '=' +
                line.reference +
                '&' +
                encodeURIComponent(`ListItems[${i}].Quantity`) +
                '=' +
                line.quantity
        }
        params += '&ProjectSelected=ORDER&EzBuyController.AddtoOrder='
        const url = `${this.protocol}${this.site}${this.addline}`
        const result = {success: true, fails: []}
        return http.post(
            url,
            params,
            {},
            responseText => {
                const errors = this._get_errors(responseText)
                for (let j = 0; j < errors.length; j++) {
                    const part = errors[j].getAttribute('data-partnumber')
                    if (part != null) {
                        for (let k = 0; k < lines.length; k++) {
                            const line = lines[k]
                            if (line.part === part.replace(/-/g, '')) {
                                result.fails.push(line)
                            }
                        }
                        result.success = false
                    }
                }
                if (callback != null) {
                    return callback(result)
                }
            },
            function() {
                if (callback != null) {
                    return callback({success: false, fails: lines})
                }
            }
        )
    }

    _get_errors(responseText) {
        const doc = browser.parseDOM(responseText)
        return doc.querySelectorAll('.grid-row.row-error')
    }

    _clear_errors(token, callback) {
        http.get(
            `${this.protocol}${this.site}${this.cart}`,
            {},
            responseText => {
                const errors = this._get_errors(responseText)
                const item_ids = []
                for (let i = 0; i < errors.length; ++i) {
                    item_ids.push(errors[i].getAttribute('data-itemid'))
                }
                const promiseArray = item_ids.map(id => {
                    return http
                        .promisePost(
                            `${this.protocol}${this.site}${this
                                .cart}/cart/DeleteCartItem?cartItemId=${id}&page=null&grid-column=SortColumn&grid-dir=0`,
                            `__RequestVerificationToken=${token}`
                        )
                        .catch(e => console.error(e))
                })
                return Promise.all(promiseArray).then(() => {
                    if (callback != null) {
                        return callback()
                    }
                })
            }
        )
    }

    clearCart(callback) {
        return this._get_token(token => {
            return this._clear_cart(token, callback)
        })
    }
    _clear_cart(token, callback) {
        const url = this.protocol + this.site + this.cart + '/cart/DeleteCart'
        const params = `__RequestVerificationToken=${token}`
        return http.post(
            url,
            params,
            {},
            event => {
                if (callback != null) {
                    callback({success: true}, this)
                }
                return this.refreshCartTabs()
            },
            () => {
                if (callback != null) {
                    return callback({success: false}, this)
                }
            }
        )
    }
    _get_adding_token(callback) {
        //we get the quick-add form, extend it to 99 lines (the max) and get
        //the __RequestVerificationToken from the response
        const url = `${this.protocol}${this.site}${this.addline}`
        return http.get(url, {}, responseText => {
            let doc = browser.parseDOM(responseText)
            let params = '__RequestVerificationToken='
            params += doc.querySelector(
                'input[name=__RequestVerificationToken]'
            ).value
            params += '&NumRows=94'
            return http.post(url, params, {}, responseText => {
                doc = browser.parseDOM(responseText)
                const token = doc.querySelector(
                    'input[name=__RequestVerificationToken]'
                ).value
                if (callback != null) {
                    return callback(token)
                }
            })
        })
    }
    _get_token(callback) {
        url = `${this.protocol}${this.site}${this.cart}`
        http.get(url, {}, responseText => {
            const doc = browser.parseDOM(responseText)
            const token = doc.querySelector('form#cart-form > input').value
            callback(token)
        })
    }
}

exports.Mouser = Mouser

function __guard__(value, transform) {
    return typeof value !== 'undefined' && value !== null
        ? transform(value)
        : undefined
}
