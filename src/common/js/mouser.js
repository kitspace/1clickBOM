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
const Promise = require('bluebird')
Promise.config({cancellation: true})

class Mouser extends RetailerInterface {
    constructor(country_code, settings) {
        super('Mouser', country_code, 'data/mouser.json', settings)
        this.protocol = 'https'
        //setting our sub-domain as the sites are all linked and switching
        //countries would not register properly otherwise
        let s = country_code.toLowerCase()
        if (s === 'uk') {
            s = 'gb'
        }
        http.get(
            'https://www.mouser.com/cs/localsitesredirect?subdomain=' + s,
            {notify: false}
        )
    }
    addLines(lines, callback) {
        if (lines.length === 0) {
            callback({success: true, fails: [], warnings})
            return
        }
        const [merged, warnings] = this.mergeSameSkus(lines)
        let count = 0
        const big_result = {success: true, fails: [], warnings}
        return this._get_token(token => {
            return this._clear_errors(token, async () => {
                const token = await this._get_adding_token()
                if (token == null) {
                    return callback({success: false, fails: lines})
                }
                const result = []
                for (let i = 0; i < merged.length; i += 99) {
                    const _99_lines = merged.slice(i, i + 99)
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
    }
    async _get_cart_guid() {
        await fetch(`${this.protocol}${this.site}/cart`, {
            credentials: 'include',
        })
        const domain = this.site.replace(/^:\/\/.*?\.mouser/, '.mouser')
        const cookies = await browser.getCookies({
            domain,
            name: 'CARTCOOKIEUUID',
        })
        if (cookies[0]) {
            return cookies[0].value
        }
    }
    async _add_lines(lines, token, callback) {
        const cartGuid = await this._get_cart_guid()
        if (cartGuid == null) {
            return callback({success: false, fails: lines})
        }
        const url = `${this.protocol}${this.site}/api/Cart/AddCartItems?cartGuid=${cartGuid}&source=SearchProductDetail`
        // this is not great, we used to remove dashes in our mouser part numbers
        // but mouser API doesn't accept those any more now, if the part doesn't
        // have dashes. below we do a search and get the mouser part number with dashes
        // from the page
        const correctedLines = await Promise.all(
            lines.map(async line => {
                if (/-/.test(line.part)) {
                    return line
                }
                const text = await fetch(
                    `${this.protocol}${this.site}/c/?q=${line.part}`
                ).then(r => r.text())
                try {
                    const doc = new DOMParser().parseFromString(
                        text,
                        'text/html'
                    )
                    let mouserPart = doc.getElementById(
                        'spnMouserPartNumFormattedForProdInfo'
                    )
                    if (mouserPart == null) {
                        // it's a search result page, we take the first result
                        mouserPart = doc.getElementsByClassName(
                            'mpart-number-lbl'
                        )[0]
                    }
                    mouserPart = mouserPart.innerHTML.trim()
                    if (mouserPart.replace(/-/g, '') !== line.part) {
                        return {fail: line}
                    }
                    return Object.assign({}, line, {part: mouserPart})
                } catch (e) {
                    console.warn(e)
                    return {fail: line}
                }
            })
        )
        const fails = correctedLines.map(line => line.fail).filter(x => x)
        lines = correctedLines.filter(x => x.fail == null)
        const body = lines.map(line => ({
            MouserPartNumber: line.part,
            Quantity: line.quantity,
            MouseReelRequest: 'None',
            CustomerPartNumber: line.reference,
        }))
        const response = await fetch(url, {
            method: 'POST',
            credentials: 'include',
            body: JSON.stringify(body),
            headers: {
                'Content-Type': 'application/json',
                Accept: 'application/json',
            },
        }).then(r => r.json())
        if (response.CartHasErrorItem || fails.length > 0) {
            return callback({success: false, fails})
        }
        callback({success: true})
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
                            `${this.protocol}${this.site}${this.cart}/cart/DeleteCartItem?cartItemId=${id}&page=null&grid-column=SortColumn&grid-dir=0`,
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
        const url = `${this.protocol}${this.site}/price-availability/`
        return new Promise((resolve, reject) => {
            http.get(url, {}, responseText => {
                const match = responseText.match(
                    /name="__RequestVerificationToken" type="hidden" value="(.*?)"/
                )
                if (match != null && match.length >= 2) {
                    return resolve(match[1])
                } else {
                    resolve(null)
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
