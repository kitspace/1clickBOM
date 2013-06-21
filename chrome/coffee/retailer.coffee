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

class @Retailer
    constructor: (name, country) ->
        @name = name + " " + country

    clearCart: (ref)->
        console.log ref.name + " cart cleared."

class @InvalidCountryError extends Error
    constructor: ->
        @name = "InvalidCountryError"
        @message = "Invalid country-code"

