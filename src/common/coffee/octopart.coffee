# The contents of this file are subject to the Common Public Attribution
# License Version 1.0 (the “License”); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
# License Version 1.1 but Sections 14 and 15 have been added to cover use of
# software over a computer network and provide for limited attribution for the
# Original Developer. In addition, Exhibit A has been modified to be consistent
# with Exhibit B.
#
# Software distributed under the License is distributed on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations under
# the License.
#
# The Original Code is 1clickBOM.
#
# The Original Developer is the Initial Developer. The Original Developer of
# the Original Code is Kaspar Emanuel.

rateLimit = require('promise-rate-limit')
http = require './http'

aliases =
    'Digi-Key' : 'Digikey'
    'RS Components' : 'RS'

_search = (query, retailers = [], other_fields = []) ->
    if query == ''
        return Promise.resolve({retailers:{}})
    url = "https://octopart.com/search?q=#{query}&start=0"
    for retailer in retailers
        for k,v of aliases
            retailer = retailer.replace(v,k)
        retailer = encodeURIComponent(retailer)
        url += "&filter[fields][offers.seller.name][]=#{retailer}"
    url += '&filter[fields][avg_avail][]=[1 TO *]'
    http.promiseGet(url)
        .then (doc) ->
            result = {retailers:{}}
            if 'manufacturer' in other_fields
                result.manufacturer = doc.querySelector('.PartHeader__brand')
                    ?.firstElementChild?.innerHTML.trim()
            if 'partNumber' in other_fields
                result.partNumber = doc.querySelector('.PartHeader__mpn')
                    ?.firstElementChild?.innerHTML.trim()
            tds = doc.querySelectorAll('td.col-seller')
            elements_moq = []
            for td in tds
                min_qty = td.parentElement?.querySelector('td.col-moq')
                min_qty = parseInt(min_qty.innerHTML.trim().replace(/,/g,''))
                if isNaN(min_qty)
                    min_qty = undefined
                elements_moq.push({td:td, moq:min_qty})
            moqs = {}
            for {td,moq} in elements_moq
                retailer = td.querySelector('a').innerHTML.trim()
                for k,v of aliases
                    retailer = retailer.replace(k,v)
                if not moqs[retailer]? or (moq? and moqs[retailer] > moq)
                    sku = td.parentElement?.querySelector('td.col-sku')
                        ?.firstElementChild?.innerHTML.trim()
                    if sku?
                        moqs[retailer] = moq
                        result.retailers[retailer] = sku
            return result
    .catch (reason) ->
            return {retailers:{}}

exports.search = rateLimit(1, 360, _search)
