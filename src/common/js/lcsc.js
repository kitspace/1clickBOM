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

function getHeaders() {
    return {
        accept: 'application/json, text/plain, */*',
        'content-type': 'application/json;charset=UTF-8',
        'sec-fetch-dest': 'empty',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-site'
    }
}

async function _add_line(line) {
    let quantity = line.quantity
    return fetch('https://wwwapi.lcsc.com/v1/carts/add', {
        method: 'POST',
        credentials: 'include',
        headers: getHeaders(),
        referrer: 'https://lcsc.com/cart',
        referrerPolicy: 'strict-origin-when-cross-origin',
        body: JSON.stringify({
            product_code: line.part,
            quantity: line.quantity,
            // commas in the tag seem to just get removed by lcsc so we use
            // a space instead
            tag: line.reference.replace(/,/g, ' '),
            link_from: 'https://lcsc.com/cart'
        })
    })
        .then(r => r.json())
        .then(r => {
            if (r.error == null) {
                return {success: true}
            }
            return {success: false}
        })
}

class LCSC extends RetailerInterface {
    constructor(country_code, settings, callback) {
        super('LCSC', country_code, null, settings)
    }

    async clearCart(callback) {
        try {
            const cart = await fetch('https://wwwapi.lcsc.com/v1/carts', {
                headers: getHeaders(),
                method: 'GET',
                mode: 'cors',
                credentials: 'include'
            }).then(r => r.json())

            const cart_ids = cart.stock.concat(cart.back_order).map(x => x.id)
            const ret = {success: true}
            if (cart_ids.length > 0) {
                const r = await fetch(
                    'https://wwwapi.lcsc.com/v1/carts/del-cart',
                    {
                        headers: getHeaders(),
                        method: 'POST',
                        mode: 'cors',
                        credentials: 'include',
                        body: JSON.stringify({cart_ids})
                    }
                )
                if (r.status !== 200) {
                    ret.success = false
                }
            }
            this.refreshSiteTabs()
            if (callback != null) {
                callback(ret)
            }
            return ret
        } catch (e) {
            return {success: false}
        }
    }

    addLines(lines, callback) {
        if (lines.length === 0) {
            const result = {success: true, fails: []}
            if (callback != null) {
                callback(result, this, lines)
            }
            return Promise.resolve(result)
        }
        const [merged, warnings] = this.mergeSameSkus(lines)
        lines = merged
        return Promise.all(
            lines.map(line =>
                _add_line(line).catch(err => {
                    console.error(err)
                    return {success: false}
                })
            )
        ).then(rs => {
            const result = {success: true, fails: []}
            rs.forEach((r, i) => {
                if (!r.success) {
                    result.success = false
                    result.fails.push(lines[i])
                }
            })
            this.refreshSiteTabs()
            result.warnings = (result.warnings || []).concat(warnings)
            if (callback != null) {
                callback(result, this, lines)
            }
            return result
        })
    }
}

exports.LCSC = LCSC

