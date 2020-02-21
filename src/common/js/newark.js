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
const {browser} = require('./browser')
const http = require('./http')

class Newark extends RetailerInterface {
    constructor(country_code, settings, callback) {
        super('Newark', country_code, 'data/newark.json', settings)
        this._set_store_id(() => {
            return callback(this)
        })
    }

    clearCart(callback) {
        return this._get_item_ids(ids => {
            return this._clear_cart(ids, obj => {
                this.refreshCartTabs()
                this.refreshSiteTabs()
                if (callback != null) {
                    return callback(obj)
                }
            })
        })
    }

    _set_store_id(callback) {
        const url = `https${this.site}${this.cart}`
        return http.get(
            url,
            {},
            response => {
                const doc = browser.parseDOM(response)
                const id_elem = doc.getElementById('storeId')
                if (id_elem != null) {
                    this.store_id = id_elem.value
                    return callback()
                }
            },
            () => callback()
        )
    }

    _clear_cart(ids, callback) {
        const url = `https${this.site}/webapp/wcs/stores/servlet/ProcessBasket`
        let params = `langId=&orderId=&catalogId=&BASE_URL=BasketPage&errorViewName=BasketErrorAjaxResponse&storeId=${this.store_id}&URL=BasketDataAjaxResponse&calcRequired=true&orderItemDeleteAll=&isBasketUpdated=true`
        ids.forEach(id => {
            params += `&orderItemDelete=${id}`
        })
        return http.post(
            url,
            params,
            {},
            event => {
                return callback({success: true}, this)
            },
            () => {
                //we actually successfully clear the cart on 404s
                return callback({success: true}, this)
            }
        )
    }

    _get_item_ids(callback) {
        const url = `https${this.site}${this.cart}`
        return http.get(url, {}, responseText => {
            const doc = browser.parseDOM(responseText)
            const order_details = doc.querySelector('#order_details')
            if (order_details != null) {
                const tbody = order_details.querySelector('tbody')
                var inputs = tbody.querySelectorAll('input')
            } else {
                var inputs = []
            }
            const ids = []
            for (let i = 0; i < inputs.length; i++) {
                const input = inputs[i]
                if (input.type === 'hidden' && /orderItem_/.test(input.id)) {
                    ids.push(input.value)
                }
            }
            return callback(ids)
        })
    }

    addLines(lines, callback) {
        if (lines.length === 0) {
            callback({success: true, fails: []})
            return
        }
        return this._add_lines(lines, result => {
            this.refreshCartTabs()
            this.refreshSiteTabs()
            return callback(result, this, lines)
        })
    }

    _add_lines(lines, callback) {
        const url = `https${this.site}/AjaxPasteOrderChangeServiceItemAdd`
        return http.get(
            url,
            {notify: false},
            () => {
                return this._add_lines_ajax(lines, callback)
            },
            () => {
                return this._add_lines_non_ajax(lines, callback)
            }
        )
    }

