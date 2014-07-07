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

settings_data  = get_local("data/settings.json")

class @BomManager
    constructor: (callback) ->
        @filling_carts  = false
        @emptying_carts = false
        that = this
        chrome.storage.local.get ["country", "settings"], ({country:country, settings:stored_settings}) ->
            that.interfaces = {}
            if (!country)
                country = "Other"
            for retailer_interface in [Digikey, Farnell, Mouser, RS, Newark]
                setting_values = that.lookup_setting_values(country, retailer_interface.name, stored_settings)
                that.interfaces[retailer_interface.name] = new retailer_interface(country, setting_values)
            if callback?
                callback()

    lookup_setting_values: (country, retailer, stored_settings)->
        if(stored_settings? && stored_settings[country]? && stored_settings[country][retailer]?)
            settings = settings_data[country][retailer].choices[stored_settings[country][retailer]]
        else
            settings = {}
        return settings

    getBOM: (callback) ->
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            callback(bom)

    addToBOM: (text, callback) ->
        that = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            if (!bom)
                bom = {}

            {items, invalid} = window.parseTSV(text)

            if invalid.length > 0
                chrome.runtime.sendMessage({invalid:invalid})

            for item in items
                if item.retailer not of bom
                    bom[item.retailer] = []
                bom[item.retailer].push(item)

            chrome.storage.local.set {"bom":bom}, () ->
                if callback?
                    callback(that)

    fillCarts: (callback)->
        @filling_carts = true
        that = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            count = Object.keys(bom).length
            for retailer of bom
                that.interfaces[retailer].addItems bom[retailer], (result, interface) ->
                    count--
                    if count == 0
                        if callback?
                            callback()
                        that.filling_carts = false


    fillCart: (retailer, callback)->
        that = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            that.interfaces[retailer].addItems(bom[retailer], callback)

    emptyCarts: (callback)->
        @emptying_carts = true
        that = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            count = Object.keys(bom).length
            for retailer of bom
                that.emptyCart retailer, (result, interface) ->
                    count--
                    if count == 0
                        if callback?
                            callback()
                        that.emptying_carts = false

    emptyCart: (retailer, callback)->
        this.interfaces[retailer].clearCart(callback)

    openCarts: ()->
        that = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            for retailer of bom
                that.openCart(retailer)

    openCart: (retailer)->
        this.interfaces[retailer].openCartTab()
