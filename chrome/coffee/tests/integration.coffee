#    This file is part of 1clickBOM.
#
#    1clickBOM is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License version 3
#    as published by the Free Software Foundation.
#
#    1clickBOM is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with 1clickBOM.  If not, see <http://www.gnu.org/licenses/>.

@digikey_data = get_local("/data/digikey_international.json")
@farnell_data = get_local("/data/farnell_international.json")
@mouser_data  = get_local("/data/mouser_international.json")

test "Digikey: Clear All", () ->
    try
        for key of window.digikey_data.sites
            console.log "Digikey: Clearing all in:" + key
            d = new Digikey(key)
            d.clearCart()
    catch error
        ok false
        throw error
    ok true

asyncTest "Digikey: Add items", () ->
    items = [{"part":"754-1173-1-ND", "quantity":2, "comment":"test"}]
    stop(Object.keys(window.digikey_data.sites).length-1)
    for key of window.digikey_data.sites
        console.log("Digikey: Adding items")
        d = new Digikey(key)
        d.addItems items, (request, that) ->
            deepEqual(request.success, true, that.country)
            start()

asyncTest "Digikey: Add items fails", () ->
    items = [{"part":"fail", "quantity":2, "comment":"test"}, {"part":"754-1173-1-ND", "quantity":2, "comment":"test"}]
    stop(Object.keys(window.digikey_data.sites).length-1)
    for key of window.digikey_data.sites
        console.log("Digikey: Adding items")
        d = new Digikey(key)
        d.addItems items, (request, that) ->
            deepEqual(request.success, false, that.country)
            deepEqual(request.fails, [items[0]], that.country)
            start()

asyncTest "Digikey: Add items fails 2", () ->
    items = [{"part":"754-1173-1-ND", "quantity":-1, "comment":"test"}, {"part":"754-1173-1-ND", "quantity":2, "comment":"test"}]
    stop(Object.keys(window.digikey_data.sites).length-1)
    for key of window.digikey_data.sites
        console.log("Digikey: Adding items (2)")
        d = new Digikey(key)
        d.addItems items, (request, that) ->
            deepEqual(request.success, false, that.country)
            deepEqual(request.fails, [items[0]], that.country)
            start()


test "Farnell: Clear All", () ->
    try
        for key of window.farnell_data.sites
            console.log "Farnell: Clearing all in " + key
            d = new Farnell(key)
            d.clearCart()
    catch error
        ok false
        throw error
    ok true

asyncTest "Farnell: Add items", () ->
    #this test can be a bit iffy,
    #if it fails, try clearing all the farnell and element14 cookies and trying again
    stop(Object.keys(window.farnell_data.sites).length-1)
    for key of window.farnell_data.sites
        console.log "Farnell: Adding items"
        d = new Farnell(key)
        items = [{"part":"2250472", "quantity":2, "comment":"test"}]
        d.addItems items, (request, country) ->
            deepEqual(request.success, true, country)
            start()

asyncTest "Farnell: Add items fails", () ->
    stop(Object.keys(window.farnell_data.sites).length-1)
    for key of window.farnell_data.sites
        d = new Farnell(key)
        items = [{"part":"fail", "quantity":2, "comment":"test"}]
        d.addItems items, (request, country) ->
            deepEqual(request.success, false, country)
            start()

test "Mouser: Add Items", () ->
    try
        # Mouser's site is unified, changing the basket anywhere will change the basket everywhere else
        console.log "Mouser: Adding item in LK"
        d = new Mouser("LK")
        items = [{"part":"607-GALILEO","quantity":2, "comment":"test"}]
        d.addItems(items)
        #China is separate
        console.log "Mouser: Adding item in CN"
        c = new Mouser("CN")
        c.addItems(items)
    catch error
        ok false
        throw error
    ok true

asyncTest "Paste BOM", 1, () ->
    chrome.storage.local.remove("bom")
    chrome.storage.local.get "country", (obj) ->
        stored = obj.country
        chrome.storage.local.set {country: "UK"}, () ->

            test_bom = get_local("/data/example.json")

            copybox    = document.createElement("textarea")
            pastebox   = document.createElement("textarea")
            restorebox = document.createElement("textarea")

            listener = (changes, namespace) ->
                if (namespace == "local" && changes.bom)
                    chrome.storage.local.get "bom", ({bom:bom}) ->
                        deepEqual(bom, test_bom)
                        restorebox.select()
                        document.execCommand("copy")
                        document.body.removeChild(copybox)
                        document.body.removeChild(pastebox)
                        document.body.removeChild(restorebox)
                        #chrome.storage.local.remove(["bom", "country"])
                        chrome.storage.onChanged.removeListener listener
                        chrome.storage.local.set {country:stored}, () ->
                        start()


            chrome.storage.onChanged.addListener listener

            copybox.id    = "copybox"
            pastebox.id   = "pastebox"
            restorebox.id = "restorebox"

            xhr = new XMLHttpRequest()
            xhr.open "GET", chrome.extension.getURL("/data/example.tsv"), false
            xhr.send()
            copybox.value = xhr.responseText

            document.body.appendChild(copybox)
            document.body.appendChild(pastebox)
            document.body.appendChild(restorebox)

            restorebox.select()
            document.execCommand("paste")
            copybox.select()
            document.execCommand("copy")

            paste_action()

