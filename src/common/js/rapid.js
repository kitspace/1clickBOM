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

const Promise = require('./bluebird')
Promise.config({cancellation: true})
const {RetailerInterface} = require('./retailer_interface')
const {browser} = require('./browser')
const http = require('./http')

class Rapid extends RetailerInterface {
    constructor(country_code, settings, callback) {
        super('Rapid', country_code, 'data/rapid.json', settings)
    }

    clearCart(callback) {
        return this._modify_cookie()
            .then(() => this._get_token())
            .then(token => {
                return fetch('https' + this.site + this.cart + '/Clear', {
                    headers: {
                        'content-type': 'application/json',
                        accept:
                            'application/json, text/javascript, */*; q=0.01;',
                        requestverificationtoken: token
                    },
                    method: 'POST',
                    body: '{}'
                })
            })
            .then(r => {
                if (r.status !== 200) {
                    throw Error(r.status)
                }
                this.refreshCartTabs()
                callback({success: true})
            })
            .catch(e => {
                console.error(e)
                callback({success: false})
            })
    }

    addLines(lines, callback) {}

    _get_cookie() {
        return browser.getCookies({url: 'https' + this.site}).then(cookies => {
            return cookies.find(c => /\.AspNetCore\.Antiforgery\./.test(c.name))
        })
    }

    _modify_cookie() {
        // modifies the ASPNET Antiforgery cookie so it get's sent along with
        // our requests
        return this._get_cookie()
            .then(cookie => {
                // we seem to need to remove the original first
                return browser
                    .removeCookie({url: 'https' + this.site, name: cookie.name})
                    .then(() => cookie)
            })
            .then(cookie => {
                cookie.url = 'https' + this.site
                delete cookie.hostOnly
                delete cookie.session
                cookie.sameSite = 'no_restriction'
                return browser.setCookie(cookie)
            })
    }

    _get_token() {
        return fetch('https' + this.site + this.cart, {credentials: 'include'})
            .then(r => {
                if (r.status !== 200) {
                    throw Error(r.status)
                }
                return r.text()
            })
            .then(text => {
                const doc = browser.parseDOM(text)
                const input = doc.querySelector(
                    'input[name="__RequestVerificationToken"]'
                )
                if (input) {
                    return input.value
                }
            })
    }
}

exports.Rapid = Rapid
