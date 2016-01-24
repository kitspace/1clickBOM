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
{parseTSV}      = require '1-click-bom'

http            = require './http'
{browser }      = require './browser'
{Digikey }      = require './digikey'
{Farnell }      = require './farnell'
{Mouser  }      = require './mouser'
{RS      }      = require './rs'
{Newark  }      = require './newark'
{badge}         = require './badge'
{retailer_list} = require('1-click-bom').lineData
{autoComplete}  = require './auto_complete'

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
            if not bom?
                bom = {}
            else
                old_bom = retailer_list.reduce (prev, k) ->
                    prev ||= bom[k]?
                , false
                if old_bom
                    bom = {}
            if not bom.retailers?
                bom.retailers = {}
            if not bom.lines?
                bom.lines = []
            callback(bom)

    autoComplete: (callback) ->
        @getBOM (bom) =>
            autoComplete bom.lines, (lines) =>
                bom = {}
                bom.lines = lines
                bom.retailers = @_to_retailers(lines)
                browser.storageSet {bom:bom}, () ->
                    callback?()

    addToBOM: (text, callback) ->
        {lines, invalid, warnings} = parseTSV(text)
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
        else if lines.length == 0
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
        else if lines.length > 0
            badge.setDecaying('OK','#00CF0F')
        @_add_to_bom(lines, invalid, callback)

    _to_retailers: (lines) ->
        r = {}
        for line in lines
            for retailer, part of line.retailers
                if part? and part != ''
                    if not r[retailer]?
                        r[retailer] = []
                    r[retailer].push
                        part     : part
                        quantity : line.quantity
                        reference  : line.reference
        return r


    _merge_lines: (lines1, lines2) ->
        warnings = []
        duplicates = {}
        merged = lines1
        for line2, index in lines2
            for line2_, index_ in lines2
                if index != index_ and line2.reference == line2_.reference
                    d = duplicates[line2.reference]
                    if d?
                        if index not in d
                            d.push(index)
                        if index_ not in d
                            d.push(index_)
                    else
                         duplicates[line2.reference] = [index, index_]
            exists = false
            for line1 in merged
                if line1.reference == line2.reference
                    exists = true
                    for r in retailer_list
                        if line2.retailers[r] != ''
                            line1.retailers[r] = line2.retailers[r]
                    if line2.partNumber != ''
                        line1.partNumber = line2.partNumber
                    if line2.manufacturer != ''
                        line1.manufacturer = line2.manufacturer
                    line1.quantity += line2.quantity
                    break
            if not exists
                merged.push(line2)
        for ref, d of duplicates
            warnings.push(
                title:'Duplicate lines detected'
                message:"You have the exact same reference '#{ref}' on lines
                    #{n + 1 for n in d[0..(d.length-2)]} and #{d[d.length-1] + 1}.
                    These have been merged"
            )
        return [merged, warnings]


    _add_to_bom: (lines, invalid, callback) ->
        @getBOM (bom) =>
            [bom.lines, warnings] = @_merge_lines(bom.lines, lines)
            for warning in warnings
                browser.notificationsCreate
                    type:'basic'
                    title:warning.title
                    message:warning.message
                    iconUrl:'/images/warning.png'
                badge.setDecaying('Warn','#FF8A00', priority=2)
            bom.retailers = @_to_retailers(bom.lines)
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
                message += ". Adding the lines may take a very long time
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


    notifyFillCart: (lines, retailer, result) ->
        if not result.success
            fails = result.fails
            failed_lines = []
            if fails.length == 0
                title = 'There may have been problems adding lines'
                title += ' to ' + retailer + ' cart. '
                failed_lines.push
                    title:'Please check the cart to try and ' ,
                    message:''
                failed_lines.push
                    title:'correct any issues.'
                    message:''
            else
                title = 'Could not add ' + fails.length
                title += ' out of ' + lines.length + ' line'
                title += if lines.length > 1 then 's' else ''
                title += ' to ' + retailer + ' cart:'
                for fail in fails
                    failed_lines.push
                        title:"line: #{fail.reference} | #{fail.quantity}
                        | #{fail.part}"
                        message:''
            browser.notificationsCreate
                type:'list'
                title:title
                message:''
                items:failed_lines
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


    fillCart: (retailer, callback)->
        @getBOM (bom) =>
            if bom.retailers[retailer]?
                @interfaces[retailer].addLines bom.retailers[retailer]
                , (result) =>
                    @notifyFillCart bom.retailers[retailer], retailer, result
                    callback(result)

    emptyCart: (retailer, callback)->
        @interfaces[retailer].clearCart (result) =>
            @notifyEmptyCart(retailer, result)
            callback?(result)

    openCart: (retailer)->
        @interfaces[retailer].openCartTab()

bom_manager.init()

exports.bom_manager = bom_manager
