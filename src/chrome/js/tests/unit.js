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

const {RetailerInterface, InvalidCountryError} = require('./retailer_interface')
const {Digikey} = require('./digikey')
const {Farnell} = require('./farnell')
const {Mouser} = require('./mouser')
const {RS} = require('./rs')
const {Newark} = require('./newark')
const qunit = require('./qunit-1.11.0')
const {browser} = require('./browser')

const {module} = qunit
const {test} = qunit
const {ok} = qunit
const {throws} = qunit
const {deepEqual} = qunit

const countries = require('./data/countries.json')

module('unit')

test('Digikey: Constructs for all countries', () =>
    (() => {
        const result = []
        for (const country in countries) {
            const code = countries[country]
            result.push(
                ok(
                    new Digikey(code, {}, function() {}) instanceof
                        RetailerInterface,
                    country + ' ' + code
                )
            )
        }
        return result
    })())

test('Farnell: Constructs for all countries', () =>
    (() => {
        const result = []
        for (const country in countries) {
            const code = countries[country]
            result.push(
                ok(
                    new Farnell(code, {}, function() {}) instanceof
                        RetailerInterface,
                    country + ' ' + code
                )
            )
        }
        return result
    })())

test('Mouser: Constructs for all countries', () =>
    //this test might time-out because it sends a lot of requests
    (() => {
        const result = []
        for (const country in countries) {
            const code = countries[country]
            result.push(
                ok(
                    new Mouser(code) instanceof RetailerInterface,
                    country + ' ' + code
                )
            )
        }
        return result
    })())

test('RS: Constructs for all countries', () =>
    (() => {
        const result = []
        for (const country in countries) {
            const code = countries[country]
            result.push(
                ok(
                    new RS(code) instanceof RetailerInterface,
                    country + ' ' + code
                )
            )
        }
        return result
    })())

test('Newark: Constructs for all countries', () =>
    (() => {
        const result = []
        for (const country in countries) {
            const code = countries[country]
            result.push(
                ok(
                    new Newark(code, {}, function() {}) instanceof
                        RetailerInterface,
                    country + ' ' + code
                )
            )
        }
        return result
    })())

test('InvalidCountryError Exists', () =>
    ok(new InvalidCountryError() instanceof Error))

test('Digikey: InvalidCountryError Thrown', () => {
    throws(() => new Digikey('XX', {}, function() {}))
})

test('Farnell: InvalidCountryError Thrown', () => {
    throws(() => new Farnell('XX', {}, function() {}))
})

test('Mouser: InvalidCountryError Thrown', () => {
    throws(() => new Mouser('XX', {}, function() {}))
})

test('RS: InvalidCountryError Thrown', () => {
    throws(() => new RS('XX', {}, function() {}))
})

test('Newark: InvalidCountryError Thrown', () => {
    throws(() => new Newark('XX', {}, function() {}))
})
