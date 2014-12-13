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
