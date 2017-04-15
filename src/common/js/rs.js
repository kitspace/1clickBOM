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

const rsOnline = {
    clearCart(callback) {
        return this._clear_cart(result => {
            __guardFunc__(callback, f => f(result, this))
            this.refreshCartTabs()
            return this.refreshSiteTabs()
        })
    },


    _clear_cart(callback) {
        const url = `https${this.site}${this.cart}`
        return http.post(url, 'isRemoveAll=true', {}, () => callback({success:true}), () => callback({success:false}))
    },

    _clear_invalid() {
        const url = `https${this.site}${this.cart}`
        return this._get_invalid().then(ids => {
            return Promise.all(ids.map(id =>  {
                const params = `isRemoveItem=true&basketLineId=${id}`
                return http.promisePost(url, params)
            }))
        })
    },


    addLines(lines, callback) {

        if (lines.length === 0) {
            callback({success: true, fails: []})
            return
        }

        const add = (lines, callback) => {
                return this._get_adding_viewstate((viewstate, form_id) => {
                    return this._add_lines(lines, viewstate, form_id, callback)
                })
        }

        const end = result => {
            callback(result, this, lines)
            this.refreshCartTabs()
            return this.refreshSiteTabs()
        }
        return this._clear_invalid().then(() => {
            add(lines, result => {
                if (!result.success) {
                    //do a second pass with corrected quantities
                    add(lines, end)
                } else {
                    return end(result)
                }
            })
        })
    },

    _get_invalid() {
        const url = `https${this.site}${this.cart}`
        return http.promiseGet(url).then(doc => {
            const errors = doc.querySelectorAll('.dataRow.errorRow')
            const ids = []
            for (let i = 0; i < errors.length; i++) {
                const id = /showConfirmDelete\('(.*?)'\)/.exec(errors[i].innerHTML.toString())[1]
                ids.push(id)
            }
            return ids
        })
    },

    _get_and_correct_invalid_lines(callback) {
        const url = `https${this.site}${this.cart}`
        return http.get(url, {}, responseText => {
            const doc = browser.parseDOM(responseText)
            const lines = []
            const iterable = doc.querySelectorAll('.dataRow.errorRow')
            for (let i = 0; i < iterable.length; i++) {
                const elem = iterable[i]
                const line = {}
                //detect minimimum and multiple-of quantities from description
                //and add a quantity according to those. we read the quantity
                //from the cart as this could be a line that was already in
                //the cart when we added. description is of the form:
                //blabla 10 (minimum) blablabla 10 (multiple of) blabla
                // or
                //blabla 10 (multiple of) blabla
                const descr = __guard__(__guard__(elem.previousElementSibling, x1 => x1.firstElementChild), x => x.innerHTML)
                const quantity = parseInt(__guard__(__guard__(elem.querySelector('.quantityTd'), x3 => x3.firstElementChild), x2 => x2.value))
                if (!isNaN(quantity)) {
                    const re_min_mul = /.*?(\d+)\D+?(\d+).*?/
                    let min = __guard__(re_min_mul.exec(descr), x4 => x4[1])
                    if (min == null) {
                        const re_mul = /.*?(\d+).*?/
                        const mul = parseInt(__guard__(re_mul.exec(descr), x5 => x5[1]))
                        if (!isNaN(mul)) {
                            line.quantity = mul - (quantity % mul)
                        }
                    } else {
                        min = parseInt(min)
                        if (!isNaN(min)) {
                            line.quantity = min - quantity
                        }
                    }
                }
                //detect part number
                const error_child = __guard__(elem.children, x6 => x6[1])
                const error_input = __guard__(error_child, x7 => x7.querySelector('input'))
                if (error_input != null) {
                    line.part = __guard__(error_input.value, x8 => x8.replace(/-/g,''))
                }
                lines.push(line)
            }
            return callback(lines)
        }
        , () => callback([])
        )
    },


    _add_lines(lines_incoming, viewstate, form_id, callback) {
        const result = {success:true, fails:[]}
        if (lines_incoming.length > 500) {
            result.warnings = ['RS cart cannot hold more than 500 lines.']
            result.fails = lines.slice(500)
            var lines = lines_incoming.slice(0, 500)
        } else {
            var lines = lines_incoming
        }
        const url = `https${this.site}${this.cart}`
        let params = 'shoppingBasketForm=shoppingBasketForm&shoppingBasketForm%3AquickStockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3Aj_idt3056=&shoppingBasketForm%3Aj_idt3062=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_listItems='


        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            params += encodeURIComponent(`${line.part},${line.quantity},,` +
            `${line.reference}\n`)
        }

        params += `&deliveryOrCollection=DELIVERY&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&javax.faces.ViewState=${viewstate}&javax.faces.source=shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn&javax.faces.partial.event=click&javax.faces.partial.execute=shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn%20%40component&javax.faces.partial.render=%40component&org.richfaces.ajax.component=shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn=shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn&rfExt=null&AJAX%3AEVENTS_COUNT=1&javax.faces.partial.ajax=true`


        return http.post(url, params, {}, () => {
            return this._get_and_correct_invalid_lines(invalid_lines => {
                const success = invalid_lines.length === 0
                const invalid = []
                if (!success) {
                    for (let j = 0; j < lines.length; j++) {
                        const line = lines[j]
                        for (let k = 0; k < invalid_lines.length; k++) {
                            const inv_line = invalid_lines[k]
                            if (line.part === inv_line.part) {
                                if (inv_line.quantity != null) {
                                    line.quantity = inv_line.quantity
                                }
                                invalid.push(line)
                            }
                        }
                    }
                }
                return __guardFunc__(callback, f => f({
                    success:result.success && success,
                    fails:result.fails.concat(invalid),
                    warnings:result.warnings
                }
                , this, lines_incoming))
            })
        }
        , () => {
            return __guardFunc__(callback, f => f({
                success:false,
                fails:result.fails.concat(lines)
            }
            , this, lines_incoming))
        }
        )
    },


    _get_adding_viewstate(callback){
        const url = `https${this.site}${this.cart}`
        return http.get(url, {}, responseText => {
            const doc = browser.parseDOM(responseText)
            const viewstate_element  = doc.getElementById('javax.faces.ViewState')
            if (viewstate_element != null) {
                var viewstate = viewstate_element.value
            } else {
                return callback('', '')
            }
            const content_doc = doc.getElementById('mainContent')
            //the form_id element is different values depending on signed in or
            //signed out could just hardcode them but maybe this will be more
            //future-proof?  we use a regex here as DOM select methods crash on
            //this element!
            const form_id  = /shoppingBasketForm\:(j_idt\d+)/.exec(content_doc.innerHTML.toString())[1]
            return callback(viewstate, form_id)
        }
        , () => callback('', '')
        )
    },
}


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
