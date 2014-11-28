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

settings_data  = get_local("data/settings.json")

class window.BomManager
    constructor: (callback) ->
        @filling_carts  = false
        @emptying_carts = false
        browser.storageGet ["country", "settings"], ({country:country, settings:stored_settings}) =>
            @interfaces = {}
            if (!country)
                country = "Other"
            count = 5
            for retailer_interface in [Digikey, Farnell, Mouser, RS, Newark]
                setting_values = @lookup_setting_values(country, retailer_interface.name, stored_settings)
                @interfaces[retailer_interface.name] = new retailer_interface country, setting_values, () ->
                    count -= 1
                    if count == 0
                        if callback?
                            callback()

    lookup_setting_values: (country, retailer, stored_settings)->
        if(stored_settings? && stored_settings[country]? && stored_settings[country][retailer]?)
            settings = settings_data[country][retailer].choices[stored_settings[country][retailer]]
        else
            settings = {}
        return settings

    getBOM: (callback) ->
        browser.storageGet ["bom"], ({bom:bom}) =>
            callback(bom)

    addToBOM: (text, callback) ->
        {items, invalid} = window.parseTSV(text)
        @_add_to_bom(items, invalid, callback)

    _add_to_bom: (items, invalid, callback) ->
        browser.storageGet ["bom"], ({bom:bom}) =>
            if (!bom)
                bom = {}
            if invalid.length > 0
                for inv in invalid
                    title = "Could not parse row: "
                    title += inv.item.row
                    message = inv.reason + "\n"
                    browser.notificationsCreate {type:"basic", title:title , message:message, iconUrl:"/images/warning128.png"}, () ->
                    badge.setDecaying("Warn","#FF8A00", priority=2)
            else if items.length == 0
                title = "Nothing pasted "
                message = "Clipboard is empty"
                browser.notificationsCreate {type:"basic", title:title , message:message, iconUrl:"/images/warning128.png"}, () ->
                badge.setDecaying("Warn","#FF8A00", priority=2)
            else if items.length > 0
                badge.setDecaying("OK","#00CF0F")

            for item in items
                if item.retailer not of bom
                    bom[item.retailer] = []
                existing = false
                for existing_item in bom[item.retailer]
                    if existing_item.part == item.part && existing_item.retailer == item.retailer
                        existing_item.quantity += item.quantity
                        if existing_item.comment != item.comment
                            existing_item.comment  += "," + item.comment
                        existing = true
                        break
                if not existing
                    bom[item.retailer].push(item)
            over = []
            for retailer,lines of bom
                if lines.length > 100
                    over.push(retailer)
            if over.length > 0
                title = "That's a lot of lines!"
                message = "You have over 100 lines for "
                message += over[0]
                if over.length > 1
                    for retailer in over[1 .. over.length - 2]
                        message += ", " + retailer
                    message += " and "
                    message += over[over.length - 1]
                message += ". Adding the items may take a very long time (or even forever). It may be OK but it really depends on the site."
                browser.notificationsCreate {type:"basic", title:title , message:message, iconUrl:"/images/warning128.png"}, () ->
                badge.setDecaying("Warn","#FF8A00", priority=2)
            browser.storageSet {"bom":bom}, () =>
                if callback?
                    callback(this)

    notifyFillCart: (items, retailer, result) ->
        if not result.success
            fails = result.fails
            failed_items = []
            if fails.length == 0
                title = "There may have been problems adding items"
                title += " to " + retailer + " cart. "
                failed_items.push({title:"Please check the cart to try and " ,message:""})
                failed_items.push({title:"correct any issues." ,message:""})
            else
                title = "Could not add " + fails.length
                title += " out of " + items.length + " line"
                title += if items.length > 1 then "s" else ""
                title += " to " + retailer + " cart:"
                for fail in fails
                    failed_items.push({title:"item: " + fail.comment + " | " + fail.quantity + " | " + fail.part,message:""})
            browser.notificationsCreate {type:"list", title:title, message:"", items:failed_items, iconUrl:"/images/error128.png"}, () =>
            badge.setDecaying("Err","#FF0000", priority=2)
        else
            badge.setDecaying("OK","#00CF0F")
        if result.warnings?
            for warning in result.warnings
                title = warning
                browser.notificationsCreate {type:"basic", title:title, message:"", iconUrl:"/images/warning128.png"}, () =>
                badge.setDecaying("Warn","#FF8A00", priority=1)

    notifyEmptyCart: (retailer, result) ->
        if not result.success
            title = "Could not empty " + retailer + " cart"
            browser.notificationsCreate {type:"basic", title:title, message:"", iconUrl:"/images/error128.png"}, () =>
            badge.setDecaying("Err","#FF0000", priority=2)
        else
            badge.setDecaying("OK","#00CF0F")

    fillCarts: (callback)->
        @filling_carts = true
        big_result = {success:true, fails:[]}
        browser.storageGet ["bom"], ({bom:bom}) =>
            count = Object.keys(bom).length
            for retailer of bom
                @interfaces[retailer].addItems bom[retailer], (result, interf, items) =>
                    @notifyFillCart(items, interf.interface_name, result)
                    count--
                    big_result.success &&= result.success
                    big_result.fails = big_result.fails.concat(result.fails)
                    if count == 0
                        if callback?
                            callback(big_result)
                        @filling_carts = false

    fillCart: (retailer, callback)->
        browser.storageGet ["bom"], ({bom:bom}) =>
            @interfaces[retailer].addItems bom[retailer], (result) =>
                @notifyFillCart bom[retailer], retailer, result
                callback(result)

    emptyCarts: (callback)->
        @emptying_carts = true
        big_result = {success: true}
        browser.storageGet ["bom"], ({bom:bom}) =>
            if bom?
                count = Object.keys(bom).length
                for retailer of bom
                    @emptyCart retailer, (result, interf) =>
                        count--
                        big_result.success &&= result.success
                        if count == 0
                            if callback?
                                callback(big_result)
                            @emptying_carts = false
            else
                if callback?
                    callback(big_result)
                @emptying_carts = false

    emptyCart: (retailer, callback)->
        @interfaces[retailer].clearCart (result) =>
            @notifyEmptyCart(retailer, result)
            if callback?
                callback(result)

    openCarts: ()->
        browser.storageGet ["bom"], ({bom:bom}) =>
            for retailer of bom
                @openCart(retailer)

    openCart: (retailer)->
        @interfaces[retailer].openCartTab()
