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

module("Digikey")

# we only test a few locations or else we start getting 403: forbidden
digikey_locations = ["UK", "AT", "IL", "US", "AU"]

test "Digikey: Clear All", () ->
    try
        for key of window.digikey_data.lookup
            console.log "Digikey: Clearing all"
            r = new Digikey(key)
            r.clearCart()
    catch error
        ok false
        throw error
    ok true

asyncTest "Digikey: Add items", () ->
    items = [{"part":"754-1173-1-ND", "quantity":2, "comment":"test"}]
    stop(digikey_locations.length - 1)
    for l in digikey_locations
        r = new Digikey(l)
        r.addItems items, (result, that) ->
            deepEqual(result.success, true, that.country)
            start()

asyncTest "Digikey: Add items fails", () ->
    items = [{"part":"fail", "quantity":2, "comment":"test"}, {"part":"754-1173-1-ND", "quantity":2, "comment":"test"}]
    stop(digikey_locations.length - 1)
    for l in digikey_locations
        r = new Digikey(l)
        r.addItems items, (result, that) ->
            deepEqual(result.success, false, that.country)
            deepEqual(result.fails, [items[0]], that.country)
            start()

asyncTest "Digikey: Add items fails 2", () ->
    items = [{"part":"754-1173-1-ND", "quantity":-1, "comment":"test"}, {"part":"754-1173-1-ND", "quantity":2, "comment":"test"}]
    stop(digikey_locations.length - 1)
    for l in digikey_locations
        r = new Digikey(l)
        r.addItems items, (result, that) ->
            deepEqual(result.success, false, that.country)
            deepEqual(result.fails, [items[0]], that.country)
            start()

module("Farnell")

test "Farnell: Clear All", () ->
    try
        for key of window.farnell_data.lookup
            console.log "Farnell: Clearing all"
            r = new Farnell(key)
            r.clearCart()
    catch error
        ok false
        throw error
    ok true

#these Farnall tests can be a bit iffy, we only test a few locations as there is a
#danger the servers start refusing requests. also, if any fail, try clearing
#all the farnell and element14 cookies and trying again
#XXX also having some issues with CN location

farnell_locations = ["UK", "AU", "EE", "FR", "TH", "International"]

asyncTest "Farnell: Add items", () ->
    items = [{"part":"2250472", "quantity":2, "comment":"test"}]
    stop(farnell_locations.length - 1)
    for l in farnell_locations
        r = new Farnell(l)
        r.addItems items, (result, that) ->
            deepEqual(result.success, true, that.country)
            start()

asyncTest "Farnell: Add items fails", () ->
    items = [{"part":"fail", "quantity":2, "comment":"test"}, {"part":"2250472", "quantity":2, "comment":"test"}]
    stop(farnell_locations.length - 1)
    for l in farnell_locations
        r = new Farnell(l)
        r.addItems items, (result, that) ->
            deepEqual(result.success, false, that.country)
            deepEqual(result.fails, [items[0]], that.country)
            start()

asyncTest "Farnell: Add items individually via microCart", () ->
    items = [{"part":"2250472", "quantity":2, "comment":"test"}]
    stop(farnell_locations.length - 1)
    for l in farnell_locations
        r = new Farnell(l)
        r._add_items_individually_via_micro_cart items, (result, that) ->
            deepEqual(result.no_item_comments, true, that.country)
            deepEqual(result.success, true, that.country)
            start()

asyncTest "Farnell: Add items individually via microCart fails", () ->
    items = [{"part":"fail", "quantity":2, "comment":"test"}, {"part":"2250472", "quantity":2, "comment":"test"}]
    stop(farnell_locations.length - 1)
    for l in farnell_locations
        r = new Farnell(l)
        r._add_items_individually_via_micro_cart items, (result, that) ->
            deepEqual(result.no_item_comments, true, that.country)
            deepEqual(result.success, false, that.country)
            deepEqual(result.fails, [items[0]], that.country)
            start()

module("RS")

asyncTest "RS: Add items", () ->
    items = [{"part":"505-1441","quantity":2, "comment":"test"}]
    r = new RS("AT")
    r.addItems items, (result, that) ->
        deepEqual(result.success,true)
        start()

asyncTest "RS: Add items fails", () ->
    items = [{"part":"fail","quantity":2, "comment":"test"}]
    r = new RS("AT")
    r.addItems items, (result, that) ->
        deepEqual(result.success,false)
        start()

asyncTest "RS: Clear All", () ->
    r = new RS("AT")
    r.clearCart (result, that) ->
        deepEqual(result.success, true)
        start()

module("Mouser")
# Mouser's site is unified, changing the basket somewhere will change the basket everywhere
asyncTest "Mouser: Add items fails", () ->
    items = [{"part":"fail","quantity":2, "comment":"test"},{"part":"607-GALILEO","quantity":2, "comment":"test"}]
    console.log "Mouser: Adding items"
    r = new Mouser("CN")
    r.addItems items, (result, that) ->
        deepEqual(result.success, false)
        deepEqual(result.fails, [items[0]])
        start()

#the order here is important as we want to make sure the "errors" were cleared after the failed add
asyncTest "Mouser: Add items", () ->
    items = [{"part":"607-GALILEO","quantity":2, "comment":"test"}]
    console.log "Mouser: Adding items"
    r = new Mouser("CN")
    r.addItems items, (result, that) ->
        deepEqual(result.success, true)
        start()
