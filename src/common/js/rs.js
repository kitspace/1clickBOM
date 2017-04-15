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

    _clear_invalid(callback) {
        return this._get_clear_viewstate((viewstate, form_ids) => {
            const params1 =
            'AJAXREQUEST=_viewRoot&shoppingBasketForm=shoppingBasket' +
            'Form&=ManualEntry&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&s' +
            'hoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_' +
            '1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStoc' +
            'kNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3Aquick' +
            'StockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3Aq' +
            'uickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm' +
            '%3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasket' +
            'Form%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBa' +
            'sketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppi' +
            'ngBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&sh' +
            'oppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9' +
            '=&shoppingBasketForm%3Aj_id1085=&shoppingBasketForm%3Aj_id1091=&sh' +
            'oppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decora' +
            'te%3AQuickOrderWidgetAction_listItems=Paste%20or%20type%20your%20l' +
            'ist%20here%20and%20click%20\'Add\'.&shoppingBasketForm%3Aj_id1182%3A' +
            '0%3Aj_id1228=505-1441&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1248' +
            '=1&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction' +
            '_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionMod' +
            'alLayerOpenedState=&shoppingBasketForm%3AsendToColleagueWidgetPane' +
            'lOpenedState=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetA' +
            'ction_senderName_decorate%3AGuestUserSendToColleagueWidgetAction_s' +
            'enderName=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetActi' +
            'on_senderEmail_decorate%3AGuestUserSendToColleagueWidgetAction_sen' +
            'derEmail=name%40company.com&shoppingBasketForm%3AGuestUserSendToCo' +
            'lleagueWidgetAction_mailTo_decorate%3AGuestUserSendToColleagueWidg' +
            'etAction_mailTo=name%40company.com&shoppingBasketForm%3AGuestUserS' +
            'endToColleagueWidgetAction_subject_decorate%3AGuestUserSendToColle' +
            'agueWidgetAction_subject=Copy%20of%20order%20from%20RS%20Online&sh' +
            'oppingBasketForm%3AGuestUserSendToColleagueWidgetAction_message_de' +
            'corate%3AGuestUserSendToColleagueWidgetAction_message=&shoppingBas' +
            'ketForm%3AsendToColleagueSuccessWidgetPanelOpenedState=&javax.face' +
            `s.ViewState=${viewstate}`
            const params2 = `AJAXREQUEST=_viewRoot&${form_ids[0]}=${form_ids[0]}&` +
              `javax.faces.ViewState=${viewstate}&ajaxSingle=${form_ids[0]}%3A` +
              `${form_ids[1]}&${form_ids[0]}%3A${form_ids[1]}=${form_ids[0]}%3A` +
              `${form_ids[1]}&`
            const params3 = 'AJAXREQUEST=_viewRoot&a4jCloseForm=a4jCloseForm&auto' +
              `Scroll=&javax.faces.ViewState=${viewstate}&a4jCloseForm%3A` +
              `${form_ids[2]}=a4jCloseForm%3A${form_ids[2]}&`
            const p = http.promiseGet(`http${this.site}${this.cart}`)
            return p.then(doc => {
                const error_lines = doc.querySelectorAll('.dataRow.errorRow')
                const a = []
                for (let i = 0; i < error_lines.length; i++) {
                    a.push(null)
                }
                //for each line we basically click the 'remove' link which also
                //asks for confirmation
                const chain = a.reduce(prev => {
                    return prev.then(_doc => {
                        if (_doc == null) {
                            return http.promiseGet(`http${this.site}${this.cart}`)
                        } else {
                            return Promise.resolve(_doc)
                        }
                    }).then(_doc => {
                        const error_line = __guard__(__guard__(_doc, x1 => x1.querySelector('.dataRow.errorRow')), x => x.querySelector('.quantityTd'))
                        const id = __guard__(__guard__(__guard__(error_line, x4 => x4.children[3]), x3 => x3.children[0]), x2 => x2.id)
                        const param_id = params1 + '&' + encodeURIComponent(id)
                        return http.promisePost(`http${this.site}${this.cart}`, param_id)
                    }).then(() => {
                        return http.promisePost(`http${this.site}${this.cart}`, params2)
                    }).then(() => {
                        return http.promisePost(`http${this.site}${this.cart}`, params3)
                    })
                }
                , Promise.resolve(doc))
                chain.then(() => callback({success:true}))
                return chain.catch(() => callback({success:false}))
            }).catch(() => callback({success:false}))
        }
        )
    },


    addLines(lines, callback) {

        if (lines.length === 0) {
            callback({success: true, fails: []})
            return
        }

        const add = (lines, callback) => {
            return this._clear_invalid(() => {
                return this._get_adding_viewstate((viewstate, form_id) => {
                    return this._add_lines(lines, viewstate, form_id, callback)
                }
                )
            }
            )
        }

        const end = result => {
            callback(result, this, lines)
            this.refreshCartTabs()
            return this.refreshSiteTabs()
        }

        return add(lines, function(result) {
            if (!result.success) {
                //do a second pass with corrected quantities
                return add(result.fails, _result => end(_result)
                )
            } else {
                return end(result)
            }
        }
        )
    },

    _get_and_correct_invalid_lines(callback) {
        const url = `http${this.site}${this.cart}`
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
        const url = `http${this.site}${this.cart}`
        let params = `AJAXREQUEST=shoppingBasketForm%3A${form_id}&shoppingBasketFo` +
        'rm=shoppingBasketForm&=QuickAdd&=DELIVERY&shoppingBasketForm%3AquickSt' +
        'ockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickSt' +
        'ockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickSt' +
        'ockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickSt' +
        'ockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickSt' +
        'ockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickSt' +
        'ockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickSt' +
        'ockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickSt' +
        'ockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickSt' +
        'ockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickSt' +
        'ockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3AQuickOr' +
        'derWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_li' +
        'stItems='

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            params += encodeURIComponent(`${line.part},${line.quantity},,` +
            `${line.reference}\n`)
        }

        params += '&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetA' +
        'ction_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionMo' +
        `dalLayerOpenedState=&javax.faces.ViewState=${viewstate}&shoppingBasket` +
        'Form%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderW' +
        'idgetAction_quickOrderTextBoxbtn=shoppingBasketForm%3AQuickOrderWidget' +
        'Action_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderT' +
        'extBoxbtn&'

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
        const url = `http${this.site}${this.cart}`
        return http.get(url, {}, responseText => {
            const doc = browser.parseDOM(responseText)
            const viewstate_element  = doc.getElementById('javax.faces.ViewState')
            if (viewstate_element != null) {
                var viewstate = viewstate_element.value
            } else {
                return callback('', '')
            }
            const btn_doc = doc.getElementById('addToOrderDiv')
            //the form_id element is different values depending on signed in or
            //signed out could just hardcode them but maybe this will be more
            //future-proof?  we use a regex here as DOM select methods crash on
            //this element!
            const form_id  = /AJAX.Submit\('shoppingBasketForm\:(j_id\d+)/
                .exec(btn_doc.innerHTML.toString())[1]
            return callback(viewstate, form_id)
        }
        , () => callback('', '')
        )
    },


    _get_clear_viewstate(callback){
        const url = `http${this.site}${this.cart}`
        return http.get(url, {}, responseText => {
            const doc = browser.parseDOM(responseText)
            const viewstate_elem = doc.getElementById('javax.faces.ViewState')
            if (viewstate_elem != null) {
                var viewstate = doc.getElementById('javax.faces.ViewState').value
            } else {
                return callback('', [])
            }

            const form_elem = doc.getElementById('a4jCloseForm')
            if (form_elem != null) {
                const form = form_elem.nextElementSibling.nextElementSibling
                //the form_id elements are different values depending on signed
                //in or signed out could just hardcode them but maybe this will
                //be more future-proof?
                const form_id2  = /"cssButton secondary red enabledBtn" href="#" id="j_id\d+\:(j_id\d+)"/.exec(form.innerHTML.toString())[1]
                const form_id3  = doc.getElementById('a4jCloseForm')
                    .firstChild.id.split(':')[1]
                return callback(viewstate, [form.id, form_id2, form_id3])
            } else {
                return callback('', [])
            }
        }
        , () => callback('', [])
        )
    }
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
        }
        )
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
