const http = require('./http')
const {Promise} = require('bluebird')

const rsOnline = {
    async clearCart(callback) {
        const cartUrl = `https${this.site}/basket`
        const cart = await fetch(cartUrl, {credentials: 'include'}).then(r =>
            r.text()
        )
        const doc = new DOMParser().parseFromString(cart, 'text/html')
        const parts = Array.from(
            doc.querySelectorAll('dl[data-testid=Product__codes] > dd > a')
        ).map(node => node.innerHTML)

        const url = `https${this.site}/services/buy/aggregator/graphql`
        await http
            .promisePost(
                url,
                JSON.stringify({
                    operationName: 'removeProduct',
                    variables: {
                        products: parts.map(p => ({productNumber: p})),
                    },
                    query: gql`
                        mutation removeProduct($products: [ProductToUpdate]!) {
                            removeBasketProducts(products: $products) {
                                error
                                response
                                __typename
                            }
                        }
                    `,
                }),
                {json: true}
            )
            .catch(() => {
                this.refreshCartTabs()
                callback({success: false}, this)
            })
            .then(() => {
                this.refreshCartTabs()
                callback({success: true}, this)
            })
    },

    async _add_line(line) {
        const url = `https${this.site}/web/services/aggregation/search-and-browse/graphql`

        const body = await http.promisePost(
            url,
            JSON.stringify([
                {
                    query: gql`
                        mutation addToBasket(
                            $locale: String!
                            $articleId: String!
                            $quantity: Int!
                            $appendQty: Boolean
                        ) {
                            addToBasket(
                                locale: $locale
                                articleId: $articleId
                                quantity: $quantity
                                appendQty: $appendQty
                            ) {
                                basketId
                                jSessionId
                                cartItemCount
                            }
                        }
                    `,
                    variables: {
                        appendQty: false,
                        articleId: line.part,
                        locale: 'uk',
                        quantity: line.quantity,
                    },
                },
            ]),
            {json: true}
        )
        const result = JSON.parse(body)
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
                this.refreshSiteTabs()
                callback({success: false, warnings, fails: lines}, this)
            })
            .then(async results => {
                // fetch the cart once to try and make sure it's up to date when we refresh
                const cartUrl = `https${this.site}/basket`
                await fetch(cartUrl, {credentials: 'include'})

                this.refreshCartTabs()

                const fails = results.filter(r => !r.success).map(r => r.line)
                callback({success: fails.length === 0, warnings, fails}, this)
            })
    },
}

function gql(strings) {
    // doesn't do anything, just used so we can autoformat the queries with
    // prettier
    return strings.join('')
}

exports.rsOnline = rsOnline
