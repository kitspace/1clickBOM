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

