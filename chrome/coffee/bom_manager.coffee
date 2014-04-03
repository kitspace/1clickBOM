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
    constructor: () ->

    newInterface:(retailer_name, retailer, country, settings) ->
        switch (retailer_name)
            when "Digikey"
                retailer.interface = new Digikey(country, settings)
            when "Farnell"
                retailer.interface = new Farnell(country, settings)
            when "Mouser"
                retailer.interface = new  Mouser(country, settings)

    addToBOM: (text, callback) ->
        that = this
        chrome.storage.local.get ["bom", "country"], (obj) ->
            bom = obj.bom
            country = obj.country
    
            if (!bom)
                bom = {}
    
            if (!country)
                country = "Other"
    
            parser = new Parser
            {items, invalid} = parser.parseTSV(text)
            {items, invalid} = parser.checkValidItems(items, invalid)
    
            if invalid.length > 0
                chrome.runtime.sendMessage({invalid:invalid})
    
            for item in items
                #if item.retailer not in bom
                found = false
                for key of bom
                    if item.retailer == key
                        found = true
                        break
                if (!found)
                    bom[item.retailer] = {"items":[]}
                if(!found or (bom[item.retailer].interface.country != country))
                    that.newInterface(item.retailer, bom[item.retailer], country)
                bom[item.retailer].items.push(item)
    
            chrome.storage.local.set {"bom":bom}, () ->
                if callback?
                    callback(that)
    lookup_setting_values: (country, retailer, stored_settings)->
        if(stored_settings? && stored_settings[country]? && stored_settings[country][retailer]?)
            settings = settings_data[country][retailer].choices[stored_settings[country][retailer]]
        else
            settings = {}
        return settings
    fill_carts: ()->
        that = this
        chrome.storage.local.get ["bom", "country", "settings"], ({bom:bom, country:country, settings:stored_settings}) ->
            for retailer of bom
                setting_values = that.lookup_setting_values(country, retailer, stored_settings)
                that.newInterface(retailer, bom[retailer], country, setting_values)
                bom[retailer].interface.addItems(bom[retailer].items)
    
    fill_cart: (retailer)->
        that = this
        chrome.storage.local.get ["bom", "country", "settings"], ({bom:bom, country:country, settings:stored_settings}) ->
            setting_values = that.lookup_setting_values(country, retailer, stored_settings)
            that.newInterface(retailer, bom[retailer], country, setting_values)
            bom[retailer].interface.addItems(bom[retailer].items)
    
    empty_carts: ()->
        that = this
        chrome.storage.local.get ["bom", "country", "settings"], ({bom:bom, country:country, settings:stored_settings}) ->
            for retailer of bom
                setting_values = that.lookup_setting_values(country, retailer, stored_settings)
                that.newInterface(retailer, bom[retailer], country, setting_values)
                bom[retailer].interface.clearCart()
    
    empty_cart: (retailer)->
        that = this
        chrome.storage.local.get ["bom", "country", "settings"], ({bom:bom, country:country, settings:stored_settings}) ->
    
            setting_values = that.lookup_setting_values(country, retailer, stored_settings)
            that.newInterface(retailer, bom[retailer], country, setting_values)
            bom[retailer].interface.clearCart()
    
    open_cart_tabs: ()->
        that = this
        chrome.storage.local.get ["bom", "country", "settings"], ({bom:bom, country:country, settings:stored_settings}) ->
            for retailer of bom
                setting_values = that.lookup_setting_values(country, retailer, stored_settings)
                that.newInterface(retailer, bom[retailer], country, setting_values)
                bom[retailer].interface.openCartTab()
    
    open_cart: (retailer)->
        that = this
        chrome.storage.local.get ["bom", "country", "settings"], ({bom:bom, country:country, settings:stored_settings}) ->
            setting_values = that.lookup_setting_values(country, retailer, stored_settings)
            that.newInterface(retailer, bom[retailer], country, setting_values)
            bom[retailer].interface.openCartTab()
