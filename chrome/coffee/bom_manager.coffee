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

settings_data  = @get_local("/data/settings.json")

class @BomManager
    constructor: (callback) ->
        that = this
        chrome.storage.local.get ["country", "settings"], ({country:country, settings:stored_settings}) ->
            that.interfaces = {}
            if (!country)
                country = "Other"
            for retailer in ["Digikey", "Farnell", "Mouser", "RS"]
                setting_values = that.lookup_setting_values(country, retailer, stored_settings)
                that.interfaces[retailer] = that.newInterface(retailer, country, setting_values)
            if callback?
                callback()

    lookup_setting_values: (country, retailer, stored_settings)->
        if(stored_settings? && stored_settings[country]? && stored_settings[country][retailer]?)
            settings = settings_data[country][retailer].choices[stored_settings[country][retailer]]
        else
            settings = {}
        return settings

    newInterface:(retailer_name, country, setting_values) ->
        switch (retailer_name)
            when "Digikey"
                return new Digikey(country, setting_values)
            when "Farnell"
                return new Farnell(country, setting_values)
            when "Mouser"
                return new  Mouser(country, setting_values)
            when "RS"
                return new     RS(country, setting_values)
    getBOM: (callback) ->
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            callback(bom)

    addToBOM: (text, callback) ->
        that = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            if (!bom)
                bom = {}

            {items, invalid} = (new Parser).parseTSV(text)

            if invalid.length > 0
                chrome.runtime.sendMessage({invalid:invalid})

            for item in items
                #if item.retailer not in bom
                found = false
                for key of bom
                    if item.retailer == key
                        found = true
                        break
                if not found
                    bom[item.retailer] = {"items":[]}
                bom[item.retailer].items.push(item)

            chrome.storage.local.set {"bom":bom}, () ->
                if callback?
                    callback(that)

    fillCarts: (callback)->
        that = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            for retailer of bom
                that.interfaces[retailer].addItems(bom[retailer].items)

    fillCart: (retailer, callback)->
        that = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            that.interfaces[retailer].addItems(bom[retailer].items, callback)

    emptyCarts: ()->
        that = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            for retailer of bom
                that.emptyCart(retailer)

    emptyCart: (retailer, callback)->
        this.interfaces[retailer].emptyCart(callback)

    openCarts: ()->
        that = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            for retailer of bom
                that.openCart(retailer)

    openCart: (retailer)->
        this.interfaces[retailer].openCartTab()
