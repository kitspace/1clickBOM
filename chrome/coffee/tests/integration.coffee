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

asyncTest "Clear All", () ->
    stop(digikey_locations.length - 1)
    for l in digikey_locations
        r = new Digikey(l)
        r.clearCart (result, that) ->
            deepEqual(result.success, true)
            start()

asyncTest "Add items", () ->
    items = [{"part":"754-1173-1-ND", "quantity":2, "comment":"test"}]
    stop(digikey_locations.length - 1)
    for l in digikey_locations
        r = new Digikey(l)
        r.addItems items, (result, that) ->
            deepEqual(result.success, true, that.country)
            start()

asyncTest "Add items fails", () ->
    items = [{"part":"fail", "quantity":2, "comment":"test"}, {"part":"754-1173-1-ND", "quantity":2, "comment":"test"}]
    stop(digikey_locations.length - 1)
    for l in digikey_locations
        r = new Digikey(l)
        r.addItems items, (result, that) ->
            deepEqual(result.success, false, that.country)
            deepEqual(result.fails, [items[0]], that.country)
            start()

asyncTest "Add items fails 2", () ->
    items = [{"part":"754-1173-1-ND", "quantity":-1, "comment":"test"}, {"part":"754-1173-1-ND", "quantity":2, "comment":"test"}]
    stop(digikey_locations.length - 1)
    for l in digikey_locations
        r = new Digikey(l)
        r.addItems items, (result, that) ->
            deepEqual(result.success, false, that.country)
            deepEqual(result.fails, [items[0]], that.country)
            start()

module("Farnell")

#these Farnall tests can be a bit iffy, we only test a few locations as there is a
#danger the servers start refusing requests. also, if any fail, try clearing
#all the farnell and element14 cookies and trying again
#XXX also having some issues with CN location

farnell_locations = ["UK", "AU", "EE", "FR", "TH", "International"]

asyncTest "Clear All", () ->
    stop(farnell_locations.length - 1)
    for l in farnell_locations
        r = new Farnell(l)
        r.clearCart (result, that) ->
            deepEqual(result.success, true)
            start()

asyncTest "Add items", () ->
    items = [{"part":"2250472", "quantity":2, "comment":"test"}]
    stop(farnell_locations.length - 1)
    for l in farnell_locations
        r = new Farnell(l)
        r.addItems items, (result, that) ->
            deepEqual(result.success, true, that.country)
            start()

asyncTest "Add items fails", () ->
    items = [{"part":"fail", "quantity":2, "comment":"test"}, {"part":"2250472", "quantity":2, "comment":"test"}]
    stop(farnell_locations.length - 1)
    for l in farnell_locations
        r = new Farnell(l)
        r.addItems items, (result, that) ->
            deepEqual(result.success, false, that.country)
            deepEqual(result.fails, [items[0]], that.country)
            start()

asyncTest "Add items individually via microCart", () ->
    items = [{"part":"2250472", "quantity":2, "comment":"test"}]
    stop(farnell_locations.length - 1)
    for l in farnell_locations
        r = new Farnell(l)
        r._add_items_individually_via_micro_cart items, (result, that) ->
            deepEqual(result.no_item_comments, true, that.country)
            deepEqual(result.success, true, that.country)
            start()

asyncTest "Add items individually via microCart fails", () ->
    items = [{"part":"fail", "quantity":2, "comment":"test"}, {"part":"2250472", "quantity":2, "comment":"test"}]
    stop(farnell_locations.length - 1)
    for l in farnell_locations
        r = new Farnell(l)
        r._add_items_individually_via_micro_cart items, (result, that) ->
            deepEqual(result.no_item_comments, true, that.country)
            deepEqual(result.success, false, that.country)
            deepEqual(result.fails, [items[0]], that.country)
            start()

module("Mouser")

# Mouser's site is unified, changing the basket somewhere will change the
# basket everywhere. 
# TODO would be good to find a way to test more locations, tried doing it like
# the other retailers but the locations can interefer with each other

asyncTest "Clear All", () ->
    r = new Mouser("AU")
    r.clearCart (result, that) ->
        deepEqual(result.success, true)
        start()

asyncTest "Add items fails but adds again", () ->
    items = [{"part":"fail","quantity":2, "comment":"test"},{"part":"607-GALILEO","quantity":2, "comment":"test"}]
    r = new Mouser("AU")
    r.addItems items, (result, that) ->
        deepEqual(result.success, false, that.country)
        deepEqual(result.fails, [items[0]], that.country)
        items = [{"part":"607-GALILEO","quantity":2, "comment":"test"}]
        that.addItems items, (result, that) ->
            #the order here is important as we want to make sure the "errors" were cleared after the failed add
            deepEqual(result.success, true, that.country)
            start()

module("RS")

rs_locations_online = [ "AT", "AU", "BE", "CH", "CN", "CZ" , "DE", "DK", "ES",
    "FR", "HK", "HU" , "IE", "IT", "JP", "KR", "MY", "NL", "NO", "NZ", "PH",
    "PL", "PT", "SE", "SG", "TH", "TW", "UK", "ZA" ]

rs_locations_delivers = ["AE", "AZ", "CL", "CY", "EE", "FI", "GR", "HR", "IL", "IN", "LT", "LV", "LY", "MT", "MX", "RO", "RU", "SA", "TR", "UA", "AR", "US"]

rs_locations = rs_locations_delivers

asyncTest "Clear all, Add items, Add Items fails and Add again", () ->
    stop(rs_locations.length - 1)
    for l in rs_locations
        r = new RS(l)
        r.clearCart (result, that) ->
            deepEqual(result.success, true, "1:" + that.country)
            items = [{"part":"264-7881","quantity":2, "comment":"test"}]
            that.addItems items, (result, that2) ->
                deepEqual(result.success, true, "2:" + that2.country)
                items = [{"part":"fail","quantity":2, "comment":"test"}]
                that2.addItems items, (result, that3) ->
                    deepEqual(result.success, false, "3:"+ that3.country)
                    items = [{"part":"264-7881","quantity":2, "comment":"test"}]
                    that3.addItems items, (result, that4) ->
                        deepEqual(result.success, true, "4:" + that4.country)
                        start()

asyncTest "Clear Errors", () ->
    r = new RS("AZ")
    r._clear_errors_rs_delivers (result, that) ->
        deepEqual(result.success, false)
        start()
