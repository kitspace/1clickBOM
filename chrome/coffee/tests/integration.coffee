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

@digikey_data = get_local("/data/digikey.json")
@farnell_data = get_local("/data/farnell.json")
@mouser_data  = get_local("/data/mouser.json")

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

module("Farnell")

farnell_locations_all = Object.keys(farnell_data.sites)
farnell_locations = []

# these sites have issues with cookies being set across countries and won't
# pass the test reliably
for l in farnell_locations_all
    if l not in [ "AU", "MY", "PH", "TW", "NZ", "KR"
                , "CN", "TH", "IN", "HK", "SG", "International"]
        farnell_locations.push(l)

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

rs_locations_delivers = ["AE", "AZ", "CL", "CY", "EE", "FI", "GR", "HR", "IL",
    "IN", "LT", "LV", "LY", "MT", "MX", "RO", "RU", "SA", "TR", "UA", "AR",
    "US"]


rs_locations = rs_locations_online.concat(rs_locations_delivers)

asyncTest "rsdelivers: Add items fails but adds again", () ->
    stop(rs_locations_delivers.length - 1)
    for l in rs_locations_delivers
        r = new RS(l)
        items = [
                  {"part":"264-7881","quantity":2, "comment":"test"}
                , {"part":"fail","quantity":2, "comment":"test"}
                ]
        r.addItems items, (result, that) ->
            expected_fails = [{"part":"fail","quantity":2, "comment":"test"}]
            deepEqual(result.success, false, "1:"+ that.country)
            deepEqual(result.fails, expected_fails,"2:" + that.country)
            items = [{"part":"264-7881","quantity":2, "comment":"test"}]
            that.addItems items, (result, that2) ->
                deepEqual(result.success, true, "3:" + that2.country)
                start()

asyncTest "rs-online: Add items fails but adds again", () ->
    stop(rs_locations_online.length - 1)
    for l in rs_locations_online
        r = new RS(l)
        items = [
                  {"part":"264-7881","quantity":2, "comment":"test"}
                , {"part":"fail","quantity":2, "comment":"test"}
                ]
        r.addItems items, (result, that) ->
            expected_fails = [{"part":"fail","quantity":2, "comment":"test"}]
            deepEqual(result.success, false, "1:"+ that.country)
            deepEqual(result.fails, expected_fails,"2:" + that.country)
            items = [{"part":"264-7881","quantity":2, "comment":"test"}]
            that.addItems items, (result, that2) ->
                deepEqual(result.success, true, "3:" + that2.country)
                start()

asyncTest "Clear all", () ->
    stop(rs_locations.length - 1)
    for l in rs_locations
        r = new RS(l)
        r.clearCart (result, that) ->
            deepEqual(result.success, true, "1:" + that.country)
            start()

module("Newark")

asyncTest "Add items fails, add items, clear all", () ->
	r = new Newark("US")
	items = [
		{"part":"98W0461","quantity":2, "comment":"test"}
			, {"part":"fail","quantity":2, "comment":"test"}
			, {"part":"fail2","quantity":2, "comment":"test"}
	]
	r.addItems items, (result1, that) ->
		deepEqual(result1.success, false)
		deepEqual(result1.fails, [items[2], items[1]])
		items = [
			{"part":"98W0461","quantity":2, "comment":"test"}
		]
		that.addItems items, (result2, that) ->
			deepEqual(result2.success, true)
			that.clearCart (result3, that) ->
				deepEqual(result3.success, true)
				start()

asyncTest "Add items", () ->
	r = new Newark("US")
	items = [
	          {"part":"98W0461","quantity":2, "comment":"test"}
	        ]
	r.addItems items, (result) ->
		deepEqual(result.success, true)
		start()