    _add_lines_non_ajax(lines, callback) {
        if (lines.length === 0) {
            if (callback != null) {
                callback({success: true, fails: []})
            }
            return
        }
        const url = `https${this.site}/webapp/wcs/stores/servlet/PasteOrderChangeServiceItemAdd`
        let params = `storeId=${this.store_id}&catalogId=&langId=-1&omItemAdd=quickPaste&URL=AjaxOrderItemDisplayView%3FstoreId%3D10194%26catalogId%3D15003%26langId%3D-1%26quickPaste%3D*&errorViewName=QuickOrderView&calculationUsage=-1%2C-2%2C-3%2C-4%2C-5%2C-6%2C-7&isQuickPaste=true&quickPaste=`
        //&addToBasket=Add+to+Cart'
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            params += encodeURIComponent(line.part) + ','
            params += encodeURIComponent(line.quantity) + ','
            params +=
                encodeURIComponent(line.reference.replace(/,/g, ' ')) + '\n'
        }
        return http.post(
            url,
            params,
            {},
            responseText => {
                const doc = browser.parseDOM(responseText)
                const form_errors = doc.querySelector('#formErrors')
                let success = true
                if (form_errors != null) {
                    success = form_errors.className !== ''
                }
                if (!success) {
                    //we find out which parts are the problem, call addLines again
                    //on the rest and concatenate the fails to the new result
                    //returning everything together to our callback
                    const fail_names = []
                    const fails = []
                    const retry_lines = []
                    for (let j = 0; j < lines.length; j++) {
                        var line = lines[j]
                        const regex = new RegExp(line.part, 'g')
                        const result = regex.exec(form_errors.innerHTML)
                        if (result !== null) {
                            fail_names.push(result[0])
                        }
                    }
                    for (let k = 0; k < lines.length; k++) {
                        var line = lines[k]
                        if (__in__(line.part, fail_names)) {
                            fails.push(line)
                        } else {
                            retry_lines.push(line)
                        }
                    }
                    return this._add_lines_non_ajax(retry_lines, function(
                        result
                    ) {
                        if (callback != null) {
                            result.fails = result.fails.concat(fails)
                            result.success = false
                            return callback(result)
                        }
                    })
                } else {
                    //success
                    if (callback != null) {
                        return callback({success: true, fails: []})
                    }
                }
            },
            () => {
                if (callback != null) {
                    return callback({success: false, fails: lines})
                }
            }
        )
    }

    _add_lines_ajax(lines, callback) {
        const result = {success: true, fails: [], warnings: []}
        if (lines.length === 0) {
            if (callback != null) {
                callback({success: true, fails: []})
            }
            return
        }
        const url = `https${this.site}/AjaxPasteOrderChangeServiceItemAdd`

        let params = `storeId=${this.store_id}&catalogId=&langId=-1&omItemAdd=quickPaste&URL=AjaxOrderItemDisplayView%3FstoreId%3D10194%26catalogId%3D15003%26langId%3D-1%26quickPaste%3D*&errorViewName=QuickOrderView&calculationUsage=-1%2C-2%2C-3%2C-4%2C-5%2C-6%2C-7&isQuickPaste=true&quickPaste=`
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            params += encodeURIComponent(line.part) + ','
            params += encodeURIComponent(line.quantity) + ','
            const reference = line.reference.replace(/,/g, ' ')
            if (reference.length > 30) {
                result.warnings.push(`Truncated line-note when adding
                    ${this.name} line to cart: ${line.reference}`)
            }
            params += encodeURIComponent(reference.substr(0, 30)) + '\n'
        }
        return http.post(
            url,
            params,
            {},
            responseText => {
                const stxt = responseText.split('\n')
                const stxt2 = stxt.slice(3, stxt.length - 4 + 1)
                let stxt3 = ''
                for (let j = 0; j < stxt2.length; j++) {
                    const s = stxt2[j]
                    stxt3 += s
                }
                const json = JSON.parse(stxt3)
                if (
                    json.hasPartNumberErrors != null ||
                    json.hasCommentErrors != null
                ) {
                    //we find out which parts are the problem, call addLines again
                    //on the rest and concatenate the fails to the new result
                    //returning everything together to our callback
                    const fail_names = []
                    const fails = []
                    const retry_lines = []
                    for (const k in json) {
                        //the rest of the json lines are the part numbers
                        const v = json[k]
                        if (
                            k !== 'hasPartNumberErrors' &&
                            k !== 'hasCommentErrors'
                        ) {
                            fail_names.push(v[0])
                        }
                    }
                    for (let i1 = 0; i1 < lines.length; i1++) {
                        const line = lines[i1]
                        if (__in__(line.part, fail_names)) {
                            fails.push(line)
                        } else {
                            retry_lines.push(line)
                        }
                    }
                    return this._add_lines_ajax(retry_lines, function(result) {
                        if (callback != null) {
                            result.fails = result.fails.concat(fails)
                            result.success = false
                            callback(result)
                        }
                    })
                } else {
                    if (json.pfOrderErrorEnc) {
                        const url = `https${this.site}${this.cart}?storeId=${this.store_id}&catalogId=15001&langId=44&pfOrderErrorEnc=${json.pfOrderErrorEnc}`
                        http.promiseGet(url)
                            .then(doc => {
                                const form_errors = doc.querySelector(
                                    '#formErrors'
                                )
                                if (form_errors == null) {
                                    // sometimes we don't get the right
                                    // response the first time
                                    return http.promiseGet(url)
                                }
                                return doc
                            })
                            .then(doc => {
                                const form_errors = doc.querySelector(
                                    '#formErrors'
                                )
                                const success = form_errors == null
                                const fails = []
                                if (!success) {
                                    for (let j = 0; j < lines.length; j++) {
                                        var line = lines[j]
                                        const regex = new RegExp(line.part, 'g')
                                        const result = regex.exec(
                                            form_errors.innerHTML
                                        )
                                        if (result != null) {
                                            // TODO: make this work for all languages
                                            // ignore 'has a pack size of ...' errors
                                            // XXX i don't think we actually ever receive these here
                                            const p = line.part
                                            const regex_pack = new RegExp(
                                                //english
                                                `(${p} has a pack)` +
                                                    //spanish
                                                    `|(${p} tiene \\d+ artículos)` +
                                                    //german
                                                    `|(${p} hat eine Verpackungsgröße von)` +
                                                    //dutch
                                                    `|(${p}  heeft een pakketgrootte van)` +
                                                    //french
                                                    `|(${p} est disponible par groupe de)` +
                                                    //bulgarian
                                                    `|(${p} има количество на опаковката от)` +
                                                    //czech
                                                    `|(${p} obsahuje v balení)` +
                                                    //danish
                                                    `|(${p} har en pakkestørrelse på)` +
                                                    //estonian
                                                    `|(${p} pakend sisaldab)` +
                                                    //finish
                                                    `|(${p} pakkauskoko on)`
                                            )
                                            const result_pack = regex_pack.exec(
                                                form_errors.innerHTML
                                            )
                                            // ignore 'needs to be order in multiples ...' errors
                                            const regex_multiples = new RegExp(
                                                //english
                                                `(${p} can only be ordered to a minimum)` +
                                                    `|(${p} needs to be ordered in multiples of)` +
                                                    //spanish
                                                    `|(${p} solo se puede pedir en cantidades mínimas de)` +
                                                    `|(${p} tiene que pedirse en múltiplos de)` +
                                                    //german
                                                    `|(${p} muss die Mindestmenge von)` +
                                                    `|(${p} muss in Staffelungen von)` +
                                                    //dutch
                                                    `|(${p} moet worden besteld in veelvouden van)` +
                                                    `|(${p} alleen worden besteld met een minimaal aantal van)` +
                                                    //french
                                                    `|(${p} doit être commandé par multiple de)` +
                                                    `|(${p} peut être commandé uniquement avec une quantité minimale)` +
                                                    //bulgarian
                                                    `|(${p} трябва да се поръчва в множество от)` +
                                                    `|(${p} може да се поръчва само при минимално количество от)` +
                                                    //czech
                                                    `|(${p} je nutné objednat)` +
                                                    `|(${p} lze objednat pouze)` +
                                                    //danish
                                                    `|(Minimumsantallet ved bestilling af produkt ${p})` +
                                                    `|(${p} skal bestilles i antal deleligt med)` +
                                                    //estonian
                                                    `|(${p} tuleb tellida)` +
                                                    `|(${p} minimaalne tellitav kogus on)` +
                                                    //finish
                                                    `|(${p} vähimmäistilausmäärä on)` +
                                                    `|(${p} on tilattava)`
                                            )
                                            const result_multiples = regex_multiples.exec(
                                                form_errors.innerHTML
                                            )
                                            if (
                                                result_pack == null &&
                                                result_multiples == null
                                            ) {
                                                fails.push(line)
                                            }
                                        }
                                    }
                                }
                                result.success = success || fails.length == 0
                                result.fails = fails
                                return callback(result)
                            })
                    }
                    //success
                    return callback(result)
                }
            },
            () => {
                if (callback != null) {
                    return callback({
                        success: false,
                        fails: lines,
                        warnings: result.warnings
                    })
                }
            }
        )
    }
}

exports.Newark = Newark

function __in__(needle, haystack) {
    return haystack.indexOf(needle) >= 0
}
