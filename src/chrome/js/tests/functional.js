// The contents of this file are subject to the Common Public Attribution
// License Version 1.0 (the “License”); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
// License Version 1.1 but Sections 14 and 15 have been added to cover use of
// software over a computer network and provide for limited attribution for the
// Original Developer. In addition, Exhibit A has been modified to be consistent
// with Exhibit B.
//
// Software distributed under the License is distributed on an
// "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
// the License for the specific language governing rights and limitations under
// the License.
//
// The Original Code is 1clickBOM.
//
// The Original Developer is the Initial Developer. The Original Developer of
// the Original Code is Kaspar Emanuel.

const { browser } = require('./browser')
const { Digikey } = require('./digikey')
const { Farnell } = require('./farnell')
const { Mouser }  = require('./mouser')
const { RS }      = require('./rs')
const { Newark }  = require('./newark')
const qunit       = require('./qunit-1.11.0')
const octopart    = require('./octopart')

const { retailer_list } = require('1-click-bom').lineData

let { module }    = qunit
let { asyncTest } = qunit
let { stop }      = qunit
let { start }     = qunit
let { deepEqual } = qunit
let { ok } = qunit

let digikey_data = browser.getLocal('data/digikey.json')
let farnell_data = browser.getLocal('data/farnell.json')
let mouser_data  = browser.getLocal('data/mouser.json')

module('Digikey')

// we only test a few locations or else we start getting 403: forbidden
let digikey_locations = ['UK', 'AT', 'IL', 'US', 'AU']

asyncTest('Clear All', function() {
    let r
    stop(digikey_locations.length - 1)
    return digikey_locations.map((l) =>
        (r = new Digikey(l),
        r.clearCart(function(result, that) {
            deepEqual(result.success, true)
            return start()
        })))
})

asyncTest('Add lines', function() {
    let r
    let lines = [
        {'part':'754-1173-1-ND', 'quantity':2, 'reference':'test'},
        {'part':'MAX2606EUT+TCT-ND', 'quantity':2, 'reference':'test'}
    ]
    stop(digikey_locations.length - 1)
    return digikey_locations.map((l) =>
        (r = new Digikey(l),
        r.addLines(lines, function(result, that) {
            deepEqual(result.success, true, that.country)
            return start()
        }
        )))
})

asyncTest('Add lines fails', function() {
    let r
    let lines = [
        {'part':'fail', 'quantity':2, 'reference':'test'},
        {'part':'754-1173-1-ND', 'quantity':2, 'reference':'test'}
    ]
    stop(digikey_locations.length - 1)
    return digikey_locations.map((l) =>
        (r = new Digikey(l),
        r.addLines(lines, function(result, that) {
            deepEqual(result.success, false, that.country)
            deepEqual(result.fails, [lines[0]], that.country)
            return start()
        }
        )))
})

module('Farnell')

let farnell_locations = Object.keys(farnell_data.sites)

asyncTest('Clear All', function() {
    let r
    stop(farnell_locations.length - 1)
    return farnell_locations.map((l) =>
        r = new Farnell(l, {}, that =>
            that.clearCart(function(result, that) {
                deepEqual(result.success, true)
                return start()
            })

        ))
})

asyncTest('Add lines', function() {
    let r
    let lines = [{'part':'2250472', 'quantity':2, 'reference':'test'}]
    stop(farnell_locations.length - 1)
    return farnell_locations.map((l) =>
        r = new Farnell(l, {}, that =>
            that.addLines(lines, function(result, that) {
                deepEqual(result.success, true, that.country)
                return start()
            }
            )

        ))
})

asyncTest('Add lines fails', function() {
    let r
    let lines = [
        {'part':'fail', 'quantity':2, 'reference':'test'},
        {'part':'2250472', 'quantity':2, 'reference':'test'}
    ]
    stop(farnell_locations.length - 1)
    return farnell_locations.map((l) =>
        r = new Farnell(l, {}, that =>
            that.addLines(lines, function(result, that) {
                deepEqual(result.success, false, that.country)
                deepEqual(result.fails, [lines[0]], that.country)
                return start()
            }
            )

        ))
})

module('Mouser')

// Mouser's site is unified, changing the basket somewhere will change the
// basket everywhere.
// TODO would be good to find a way to test more locations, tried doing it like
// the other retailers but the locations can interfere with each other

asyncTest('Clear All', function() {
    let r = new Mouser('AU')
    return r.clearCart(function(result, that) {
        deepEqual(result.success, true)
        return start()
    })
})

