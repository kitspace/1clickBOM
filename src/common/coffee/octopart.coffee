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

http = require './http'

aliases =
    'Digi-Key' : 'Digikey'
    'RS Components' : 'RS'

exports.search = (query, retailers = [], other_fields = []) ->
    if query == ''
        return Promise.resolve({retailers:{}})
    url = "https://octopart.com/search?q=#{query}&start=0"
    for retailer in retailers
        for k,v of aliases
            retailer = retailer.replace(v,k)
        retailer = encodeURIComponent(retailer)
        url += "&filter[fields][offers.seller.name][]=#{retailer}"
    http.promiseGet(url)
        .then (doc) ->
            r = {retailers:{}}
            if 'manufacturer' in other_fields
                r.manufacturer = doc.querySelector('.PartHeader__brand')
                    ?.firstElementChild?.innerHTML.trim()
            if 'partNumber' in other_fields
                r.partNumber = doc.querySelector('.PartHeader__mpn')
                    ?.firstElementChild?.innerHTML.trim()
            for retailer in retailers
                r.retailers[retailer] = null
            for n,i in doc.querySelectorAll('td.col-seller')
                retailer = n.querySelector('a').innerHTML.trim()
                for k,v of aliases
                    retailer = retailer.replace(k,v)
                if r.retailers[retailer] == null
                    sku = n.parentElement?.querySelector('td.col-sku')
                        ?.firstElementChild?.innerHTML.trim()
                    if sku?
                        r.retailers[retailer] = sku
                done = retailers.reduce (prev, retailer) ->
                    prev && (r.retailers[retailer] != null)
                , true
                if done
                    break
            return r

