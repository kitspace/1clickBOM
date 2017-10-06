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
const {Newark} = require('./newark')

class Farnell extends RetailerInterface {
    constructor(country_code, settings, callback) {
        super('Farnell', country_code, 'data/farnell.json', settings)
        //all Farnell sites are Newark style sites now so we use Newark's
        //methods
        const names = Object.getOwnPropertyNames(Newark.prototype)
        for (const index in names) {
            const method = Newark.prototype[names[index]]
            this[names[index]] = method
        }
        this.cart = '/webapp/wcs/stores/servlet/AjaxOrderItemDisplayView'
        this.affiliate_prefix =
            'http://www.anrdoezrs.net/links/8291192/type/dlg/'
        this._set_store_id(() => {
            return callback(this)
        })
    }
}

exports.Farnell = Farnell