asyncTest('Add lines fails but adds again', function() {
    let lines = [
        {'part':'fail','quantity':2, 'reference':'test'},
        {'part':'607-GALILEO2','quantity':2, 'reference':'test'},
        {'part':'fail2','quantity':2, 'reference':'test'},
    ]
    let r = new Mouser('UK')
    return r.addLines(lines, function(result, that) {
        deepEqual(result.success, false, that.country)
        deepEqual(result.fails, [lines[0], lines[2]], that.country)
        lines = [{'part':'607-GALILEO2','quantity':2, 'reference':'test'}]
        return that.addLines(lines, function(result, that) {
            //the order here is important as we want to make sure the 'errors'
            //were cleared after the failed add
            deepEqual(result.success, true, that.country)
            return start()
        })
    })
})

module('RS')

let rs_locations_online = [ 'AT', 'AU', 'BE', 'CH', 'CN', 'CZ' , 'DE', 'DK', 'ES',
    'FR', 'HK', 'HU' , 'IE', 'IT', 'JP', 'KR', 'MY', 'NL', 'NO', 'NZ', 'PH',
    'PL', 'PT', 'SE', 'SG', 'TH', 'TW', 'UK', 'ZA' ]

let rs_locations_delivers = ['AE', 'AZ', 'CL', 'CY', 'EE', 'FI', 'GR', 'HR', 'IL',
    'IN', 'LT', 'LV', 'LY', 'MT', 'MX', 'RO', 'RU', 'SA', 'TR', 'UA', 'AR',
    'US']


let rs_locations = rs_locations_online.concat(rs_locations_delivers)

asyncTest('Clear all', function() {
    let r
    stop(rs_locations.length - 1)
    return rs_locations.map((l) => {
        r = new RS(l),
        r.clearCart(function(result, that) {
            deepEqual(result.success, true, `1:${that.country}`)
            return start()
        })
    })
})

asyncTest('Add lines fails but adds again', function() {
    let r
    let lines
    stop(rs_locations.length - 1)
    return rs_locations.map((l) => {
        r = new RS(l)
        lines = [
            {'part':'264-7881','quantity':2, 'reference':'test'},
            {'part':'fail1','quantity':2, 'reference':'test'},
            {'part':'fail2','quantity':2, 'reference':'test'}
        ]
        r.addLines(lines, function(result, that) {
            let expected_fails = [
                {'part':'fail1','quantity':2, 'reference':'test'},
                {'part':'fail2','quantity':2, 'reference':'test'}
            ]
            deepEqual(result.success, false, `1:${that.country}`)
            deepEqual(result.fails, expected_fails,`2:${that.country}`)
            lines = [{'part':'264-7881','quantity':2, 'reference':'test'}]
            return that.addLines(lines, function(result, that2) {
                deepEqual(result.success, true, `3:${that2.country}`)
                return start()
            }
            )
        })
    })
})

module('Newark')

asyncTest('Add lines fails, add lines, clear all', function() {
	let r
	return r = new Newark('US', {}, function() {
            let lines = [
                {'part':'98W0461','quantity':2, 'reference':'test'},
                {'part':'fail'   ,'quantity':2, 'reference':'test'},
                {'part':'fail2'  ,'quantity':2, 'reference':'test'}
            ]
            return r.addLines(lines, function(result1, that) {
                    deepEqual(result1.success, false)
                    deepEqual(result1.fails, [lines[1], lines[2]])
                    lines = [
                        {'part':'98W0461','quantity':2, 'reference':'test'}
                    ]
                    return that.addLines(lines, function(result2, that) {
                            deepEqual(result2.success, true)
                            return that.clearCart(function(result3, that) {
                                    deepEqual(result3.success, true)
                                    return start()
                            })
                        }
                    )
                }
            )
        }
	)
}
)

asyncTest('Add lines', function() {
	let r
	return r = new Newark('US', {}, function() {
            let lines = [
                {'part':'98W0461','quantity':2, 'reference':'test'}
            ]
            return r.addLines(lines, function(result) {
                    deepEqual(result.success, true)
                    return start()
                }
            )
        })
})

module('Octopart')

asyncTest('Auto complete fails', function() {
    let query = 'wizzooooabbbaa'
    octopart.search(query, retailer_list).then(new_lines => {
        retailer_list.forEach(name => {
            ok(!new_lines.retailers[name])
        })
        start()
    })
})

asyncTest('Auto complete', function() {
    let query = 'IRF7309PBF'
    octopart.search(query, retailer_list).then(new_lines => {
        retailer_list.forEach(name => {
            ok(new_lines.retailers[name])
        })
        start()
    })
})
