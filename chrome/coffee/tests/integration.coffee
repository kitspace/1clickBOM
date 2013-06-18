xhr = new XMLHttpRequest()
xhr.open "GET", chrome.extension.getURL("/data/digikey_international.json"), false
xhr.send()
if xhr.status == 200
    @data = JSON.parse xhr.responseText

test "Clear All", () ->
    for key of window.data.sites
        d = new Digikey(key)
        d.clearCart()
    ok true
