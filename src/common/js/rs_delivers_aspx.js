const http = require('./http')
const {browser} = require('./browser')

const rsDeliversAspx = {
    clearCart(callback) {
        const url = `http${this
            .site}/ShoppingCart/NcjRevampServicePage.aspx/EmptyCart`
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
        return this._get_invalid_line_ids(ids => {
            return this._delete_invalid(ids, callback)
        })
    },

    _delete_invalid(ids, callback) {
        const url = `http${this
            .site}/ShoppingCart/NcjRevampServicePage.aspx/RemoveMultiple`
        let params = '{"request":{"encodedString":"'
        for (let i = 0; i < ids.length; i++) {
            const id = ids[i]
            params += id + '|'
        }
        params += '"}}'
        return http.post(
            url,
            params,
            {json: true},
            function() {
                if (callback != null) {
                    return callback()
                }
            },
            function() {
                if (callback != null) {
                    return callback()
                }
            }
        )
    },

    _get_invalid_line_ids(callback) {
        const url = `http${this
            .site}/ShoppingCart/NcjRevampServicePage.aspx/GetCartHtml`
        return http.post(
            url,
            undefined,
            {json: true},
            function(responseText) {
                const doc = browser.parseDOM(JSON.parse(responseText).html)
                const ids = []
                const parts = []
                const iterable = doc.getElementsByClassName('errorOrderLine')
                for (let i = 0; i < iterable.length; i++) {
                    const elem = iterable[i]
                    ids.push(
                        elem.parentElement.nextElementSibling
                            .querySelector('.quantityTd')
                            .firstElementChild.classList[3].split('_')[1]
                    )
                    parts.push(
                        elem.parentElement.nextElementSibling
                            .querySelector('.descriptionTd')
                            .firstElementChild.nextElementSibling.firstElementChild.nextElementSibling.innerText.trim()
                    )
                }
                return callback(ids, parts)
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
                const url = `http${this
                    .site}/ShoppingCart/NcjRevampServicePage.aspx/BulkOrder`
                let params = '{"request":{"lines":"'
                for (let j = 0; j < lines.length; j++) {
                    const line = lines[j]
                    params +=
                        `${line.part},${line.quantity},,` +
                        `${line.reference}\n`
                }
                params += '"}}'
                return http.post(
                    url,
                    params,
                    {json: true},
                    responseText => {
                        const doc = browser.parseDOM(
                            JSON.parse(responseText).html
                        )
                        const success =
                            doc.querySelector('#hidErrorAtLineLevel').value ===
                            '0'
                        if (!success) {
                            return this._get_invalid_line_ids((ids, parts) => {
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

exports.rsDeliversAspx = rsDeliversAspx

function __in__(needle, haystack) {
    return haystack.indexOf(needle) >= 0
}
