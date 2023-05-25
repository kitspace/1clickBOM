const http = require('./http')
const {browser} = require('./browser')

const rsDelivers = {
    clearCart(callback) {
        const url = `http${this.site}/graphql`
        return http
            .promisePost(
                url,
                '{"operationName":"clearBasket","variables":{},"query":"mutation clearBasket {\\n  clearBasket {\\n    isSuccess\\n    tags {\\n      ... on BulkRemoveFromBasketEnsighten {\\n        products {\\n          productId\\n          orderQuantity\\n          __typename\\n        }\\n        __typename\\n      }\\n      ... on BulkRemoveFromBasketGoogleAnalytics {\\n        products {\\n          id\\n          name\\n          category\\n          brand\\n          quantity\\n          __typename\\n        }\\n        __typename\\n      }\\n      ... on BulkRemoveFromBasketTealium {\\n        products {\\n          productId\\n          __typename\\n        }\\n        __typename\\n      }\\n      ... on GA4Event_RemoveFromCart {\\n        event\\n        ecommerce {\\n          currency\\n          value\\n          items {\\n            ...GA4Item\\n            __typename\\n          }\\n          __typename\\n        }\\n        __typename\\n      }\\n      __typename\\n    }\\n    __typename\\n  }\\n}\\n\\nfragment GA4Item on GA4Item {\\n  item_id\\n  item_name\\n  currency\\n  discount\\n  index\\n  item_brand\\n  item_category\\n  item_category2\\n  item_category3\\n  item_category4\\n  price\\n  quantity\\n  __typename\\n}\\n"}',
                {json: true}
            )
            .catch(() => {
                callback({success: false}, this)
            })
            .then(() => {
                this.refreshSiteTabs()
                callback({success: true}, this)
            })
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
        const [merged, warnings] = this.mergeSameSkus(lines)
        lines = merged
        return this._add_lines(lines, 0, {success: true, fails: []}, result => {
            result.warnings = (result.warnings || []).concat(warnings)
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
                                        fails: result.fails.concat(invalid),
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
    },
}

exports.rsDelivers = rsDelivers

function __in__(needle, haystack) {
    return haystack.indexOf(needle) >= 0
}
