const http = require('./http')
const {Promise} = require('bluebird')

const rsDelivers = {
    clearCart(callback) {
        const url = `https${this.site}/graphql`
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

    async _add_line(line) {
        const url = `https${this.site}/graphql`
        const body = await http.promisePost(
            url,
            `{"query":"mutation ($quantity: Float!, $stockCode:String!) {\\n                        addToBasketV2(pageType: Basket, quantity: $quantity, stockCode: $stockCode) {\\n                                isSuccess\\n                              }\\n                            }","variables":{"quantity":${line.quantity},"stockCode":"${line.part}"}}`,
            {json: true}
        )
        const res = JSON.parse(body)
        if (res.errors != null) {
            const invalid_qty_re = /Invalid quantity \d+ for product with ssm (\d+)/
            const err = res.errors[0]
            if (invalid_qty_re.test(err.message)) {
                const match = err.message.match(invalid_qty_re)
                const mult = parseInt(match[1], 10)
                const q = Math.ceil(line.quantity / mult) * mult
                const l = Object.assign({}, line, {
                    quantity: q,
                })
                return this._add_line(l)
            }
            return {success: false, line}
        }
        return {success: true}
    },

    addLines(lines, callback) {
        if (lines.length === 0) {
            callback({success: true, fails: []})
            return
        }
        const [merged, warnings] = this.mergeSameSkus(lines)
        return Promise.all(merged.map(line => this._add_line(line)))
            .catch(e => {
                console.error(e)
                callback({success: false, warnings, fails: lines}, this)
            })
            .then(results => {
                const fails = results.filter(r => !r.success).map(r => r.line)
                this.refreshSiteTabs()
                callback({success: fails.length === 0, warnings, fails}, this)
            })
    },
}

exports.rsDelivers = rsDelivers
