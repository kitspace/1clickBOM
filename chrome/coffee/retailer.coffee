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
    constructor: (name, country_code, data_path) ->
        xhr = new XMLHttpRequest()
        xhr.open "GET", chrome.extension.getURL(data_path), false
        xhr.send()
        if xhr.status == 200
            data = JSON.parse xhr.responseText
        country_code_lookedup = data.lookup[country_code]
        if !country_code_lookedup
            error = new InvalidCountryError()
            error.message += " \"" + country_code + "\" given to " + name
            throw error

        if typeof(data.carts) == "string"
            @cart = data.carts
        else
            @cart = data.carts[country_code_lookedup]

        if typeof(data.additems) == "string"
            @additem = data.additems
        else
            @additem = data.additems[country_code_lookedup]

        @site = data.sites[country_code_lookedup]
        @name = name + " " + country_code_lookedup

    clearCart: (ref)->
        console.log ref.name + " cart cleared."

    refreshCartTabs: (site = @site, cart = @cart) ->
        #we reload any tabs with the cart URL but the path is case insensitive so we use a regex 
        #we update the matching tabs to the cart URL instead of using tabs.refresh so we don't 
        #re-pass any parameters to the cart
        re = new RegExp(cart, "i")
        chrome.tabs.query {"url":"*" + site + "/*"}, (tabs)->
            for tab in tabs
                if (tab.url.match(re))
                    protocol = tab.url.split("://")[0]
                    chrome.tabs.update tab.id, {"url": protocol + site + cart}


class @InvalidCountryError extends Error
    constructor: ->
        @name = "InvalidCountryError"
        @message = "Invalid country-code"

