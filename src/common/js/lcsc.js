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

async function _add_lines(lines, fails) {
    if (lines.length === 0) {
        return {success: fails.length === 0, fails}
    }
    const body = lines.map(line => ({
        productCode: line.part,
        quantity: line.quantity,
        customerTag: line.reference,
        cartSource: 'product_list',
    }))

    const r = await fetch('https://wmsc.lcsc.com/wmsc/cart/add/batch', {
        headers: {
            accept: 'application/json, text/plain, */*',
            'content-type': 'application/json;charset=UTF-8',
        },
        body: JSON.stringify(body),
        method: 'POST',
        credentials: 'include',
    }).then(r => r.json())

    if (r.result.error) {
        const failedProducts = r.result.error.map(x => x.productCode)
        fails = fails.concat(
            lines.filter(line => failedProducts.includes(line.part))
        )
        lines = lines.filter(line => !failedProducts.includes(line.part))
        return _add_lines(lines, fails)
    }

    return {success: fails.length === 0, fails}
}

class LCSC extends RetailerInterface {
    constructor(country_code, settings, callback) {
        super('LCSC', country_code, null, settings)
    }

    async clearCart(callback) {
        try {
            const cart = await fetch('https://wmsc.lcsc.com/wmsc/cart/index', {
                headers: {
                    accept: 'application/json, text/plain, */*',
                },
                method: 'GET',
                credentials: 'include',
            }).then(r => r.json())
            const {
                instockCartList,
                lcOrderCartList,
                orderCartList,
            } = cart.result
            const cartIds = instockCartList
                .concat(lcOrderCartList)
                .concat(orderCartList)
                .map(x => x.uuid)

            const res = await fetch('https://wmsc.lcsc.com/wmsc/cart/delete', {
                headers: {
                    accept: 'application/json, text/plain, */*',
                    'content-type': 'application/x-www-form-urlencoded',
                },
                body: `uuid=${encodeURIComponent(String(cartIds))}`,
                method: 'POST',
                credentials: 'include',
            })
            if (res.status !== 200) {
                throw Error('Non 200 response for clear cart')
            }
            if (callback != null) {
                callback({success: true})
            }
            this.refreshSiteTabs()
            return {success: true}
        } catch (e) {
            console.error(e)
            if (callback != null) {
                callback({success: false})
            }
            return {success: false}
        }
    }

    async addLines(lines, callback) {
        try {
            const r = await _add_lines(lines, [])
            if (callback != null) {
                callback(r)
            }
            this.refreshSiteTabs()
            return r
        } catch (e) {
            console.error(e)
            if (callback != null) {
                callback({success: false, fails: lines})
            }
            return {success: false, fails: lines}
        }
    }
}

exports.LCSC = LCSC
