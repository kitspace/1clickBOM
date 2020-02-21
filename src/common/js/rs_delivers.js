const http = require('./http')
const {browser} = require('./browser')

const rsDelivers = {
    clearCart(callback) {
        const url = `http${this.site}/CheckoutServices/DeleteAllProductsInCart`
        return http.post(
            url,
            '',
            {json: true},
            responseText => {
                if (callback != null) {
                    callback({success: true}, this)
                }
                this.refreshSiteTabs()
                return this.refreshCartTabs()
            },
            () => {
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
        return http.get(
            url,
            {},
            function(responseText) {
                let html = responseText
                try {
                    html = JSON.parse(responseText).cartLinesHtml
                } catch (e) {}
                const doc = browser.parseDOM(html)
                const errors = doc.getElementsByClassName('errorOrderLine')
                const ids = []
                const parts = []
                for (let i = 0; i < errors.length; i++) {
                    const error = errors[i]
                    parts.push(
                        error.parentElement.nextElementSibling
                            .querySelector('.descTd')
                            .firstElementChild.nextElementSibling.firstElementChild.nextElementSibling.innerText.trim()
                            .replace('-', '')
                    )
                }
                return callback(parts)
            },
            () => callback([], [])
        )
    },

    addLines(lines, callback) {
        if (lines.length === 0) {
            callback({success: true, fails: []})
            return
        }
        return this._add_lines(lines, 0, {success: true, fails: []}, result => {
            callback(result, this, lines)
            this.refreshCartTabs()
            return this.refreshSiteTabs()
        })
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
                return http.post(
                    url,
                    params,
                    responseText => {
                        return callback({success: true})
                        const doc = browser.parseDOM(
                            JSON.parse(responseText).html
                        )
                        const success =
                            doc.querySelector('#hidErrorAtLineLevel').value ===
                            '0'
                        if (!success) {
                            return this._get_invalid_lines(parts => {
                                const invalid = []
                                for (let k = 0; k < lines.length; k++) {
                                    const line = lines[k]
                                    if (__in__(line.part, parts)) {
                                        invalid.push(line)
                                    }
                                }
                                return this._add_lines(
                                    lines_incoming,
                                    i + 100,
                                    {
                                        success: false,
                                        fails: result.fails.concat(invalid)
                                    },
                                    callback
                                )
                            })
                        } else {
                            return this._add_lines(
                                lines_incoming,
                                i + 100,
                                result,
                                callback
                            )
                        }
                    },
                    () => {
                        return this._add_lines(
                            lines_incoming,
                            i + 100,
                            {success: false, fails: result.fails.concat(lines)},
                            callback
                        )
                    }
                )
            })
        } else {
            return callback(result)
        }
    }
}

exports.rsDelivers = rsDelivers

function __in__(needle, haystack) {
    return haystack.indexOf(needle) >= 0
}
