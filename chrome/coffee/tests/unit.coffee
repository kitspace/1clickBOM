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

test "Digikey: Constructs and is RetailerInterface", () ->
    ok new Digikey("AT") instanceof RetailerInterface

test "Farnell: Constructs and is RetailerInterface", () ->
    ok new Farnell("AT") instanceof RetailerInterface

test "Mouser: Constructs and is RetailerInterface", () ->
    ok new Mouser("AT") instanceof RetailerInterface

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

