test "clear all", () ->
    xhr = new XMLHttpRequest()
    xhr.open "GET", chrome.extension.getURL("/data/digikey_international.json"), false
    xhr.send()
    if xhr.status == 200
        data = JSON.parse xhr.responseText
    for key of data.sites
        d = new Digikey(key)
        d.clearCart()
    ok true
#test "usefull error on wrong country", () ->

