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
let n
let time_period_ms
const Promise = require('./bluebird')
Promise.config({cancellation:true})

const rateLimit = require('./promise-rate-limit')

const http = require('./http')

let aliases = {
    'Digi-Key' : 'Digikey',
    'RS Components' : 'RS'
}

let _search = function(query, retailers = [], other_fields = []) {
    if (!query || query === '') {
        return Promise.resolve({retailers:{}, partNumbers:[]})
    }
    query = query.replace(' / ', ' '); //search doesn't seem to like ' / '
    let url = `https://octopart.com/search?q=${encodeURIComponent(query)}&start=0`
    for (let i = 0; i < retailers.length; i++) {
        let retailer = retailers[i]
        for (let k in aliases) {
            let v = aliases[k]
            retailer = retailer.replace(v,k)
        }
        retailer = encodeURIComponent(retailer)
        url += `&filter[fields][offers.seller.name][]=${retailer}`
    }
    url += '&avg_avail=(1__*)&start=0'
    return http.promiseGet(url)
        .then(function(doc) {
            let result = {retailers:{}, partNumbers:[]}
            if (__in__('partNumbers', other_fields)) {
                let manufacturer = __guard__(doc.querySelector('.part-card-manufacturer'), x => x.innerHTML.trim())
                if (manufacturer == null) {
                    manufacturer = ''
                }
                let number = __guard__(doc.querySelector('.part-card-mpn'), x1 => x1.innerHTML.trim())
                if (number != null) {
                    result.partNumbers.push({manufacturer, part:number})
                }
            }
            //we prefer the lowest minimum order quantities (moq)
            let tds = doc.querySelectorAll('td.col-seller')
            let elements_moq = []
            for (let j = 0; j < tds.length; j++) {
                let td = tds[j]
                let min_qty = __guard__(td.parentElement, x2 => x2.querySelector('td.col-moq'))
                min_qty = parseInt(__guard__(min_qty, x3 => x3.innerHTML.trim().replace(/,/g,'')))
                if (isNaN(min_qty)) {
                    min_qty = undefined
                }
                elements_moq.push({tr:td.parentElement, moq:min_qty})
            }
            let moqs = {}
            for (let i1 = 0; i1 < elements_moq.length; i1++) {
                let {tr,moq} = elements_moq[i1]
                let retailer = tr.querySelector('td.col-seller').innerHTML.trim()
                for (let k in aliases) {
                    let v = aliases[k]
                    retailer = retailer.replace(k,v)
                }
                if ((moqs[retailer] == null) || ((moq != null) && moqs[retailer] > moq)) {
                    let sku = __guard__(__guard__(tr.querySelector('td.col-sku'), x5 => x5.firstElementChild), x4 => x4.innerHTML.trim())
                    if (sku != null) {
                        moqs[retailer] = moq
                        result.retailers[retailer] = sku
                    }
                }
            }
            return result
    })

    .catch(reason => ({retailers:{}, partNumbers:[]}))
}


exports.search = rateLimit(n=30, time_period_ms=10000, _search)

function __in__(needle, haystack) {
  return haystack.indexOf(needle) >= 0
}
function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined
}
