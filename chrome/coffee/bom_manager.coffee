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

class window.BomManager
    constructor: (callback) ->
        self = this
        self.filling_carts  = false
        self.emptying_carts = false
        chrome.storage.local.get ["country", "settings"], ({country:country, settings:stored_settings}) ->
            self.interfaces = {}
            if (!country)
                country = "Other"
            for retailer_interface in [Digikey, Farnell, Mouser, RS, Newark]
                setting_values = self.lookup_setting_values(country, retailer_interface.name, stored_settings)
                self.interfaces[retailer_interface.name] = new retailer_interface(country, setting_values)
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
        self = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            if (!bom)
                bom = {}

            {items, invalid} = window.parseTSV(text)

            if invalid.length > 0
                for inv in invalid
                    title = "Could not parse row: "
                    title += inv.item.row
                    message = inv.reason + "\n"
                    chrome.notifications.create "", {type:"basic", title:title , message:message, iconUrl:"/images/warning128.png"}, () ->
                    badge.set("Warn","#FF8A00", priority=1)
            else if items.length == 0
                title = "Nothing pasted "
                message = "Clipboard is empty"
                chrome.notifications.create "", {type:"basic", title:title , message:message, iconUrl:"/images/warning128.png"}, () ->
                badge.set("Warn","#FF8A00", priority=1)
            else if items.length > 0
                badge.set("OK","#00CF0F")

            for item in items
                if item.retailer not of bom
                    bom[item.retailer] = []
                bom[item.retailer].push(item)

            chrome.storage.local.set {"bom":bom}, () ->
                if callback?
                    callback(self)
    notifyFillCart: (items, retailer, result) ->
        if not result.success
            fails = result.fails
            title = "Could not add " + fails.length
            title += " out of " + items.length + " line"
            title += if items.length > 1 then "s" else ""
            title += " to " + retailer + " cart"
            chrome.notifications.create "", {type:"basic", title:title, message:"", iconUrl:"/images/error128.png"}, () ->
            badge.set("Err","#FF0000", priority=2)
        else
            badge.set("OK","#00CF0F")
        if result.warnings?
            for warning in result.warnings
                title = warning
                chrome.notifications.create "", {type:"basic", title:title, message:"", iconUrl:"/images/warning128.png"}, () ->
                badge.set("Warn","#FF8A00", priority=1)



    notifyEmptyCart: (retailer, result) ->
        if not result.success
            title = "Could not empty" + retailer + " cart"
            chrome.notifications.create "", {type:"basic", title:title, message:"", iconUrl:"/images/error128.png"}, () ->
            badge.set("Err","#FF0000", priority=2)
        else
            badge.set("OK","#00CF0F")

    fillCarts: (callback)->
        self = this
        self.filling_carts = true
        big_result = {success:true, fails:[]}
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            count = Object.keys(bom).length
            for retailer of bom
                self.interfaces[retailer].addItems bom[retailer], (result, interf, items) ->
                    self.notifyFillCart(items, interf.interface_name, result)
                    count--
                    big_result.success &&= result.success
                    big_result.fails = big_result.fails.concat(result.fails)
                    if count == 0
                        if callback?
                            callback(big_result)
                        self.filling_carts = false


    fillCart: (retailer, callback)->
        self = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            self.interfaces[retailer].addItems bom[retailer], (result) ->
                self.notifyFillCart bom[retailer], retailer, result
                callback(result)

    emptyCarts: (callback)->
        self = this
        self.emptying_carts = true
        big_result = {success: true}
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            count = Object.keys(bom).length
            for retailer of bom
                self.emptyCart retailer, (result, interf) ->
                    count--
                    big_result.success &&= result.success
                    if count == 0
                        if callback?
                            callback(big_result)
                        self.emptying_carts = false

    emptyCart: (retailer, callback)->
        self = this
        self.interfaces[retailer].clearCart (result) ->
            self.notifyEmptyCart(retailer, result)
            if callback?
                callback(result)

    openCarts: ()->
        self = this
        chrome.storage.local.get ["bom"], ({bom:bom}) ->
            for retailer of bom
                self.openCart(retailer)

    openCart: (retailer)->
        this.interfaces[retailer].openCartTab()
