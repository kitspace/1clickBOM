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

countries_data = @get_local("/data/countries.json")
settings_data  = @get_local("/data/settings.json")

class @BomManager
    constructor: (callback) ->
        that = this
        chrome.storage.local.get ["bom", "country", "settings"], ({bom:bom, country:country, settings:stored_settings}) ->
            that.bom = bom
            for retailer of that.bom
                setting_values = that.lookup_setting_values(country, retailer, stored_settings)
                that.newInterface(retailer, that.bom[retailer], country, setting_values)
            if callback?
                callback()

    lookup_setting_values: (country, retailer, stored_settings)->
        if(stored_settings? && stored_settings[country]? && stored_settings[country][retailer]?)
            settings = settings_data[country][retailer].choices[stored_settings[country][retailer]]
        else
            settings = {}
        return settings

    newInterface:(retailer_name, retailer, country, setting_values) ->
        switch (retailer_name)
            when "Digikey"
                retailer.interface = new Digikey(country, setting_values)
            when "Farnell"
                retailer.interface = new Farnell(country, setting_values)
            when "Mouser"
                retailer.interface = new  Mouser(country, setting_values)
            when "RS"
                retailer.interface = new      RS(country, setting_values)
    getBOM: () ->
        return @bom

    addToBOM: (text, callback) ->
        that = this
        #we already have these but it seems to take longer for the storage onChanged listener to trigger without this
        #might be a case for "setImmediate" as "setTimeout(function, 0)" doesn't help either
        chrome.storage.local.get ["bom", "country", "settings"], ({bom:bom, country:country, settings:stored_settings}) ->
            if (!bom)
                bom = {}

            if (!country)
                country = "Other"

            {items, invalid} = (new Parser).parseTSV(text)

            if invalid.length > 0
                chrome.runtime.sendMessage({invalid:invalid})

            for item in items
                setting_values = that.lookup_setting_values(country, item.retailer, stored_settings)
                #if item.retailer not in bom
                found = false
                for key of bom
                    if item.retailer == key
                        found = true
                        break
                if not found
                    bom[item.retailer] = {"items":[]}
                if (not found) or (bom[item.retailer].interface.country != country) or (bom[item.retailer].interface.settings != setting_values)
                    that.newInterface(item.retailer, bom[item.retailer], country, setting_values)
                bom[item.retailer].items.push(item)

            chrome.storage.local.set {"bom":bom}, () ->
                if callback?
                    callback(that)

    fillCarts: (retailer, callback)->
        for retailer of @bom
            @fillCart retailer, () ->

    fillCart: (retailer, callback)->
        @bom[retailer].interface.addItems(@bom[retailer].items, callback)

    emptyCarts: ()->
        for retailer of @bom
            @emptyCart(retailer)
    emptyCart: (retailer, callback)->
        @bom[retailer].interface.clearCart(callback)

    openCarts: ()->
        for retailer of @bom
            @openCart(retailer)
    openCart: (retailer)->
        @bom[retailer].interface.openCartTab()
