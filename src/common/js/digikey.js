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
        this._rate_limited_add_line = rateLimit(6, 1000, this._add_line)
    }

    clearCart(callback) {
        const url = `https${this.site}${this.cart}?webid=-1`
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
        const result = {success: true, fails: []}
        let count = lines.length
        return lines.map(line =>
            this._rate_limited_add_line(line, (line, line_result) => {
                if (!line_result.success) {
                    return this._get_part_id(
                        line,
                        (line, id) => {
                            return this._get_suggested(
                                line,
                                id,
                                'NextBreakQuanIsLowerExtPrice',
                                new_line => {
                                    return this._rate_limited_add_line(
                                        new_line,
                                        (_, r) => {
                                            if (!r.success) {
                                                return this._get_suggested(
                                                    line,
                                                    id,
                                                    'CutTapeQuantityIsMultipleOfReelQuantity',
                                                    new_line => {
                                                        return this._rate_limited_add_line(
                                                            new_line,
                                                            (_, r) => {
                                                                if (
                                                                    !r.success
                                                                ) {
                                                                    return this._get_suggested(
                                                                        new_line,
                                                                        id,
                                                                        'TapeReelQuantityTooLow',
                                                                        new_line => {
                                                                            return this._rate_limited_add_line(
                                                                                new_line,
                                                                                function(
                                                                                    _,
                                                                                    r
                                                                                ) {
                                                                                    if (
                                                                                        result.success
                                                                                    ) {
                                                                                        result.success =
                                                                                            r.success
                                                                                    }
                                                                                    result.fails = result.fails.concat(
                                                                                        r.fails
                                                                                    )
                                                                                    count--
                                                                                    if (
                                                                                        count ===
                                                                                        0
                                                                                    ) {
                                                                                        return callback(
                                                                                            result
                                                                                        )
                                                                                    }
                                                                                }
                                                                            )
                                                                        },
                                                                        function() {
                                                                            result.success = false
                                                                            result.fails.push(
                                                                                line
                                                                            )
                                                                            count--
                                                                            if (
                                                                                count ===
                                                                                0
                                                                            ) {
                                                                                return callback(
                                                                                    result
                                                                                )
                                                                            }
                                                                        }
                                                                    )
                                                                } else {
                                                                    count--
                                                                    if (
                                                                        count ===
                                                                        0
                                                                    ) {
                                                                        return callback(
                                                                            result
                                                                        )
                                                                    }
                                                                }
                                                            }
                                                        )
                                                    },
                                                    function() {
                                                        result.success = false
                                                        result.fails.push(line)
                                                        count--
                                                        if (count === 0) {
                                                            return callback(
                                                                result
                                                            )
                                                        }
                                                    }
                                                )
                                            } else {
                                                count--
                                                if (count === 0) {
                                                    return callback(result)
                                                }
                                            }
                                        }
                                    )
                                },
                                function() {
                                    result.success = false
                                    result.fails.push(line)
                                    count--
                                    if (count === 0) {
                                        return callback(result)
                                    }
                                }
                            )
                        },
                        function() {
                            result.success = false
                            result.fails.push(line)
                            count--
                            if (count === 0) {
                                return callback(result)
                            }
                        }
                    )
                } else {
                    count--
                    if (count === 0) {
                        return callback(result)
                    }
                }
            })
        )
    }
    _add_line(line, callback) {
        const url = `https${this.site}${this.addline}`
        const params =
            `qty=${line.quantity}&part=` +
            encodeURIComponent(line.part) +
            '&cref=' +
            encodeURIComponent(line.reference)
        const result = {success: true, fails: []}
        return http.post(
            url,
            params,
            {},
            responseText => {
                const doc = browser.parseDOM(responseText)
                //if the cart returns with a quick-add quantity filled-in there was an error
                const quick_add_quant = doc.querySelector(
                    '#ctl00_ctl00_mainContentPlaceHolder_mainContentPlaceHolder_txtQuantity'
                )
                result.success =
                    quick_add_quant != null &&
                    quick_add_quant.value != null &&
                    quick_add_quant.value === ''
                if (!result.success) {
                    result.fails.push(line)
                }
                return callback(line, result)
            },
            () => {
                result.success = false
                result.fails.push(line)
                return callback(line, result)
            }
        )
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
