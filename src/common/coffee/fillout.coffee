http        = require './http'
{retailers} = require './retailers'

aliases =
    'Digi-Key' : 'Digikey'
    'RS Components' : 'RS'

exports.search = (part) ->
    url = "https://octopart.com/search?q=#{part}&start=0"
    for retailer in retailers
        for k,v of aliases
            retailer = retailer.replace(v,k)
        retailer = encodeURIComponent(retailer)
        url += "&filter[fields][offers.seller.name][]=#{retailer}"
    http.promiseGet(url)
        .then (doc) ->
            r = {}
            for retailer in retailers
                r[retailer] = null
            for n,i in doc.querySelectorAll('td.col-seller')
                retailer = n.querySelector('a').innerHTML
                for k,v of aliases
                    retailer = retailer.replace(k,v)
                if r[retailer] == null
                    sku = n.parentElement?.querySelector('td.col-sku')
                        ?.firstElementChild?.innerHTML
                    if sku?
                        r[retailer] = sku
                done = retailers.reduce (prev, retailer) ->
                    prev && (r[retailer] != null)
                if done
                    break
            return r

