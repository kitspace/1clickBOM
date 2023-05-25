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
        if (/web\/ca/.test(this.cart)) {
            for (var name in rsOnline) {
                var method = rsOnline[name]
                this[name] = method
            }
        } else {
            for (var name in rsDelivers) {
                var method = rsDelivers[name]
                this[name] = method
            }
        }
        __guardFunc__(callback, f => f())
    }
}

exports.RS = RS

function __guardFunc__(func, transform) {
    return typeof func === 'function' ? transform(func) : undefined
}
