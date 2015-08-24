http = require './http'

exports.search = (part) ->
    url = "https://octopart.com/search?q=#{part}&start=0&filter[fields]\
    [offers.seller.name][]=Mouser&filter[fields][offers.seller.name][]=\
    Digi-Key&filter[fields][offers.seller.name][]=RS%20Components&filter\
    [fields][offers.seller.name][]=Farnell&filter[fields][offers.seller\
    .name][]=Newark"
    http.promiseGet(url)
        .then (doc) ->
            r =
                RS      : null
                Digikey : null
                Farnell : null
                Mouser  : null
                Newark  : null
            for n,i in doc.querySelectorAll('td.col-seller')
                retailer = n.querySelector('a').innerHTML
                retailer = retailer.replace('Digi-Key', 'Digikey')
                retailer = retailer.replace('RS Components', 'RS')
                console.log(retailer)
                if r[retailer] == null
                    sku = n.parentElement?.querySelector('td.col-sku')
                        ?.firstElementChild?.innerHTML
                    if sku?
                        r[retailer] = sku
                done = Object.keys(r).reduce (prev, k) ->
                    prev && (r[k] != null)
                if done
                    break
            return r

