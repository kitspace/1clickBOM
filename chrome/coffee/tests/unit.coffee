# This file is part of 1clickBOM.
#
# 1clickBOM is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License version 3
# as published by the Free Software Foundation.
#
# 1clickBOM is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with 1clickBOM.  If not, see <http://www.gnu.org/licenses/>.


countries = get_local("/data/countries.json")

module("unit")

test "Digikey: Constructs for all countries", () ->
    for country,code of countries
        ok(new Digikey(code) instanceof RetailerInterface, country + " " + code)

test "Farnell: Constructs for all countries", () ->
    for country,code of countries
        ok(new Farnell(code) instanceof RetailerInterface, country + " " + code)

test "Mouser: Constructs for all countries", () ->
    #we need to mock the post request otherwise they will time out since they fire too quickly
    real_post = window.post
    window.post = () ->
    for country,code of countries
        ok(new Mouser(code) instanceof RetailerInterface, country + " " + code)
    window.post = real_post

test "RS: Constructs for all countries", () ->
    for country,code of countries
        ok(new RS(code) instanceof RetailerInterface, country + " " + code)

test "Newark: Constructs for all countries", () ->
    for country,code of countries
        ok(new Newark(code) instanceof RetailerInterface, country + " " + code)

test "InvalidCountryError Exists", () ->
    ok new InvalidCountryError instanceof Error

test "Digikey: InvalidCountryError Thrown", () ->
    throws () ->
        new Digikey("XX")
    , InvalidCountryError

test "Farnell: InvalidCountryError Thrown", () ->
    throws () ->
        new Farnell("XX")
    , InvalidCountryError

test "Mouser: InvalidCountryError Thrown", () ->
    throws () ->
        new Mouser("XX")
    , InvalidCountryError

test "RS: InvalidCountryError Thrown", () ->
    throws () ->
        new RS("XX")
    , InvalidCountryError

test "Newark: InvalidCountryError Thrown", () ->
    throws () ->
        new Newark("XX")
    , InvalidCountryError

test "Parser: Catches negative quantities", () ->
    {items, invalid} = window.parseTSV("test\t-1\tFarnell\t898989")
    deepEqual(items, [])
    deepEqual(invalid[0].reason, "Quantity is less than one")
