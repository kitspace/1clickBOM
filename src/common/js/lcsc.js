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
const {browser} = require('./browser')
const http = require('./http')
const rateLimit = require('./promise-rate-limit')

const accepted_codes = [200, 204004]

const _add_line = rateLimit(1, 750, async line => {
    const doc = await http.promiseGet(
        'https://lcsc.com/pre_search/link?type=lcsc&&value=' + line.part
    )
    const button = doc.querySelector('.btn-tocart')
    if (button == null) {
        return {success: false}
    }
    const tag = line.reference.slice(0, 20)
    const product_id = button.getAttribute('data-productid')
    let quantity = line.quantity
    const params = `product_id=${product_id}&quantity=${quantity}&tag=${tag}`
    return http
        .promisePost('https://lcsc.com/cart/add', params)
        .then(r => {
            r = JSON.parse(r)
            if (r.code === 400001) {
                quantity = Math.ceil(quantity / r.step) * r.step
                const params = `product_id=${product_id}&quantity=${quantity}&tag=${tag}`
                return http
                    .promisePost('https://lcsc.com/cart/add', params)
                    .then(r => JSON.parse(r))
            }
            return r
        })
        .then(r => {
            if (accepted_codes.includes(r.code)) {
                return {success: true}
            }
            return {success: false}
        })
})

class LCSC extends RetailerInterface {
    constructor(country_code, settings, callback) {
        super('LCSC', country_code, null, settings)
    }

    clearCart(callback) {
        return fetch('https://lcsc.com/carts')
            .then(r => r.json())
            .then(cart => {
                const params = cart.data
                    .map(
                        x =>
                            encodeURIComponent('product_id[]') +
                            '=' +
                            encodeURIComponent(x.product_id)
                    )
                    .join('&')
                return fetch('https://lcsc.com/cart/delete', {
                    method: 'POST',
                    headers: {
                        'Content-Type':
                            'application/x-www-form-urlencoded;charset=UTF-8'
                    },
                    body: params
                })
            })
            .then(r => r.json())
            .then(r => {
                const ret = {success: false}
                if (r.code === 200) {
                    ret.success = true
                }
                this.refreshSiteTabs()
                if (callback != null) {
                    callback(ret)
                }
                return ret
            })
    }

    addLines(lines, callback) {
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
            if (callback != null) {
                callback(result, this, lines)
            }
            return result
        })
    }
}

exports.LCSC = LCSC
