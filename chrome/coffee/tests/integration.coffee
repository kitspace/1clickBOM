xhr = new XMLHttpRequest()
xhr.open "GET", chrome.extension.getURL("/data/digikey_international.json"), false
xhr.send()
if xhr.status == 200
    @data = JSON.parse xhr.responseText

#test "Clear All", () ->
#    for key of window.data.sites
#        console.log "Clear All " + key
#        d = new Digikey(key)
#        d.clearCart()
#    ok true

test "Add Items", () ->
    #for key of window.data.sites
    #    console.log "Adding item to Digikey " + key
    #    d = new Digikey(key)
    #    items = [{"part":"754-1173-1-ND","quantity":2, "comment":"test"}]
    #    d.addItems(items)
    d = new Digikey("BE")
    items = [
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"}
    ]
    d.addItems(items)
    ok true

#test "Read Cart", () ->
#    for key of window.data.sites
#        d = new Digikey(key)
#        cart = d.readCart()
#        strictEqual(cart.total, 0)
