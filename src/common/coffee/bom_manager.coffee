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

http       = require './http'
{browser } = require './browser'
{Digikey } = require './digikey'
{Farnell } = require './farnell'
{Mouser  } = require './mouser'
{RS      } = require './rs'
{Newark  } = require './newark'
{parseTSV} = require './parser'
{badge}    = require './badge'
{retailer_list} = require './retailer_list'

bom_manager =
    retailers: [Digikey, Farnell, Mouser, RS, Newark]
    init: (callback) ->
        @filling_carts  = false
        @emptying_carts = false
        browser.prefsGet ['country', 'settings']
        , ({country:country, settings:stored_settings}) =>
            @interfaces = {}
            if (!country)
                country = 'Other'
            count = @retailers.length
            for retailer_interface in @retailers
                retailer = retailer_interface.name
                if stored_settings?[country]?[retailer]?
                    setting_values = stored_settings[country][retailer]
                else
                    setting_values = {}
                @interfaces[retailer] = new retailer_interface country
                , setting_values, () ->
                    count -= 1
                    if count == 0
                        callback?()

    getBOM: (callback) ->
        browser.storageGet ['bom'], ({bom:bom}) =>
            if not bom
                bom = {}
            if not bom.retailers
                bom.retailers = {}
            if not bom.items
                bom.items = []
            callback(bom)

    addToBOM: (text, callback) ->
        {items, invalid, warnings} = parseTSV(text)
        if invalid.length > 0
            for inv in invalid
                title = 'Could not parse row '
                title += inv.row
                message = inv.reason + '\n'
                browser.notificationsCreate
                    type:'basic'
                    title:title
                    message:message
                    iconUrl:'/images/warning.png'
                badge.setDecaying('Warn','#FF8A00', priority=2)
        else if items.length == 0
            title = 'Nothing pasted '
            message = 'Clipboard is empty'
            browser.notificationsCreate
                type:'basic'
                title:title
                message:message
                iconUrl:'/images/warning.png'
            badge.setDecaying('Warn','#FF8A00', priority=2)
        else if warnings?.length > 0
            for w in warnings
                title = w.title
                message = w.message
                browser.notificationsCreate
                    type:'basic'
                    title:title
                    message:message
                    iconUrl:'/images/warning.png'
                badge.setDecaying('Warn','#FF8A00', priority=2)
        else if items.length > 0
            badge.setDecaying('OK','#00CF0F')
        @_add_to_bom(items, invalid, warnings, callback)

    _to_retailers: (items) ->
        r = {}
        for item in items
            for retailer,part of item.retailers
                if part != ''
                    if not r[retailer]?
                        r[retailer] = []
                    r[retailer].push
                        part     : part
                        quantity : item.quantity
                        comment  : item.comment
        return r


    _merge_items: (items1, items2) ->
        merged = []
        for item2 in items2
            exists = false
            for item1 in items1
                if item1.comment == item2.comment
                    exists = true
                    for r of retailer_list
                        if item1.retailers[r] == ''
                            item1.retailers[r] = item2.retailers[r]
                    item1.quantity += item2.quantity
                    merged.push(item1)
                    break
            if not exists
                merged.push(item2)
        return merged


    _add_to_bom: (items, invalid, warnings, callback) ->
        @getBOM (bom) =>
            bom.items = @_merge_items(bom.items, items)
            bom.retailers = @_to_retailers(bom.items)
            over = []
            for retailer,lines of bom.retailers
                if lines.length > 100
                    over.push(retailer)
            if over.length > 0
                title = "That's a lot of lines!"
                message = 'You have over 100 lines for '
                message += over[0]
                if over.length > 1
                    for retailer in over[1 .. over.length - 2]
                        message += ', ' + retailer
                    message += ' and '
                    message += over[over.length - 1]
                message += ". Adding the items may take a very long time
                (or even forever). It may be OK but it really depends on the
                site."
                browser.notificationsCreate
                    type:'basic'
                    title:title
                    message:message
                    iconUrl:'/images/warning.png'
                badge.setDecaying('Warn','#FF8A00', priority=2)
            browser.storageSet {bom:bom}, () =>
                callback?(this)


    notifyFillCart: (items, retailer, result) ->
        if not result.success
            fails = result.fails
            failed_items = []
            if fails.length == 0
                title = 'There may have been problems adding items'
                title += ' to ' + retailer + ' cart. '
                failed_items.push
                    title:'Please check the cart to try and ' ,
                    message:''
                failed_items.push
                    title:'correct any issues.'
                    message:''
            else
                title = 'Could not add ' + fails.length
                title += ' out of ' + items.length + ' line'
                title += if items.length > 1 then 's' else ''
                title += ' to ' + retailer + ' cart:'
                for fail in fails
                    failed_items.push
                        title:"item: #{fail.comment} | #{fail.quantity}
                        | #{fail.part}"
                        message:''
            browser.notificationsCreate
                type:'list'
                title:title
                message:''
                items:failed_items
                iconUrl:'/images/error.png'
            badge.setDecaying('Err','#FF0000', priority=2)
        else
            badge.setDecaying('OK','#00CF0F')
        if result.warnings?
            for warning in result.warnings
                title = warning
                browser.notificationsCreate
                    type:'basic'
                    title:title
                    message:''
                    iconUrl:'/images/warning.png'
                badge.setDecaying('Warn','#FF8A00', priority=1)


    notifyEmptyCart: (retailer, result) ->
        if not result.success
            title = 'Could not empty ' + retailer + ' cart'
            browser.notificationsCreate
                type:'basic'
                title:title
                message:''
                iconUrl:'/images/error.png'
            badge.setDecaying('Err','#FF0000', priority=2)
        else
            badge.setDecaying('OK','#00CF0F')

    fillCarts: (callback, callbackEveryRetailer)->
        @filling_carts = true
        big_result = {success:true, fails:[]}
        browser.storageGet ['bom'], ({bom:bom}) =>
            count = Object.keys(bom.retailers).length
            for retailer of bom.retailers
                @interfaces[retailer].addItems bom.retailers[retailer]
                , (result, interf, items) =>
                    @notifyFillCart(items, interf.name, result)
                    count--
                    big_result.success &&= result.success
                    big_result.fails = big_result.fails.concat(result.fails)
                    callbackEveryRetailer?(result.success)
                    if count == 0
                        @filling_carts = false
                        callback?()

    fillCart: (retailer, callback)->
        browser.storageGet ['bom'], ({bom:bom}) =>
            @interfaces[retailer].addItems bom.retailers[retailer]
            , (result) =>
                @notifyFillCart bom.retailers[retailer], retailer, result
                callback(result)

    emptyCarts: (callback, callbackEveryRetailer)->
        @emptying_carts = true
        big_result = {success: true}
        browser.storageGet ['bom'], ({bom:bom}) =>
            if bom?
                count = Object.keys(bom.retailers).length
                for retailer of bom.retailers
                    @emptyCart retailer, (result, interf) =>
                        count--
                        big_result.success &&= result.success
                        callbackEveryRetailer?(result.success)
                        if count == 0
                            @emptying_carts = false
                            callback?(big_result)
            else
                @emptying_carts = false
                callback?(big_result)

    emptyCart: (retailer, callback)->
        @interfaces[retailer].clearCart (result) =>
            @notifyEmptyCart(retailer, result)
            callback?(result)

    openCarts: ()->
        browser.storageGet ['bom'], ({bom:bom}) =>
            for retailer of bom.retailers
                @openCart(retailer)

    openCart: (retailer)->
        @interfaces[retailer].openCartTab()

bom_manager.init()

exports.bom_manager = bom_manager
