http = require './http'

exports.search = (part) ->
    url = "https://octopart.com/search?q=#{part}&start=0&filter[fields]\
    [offers.seller.name][]=Mouser&filter[fields][offers.seller.name][]=\
    Digi-Key&filter[fields][offers.seller.name][]=RS%20Components&filter\
    [fields][offers.seller.name][]=Farnell&filter[fields][offers.seller\
    .name][]=Newark"
    http.promiseGet(url)
        .then (doc) ->
            retailers = []
            for n,i in doc.querySelectorAll('td.col-seller')
                if i >= 5
                    break
                else
                    retailer = n.querySelector('a').innerHTML
                    retailer.replace('Digi-Key', 'DigiKey')
                    retailer.replace('RS Components', 'RS')
                    retailers.push(retailer)
            skus = []
            for n,i in doc.querySelectorAll('td.col-sku')
                if i >= 5
                    break
                else
                    skus.push(n.querySelector('a').innerHTML)
            r = {}
            for retailer,index in retailers
                r[retailer] = skus[index]
            return r

