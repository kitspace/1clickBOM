window.get_100_in_stock = (start, retailer, callback) ->
    url = "https://octopart.com/api/v3/parts/search";

    # NOTE: Use your API key here (https://octopart.com/api/register)
    url += "?apikey=CHANGE_ME"

    url += "&q="
    url += "&start=" + start
    url += "&limit=100"
    url += "&filter[queries][]=offers.seller.name:" + retailer + "*"
    console.log(url)
    get url, (event) ->
        doc = JSON.parse(event.target.response)
        ret = []
        regex = new RegExp retailer
        for obj in doc.results
            for offer in obj.item.offers
                if regex.test(offer.seller.name) && offer.in_stock_quantity > 0
                    ret.push(offer.sku)
                    break
        callback(ret)


window.octopart_get_in_stock = (retailer, callback) ->
    ret = []
    count = 0
    for i in [0..900] by 100
        count += 1
        get_100_in_stock i, retailer, (part_numbers) ->
            ret = ret.concat(part_numbers)
            count -= 1
            console.log(count)
            if count <= 0
                if callback?
                    callback(ret)


octoparts = ""
window.octopart_get_in_stock "Digi-Key", (parts) ->
    for part in parts
        octoparts += "octotest\t1\tDigikey\t" + part + "\n"
    window.octopart_get_in_stock "Mouser", (parts) ->
        for part in parts
            octoparts += "octotest\t1\tMouser\t" + part + "\n"
        window.octopart_get_in_stock "Farnell", (parts) ->
            for part in parts
                octoparts += "octotest\t1\tFarnell\t" + part + "\n"
            window.octopart_get_in_stock "Newark", (parts) ->
                for part in parts
                    octoparts += "octotest\t1\tNewark\t" + part + "\n"
                window.octopart_get_in_stock "Newark", (parts) ->
                    for part in parts
                        octoparts += "octotest\t1\tNewark\t" + part + "\n"
                    window.octopart_get_in_stock "RS", (parts) ->
                        for part in parts
                            octoparts += "octotest\t1\tRS\t" + part + "\n"
                        console.log(octoparts)
