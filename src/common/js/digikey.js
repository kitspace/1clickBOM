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

class Digikey extends RetailerInterface {
    constructor(country_code, settings, callback) {
        super('Digikey', country_code, 'data/digikey.json', settings, callback)

        //make sure we have a cart cookie
        http.get(`https${this.site}${this.cart}`, {notify: false}, () => {})
    }

    clearCart(callback) {
        const url = `https${this.site}${this.addline}?webid=-1`
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

    openCartTab() {
        browser.tabsQuery(
            {url: `*${this.site}${this.addline}*`, currentWindow: true},
            tabs => {
                if (tabs.length > 0) {
                    browser.tabsActivate(tabs[tabs.length - 1])
                } else {
                    this._open_tab(this.site + this.cart)
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
        })
    }

    _add_lines(lines, callback) {
        for (let i = 0; i < lines.length / 30; i++) {
            const _30_lines = lines.slice(i * 30, i * 30 + 30)
            this._add_30_lines(_30_lines)
        }
        // we are faking success because we can't get a response from the digikey tab
        // it seems to be very reliable though
        setTimeout(() => callback({success: true, fails: []}), 1000)
    }

    _add_30_lines(lines) {
        const url = `https${this.site}${this.addline}`
        let params = ''
        lines.forEach((line, i) => {
            params +=
                (i === 0 ? '?' : '&') +
                `part${i}=${encodeURIComponent(line.part)}` +
                `&qty${i}=${encodeURIComponent(line.quantity)}` +
                `&cref${i}=${encodeURIComponent(line.reference.slice(0, 48))}`
        })
        const tab = browser.tabsCreate(url + params)
    }
}

exports.Digikey = Digikey
