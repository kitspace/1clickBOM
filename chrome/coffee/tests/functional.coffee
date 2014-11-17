# The contents of this file are subject to the Common Public Attribution
# License Version 1.0 (the “License”); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
# License Version 1.1 but Sections 14 and 15 have been added to cover use of
# software over a computer network and provide for limited attribution for the
# Original Developer. In addition, Exhibit A has been modified to be consistent
# with Exhibit B.
#
# Software distributed under the License is distributed on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations under
# the License.
#
# The Original Code is 1clickBOM.
#
# The Original Developer is the Initial Developer. The Original Developer of
# the Original Code is Kaspar Emanuel.

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
    if l not in [ "AU", "MY", "PH", "TW", "NZ", "KR" , "CN"
                , "TH", "IN", "SG"
                , "FR", "IL", "International", "TR"
                ]
        farnell_locations.push(l)

asyncTest "Clear All", () ->
    stop(farnell_locations_all.length - 1)
    for l in farnell_locations_all
        r = new Farnell l, {}, (that) ->
            that.clearCart (result, that) ->
                deepEqual(result.success, true)
                start()

asyncTest "Add items", () ->
    items = [{"part":"2250472", "quantity":2, "comment":"test"}]
    stop(farnell_locations.length - 1)
    for l in farnell_locations
        r = new Farnell l, {}, (that) ->
            that.addItems items, (result, that) ->
                deepEqual(result.success, true, that.country)
                start()

asyncTest "Add items fails", () ->
    items = [{"part":"fail", "quantity":2, "comment":"test"}, {"part":"2250472", "quantity":2, "comment":"test"}]
    stop(farnell_locations.length - 1)
    for l in farnell_locations
        r = new Farnell l, {}, (that) ->
            that.addItems items, (result, that) ->
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

asyncTest "Clear all", () ->
    stop(rs_locations.length - 1)
    for l in rs_locations
        r = new RS(l)
        r.clearCart (result, that) ->
            deepEqual(result.success, true, "1:" + that.country)
            start()

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
    for l in rs_locations
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


module("Newark")

asyncTest "Add items fails, add items, clear all", () ->
	r = new Newark("US")
	items = [
          {"part":"98W0461","quantity":2, "comment":"test"}
		, {"part":"fail"   ,"quantity":2, "comment":"test"}
		, {"part":"fail2"  ,"quantity":2, "comment":"test"}
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

