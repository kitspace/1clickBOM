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
const Promise = require('bluebird')
const {RetailerInterface} = require('./retailer_interface')
const {rsOnline} = require('./rs_online')
const {rsDelivers} = require('./rs_delivers')

Promise.config({cancellation: true})

class RS extends RetailerInterface {
    constructor(country_code, settings, callback) {
        super('RS', country_code, 'data/rs.json', settings)
        if (/basket/.test(this.cart)) {
            for (var name in rsOnline) {
                var method = rsOnline[name]
                this[name] = method
            }
            chrome.webRequest.onBeforeSendHeaders.addListener(
                details => {
                    const requestHeaders = setHeader(
                        details.requestHeaders,
                        'origin',
                        `https://${this.site}`
                    )
                    return {requestHeaders}
                },
                {
                    urls: [
                        `https${this.site}/web/services/aggregation/search-and-browse/graphql`,
                        `https${this.site}/services/buy/aggregator/graphql`,
                    ],
                },
                ['blocking', 'requestHeaders', 'extraHeaders']
            )
        } else {
            for (var name in rsDelivers) {
                var method = rsDelivers[name]
                this[name] = method
            }
        }
        if (callback != null) {
            callback()
        }
    }
}

exports.RS = RS

function setHeader(headers, name, value) {
    headers = headers.filter(h => h.name.toLowerCase() !== name.toLowerCase())
    headers.push({name, value})
    return headers
}
