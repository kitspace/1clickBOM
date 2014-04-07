@get = (url) ->
    xhr = new XMLHttpRequest
    xhr.open("GET",url,false)
    xhr.send()
    return((new DOMParser).parseFromString(xhr.responseText, "text/html"))

@scrape = () ->
    data = get_local("data/rs_international.json")
    ret = {}
    for key of data.sites
        doc = get("http" + data.sites[key])
        item = doc.querySelector("#basketItemCount")
        if (item == null)
            item = doc.querySelector("#ctl00_headerControl_ctl01_ctl00_hypShoppingCart")
            if item == null
                item = doc.querySelector("#ctl00_headerControl_ctl01_ctl00_A2").href;
            else
                item = item.href
        else
            item = item.parentElement.href
        ret[key] = item.split(".com")[1]
    return ret

