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
const rateLimit = require('./promise-rate-limit')

class Digikey extends RetailerInterface {
    constructor(country_code, settings, callback) {
        super('Digikey', country_code, 'data/digikey.json', settings, callback)

        //make sure we have a cart cookie
        http.get(`https${this.site}${this.cart}`, {notify: false}, () => {})

        //rate limiting _add_line as we were starting to get 503s
        this._rate_limited_add_line = rateLimit(
            6,
            1000,
            this._add_line.bind(this)
        )
    }

    clearCart(callback) {
        const url = `https${this.site}/classic/ordering/fastadd.aspx?webid=-1`
        return http.get(
            url,
            {},
            () => {
                if (callback != null) {
                    callback({success: true})
                }
                return this.refreshCartTabs()
            },
            () => {
                if (callback != null) {
                    return callback({success: false})
                }
            }
        )
    }

    addLines(lines, callback) {
        if (lines.length === 0) {
            callback({success: true, fails: []})
            return
        }
        return this._add_lines(lines, result => {
            if (callback != null) {
                callback(result, this, lines)
            }
            return this.refreshCartTabs()
        })
    }

    _add_lines(lines, callback) {
        return Promise.all(lines.map(this._rate_limited_add_line)).then(
            results => {
                console.log({results})
                callback({success: true, fails: []})
            }
        )
    }
    _add_line(line, callback) {
        const url = `https${this.site}${this.addline}`
        const params = {
            details: [
                {
                    quantity: `${line.quantity}`,
                    partNumber: line.part,
                    cRef: line.reference.slice(0, 48)
                }
            ],
            overrideUpsell: false
        }

        return fetch(url, {
            method: 'POST',
            headers: {
                pragma: 'no-cache',
                'Content-Type': 'application/json'
            },
            referrer: 'https://www.digikey.co.uk/ordering/shoppingcart',
            credentials: 'include',
            body: JSON.stringify(params)
        })
            .then(r => {
                if (r.status === 200) {
                    return r.json().then(x => {
                        console.log(x)
                        return {line, success: x.BaseSuccess}
                    })
                } else {
                    return {line, success: false}
                }
            })
            .catch(() => ({line, success: false}))
    }

    _get_part_id(line, callback, error_callback) {
        let url = `https${this.site}/product-detail/en/`
        url += line.part + '/'
        url += line.part + '/'
        return http.get(
            url,
            {notify: false},
            function(responseText) {
                const doc = browser.parseDOM(responseText)
                const inputs = doc.querySelectorAll('input')
                for (let i = 0; i < inputs.length; i++) {
                    const input = inputs[i]
                    if (input.name === 'partid') {
                        callback(line, input.value)
                        return
                    }
                }
                //we never found an id
                return error_callback()
            },
            error_callback
        )
    }
    _get_suggested(line, id, error, callback, error_callback) {
        let url = `https${this.site}/classic/Ordering/PackTypeDialog.aspx?`
        url += `part=${line.part}`
        url += `&qty=${line.quantity}`
        url += `&partId=${id}`
        url += `&error=${error}&cref=&esc=-1&returnURL=%2f%2fwww.digikey.co.uk%2fclassic%2fordering%2faddpart.aspx&fastAdd=false&showUpsell=True`
        return http.get(
            url,
            {line, notify: false},
            function(responseText) {
                const doc = browser.parseDOM(responseText)
                switch (error) {
                    case 'TapeReelQuantityTooLow':
                        var choice = doc.getElementById('rb1')
                        break
                    case 'NextBreakQuanIsLowerExtPrice':
                        choice = doc.getElementById('rb2')
                        break
                    case 'CutTapeQuantityIsMultipleOfReelQuantity':
                        choice = doc.getElementById('rb1')
                        break
                }
                if (choice != null) {
                    const label = choice.nextElementSibling
                    if (label != null) {
                        const split = label.innerHTML.split('&nbsp;')
                        const part = split[2]
                        const number = parseInt(split[0].replace(/,/, ''))
                        if (!isNaN(number)) {
                            const it = line
                            it.part = part
                            it.quantity = number
                            return callback(it)
                        } else {
                            return error_callback()
                        }
                    } else {
                        return error_callback()
                    }
                } else {
                    return error_callback()
                }
            },
            error_callback
        )
    }
}

exports.Digikey = Digikey
