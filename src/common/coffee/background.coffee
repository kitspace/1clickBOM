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

{bom_manager}   = require './bom_manager'
{browser}       = require './browser'
{parseTSV}      = require './parser'
http            = require './http'
{badge}         = require './badge'
{writeTSV}      = require './writer'
{retailer_list} = require './line_data'


exports.background = (messenger) ->

    browser.prefsOnChanged ['country', 'settings'], () ->
        bom_manager.init()

    tsvPageNotifier =
        onDotTSV : false
        re       : new RegExp('\.tsv$','i')
        lines    : []
        invalid  : []
        _set_not_dotTSV: () ->
            badge.setDefault('')
            @onDotTSV = false
            @lines    = []
            @invalid  = []
            sendState()
        checkPage: (callback) ->
            browser.tabsGetActive (tab) =>
                if tab?
                    tab_url = tab.url.split('?')[0]
                    if tab_url.match(@re)
                        if /^http.?:\/\/github.com\//.test(tab.url)
                            url = tab_url.replace(/blob/,'raw')
                        else if /^http.?:\/\/bitbucket.org\//.test(tab.url)
                            url = tab_url.split('?')[0].replace(/src/,'raw')
                        else
                            url = tab_url
                        http.get url, {notify:false}, (event) =>
                            {lines, invalid} = parseTSV(event.target.responseText)
                            if lines.length > 0
                                badge.setDefault('\u2191', '#0000FF')
                                @onDotTSV = true
                                @lines    = lines
                                @invalid  = invalid
                                sendState()
                            else
                                @_set_not_dotTSV()
                        , () =>
                            @_set_not_dotTSV()
                    else
                        @_set_not_dotTSV()
                    if callback?
                        callback()
                else if callback?
                    callback()
        addToBOM: (callback) ->
            @checkPage () =>
                if @onDotTSV
                    bom_manager._add_to_bom(@lines, @invalid, callback)

    browser.tabsOnUpdated () =>
        tsvPageNotifier.checkPage()

    sendState = () ->
        bom_manager.getBOM (bom) ->
            messenger.send('sendBackgroundState',
                bom:bom
                bom_manager:bom_manager
                onDotTSV: tsvPageNotifier.onDotTSV)

    messenger.on 'getBackgroundState', () ->
        sendState()

    messenger.on 'fillCart', (name, callback) ->
        bom_manager.fillCart name, ((name) ->
            bom_manager.openCart(name)
            sendState()
        ).bind(undefined, name)
        sendState()

    messenger.on 'openCart', (name) ->
        bom_manager.openCart(name)

    messenger.on 'autoComplete', () ->
        bom_manager.autoComplete ()->
            sendState()
            badge.setDecaying('OK','#00CF0F')

    messenger.on 'emptyCart', (name) ->
        bom_manager.emptyCart name, ((name) ->
            bom_manager.openCart(name)
            sendState()
        ).bind(undefined, name)
        sendState()

    messenger.on 'clearBOM', () ->
        browser.storageRemove 'bom' , () ->
            sendState()

    messenger.on 'paste', () ->
        bom_manager.addToBOM browser.paste(), () ->
            sendState()

    messenger.on 'copy', () ->
        bom_manager.getBOM (bom) ->
            browser.copy(writeTSV(bom))
            badge.setDecaying('OK','#00CF0F')

    messenger.on 'loadFromPage', () ->
        tsvPageNotifier.addToBOM () ->
            sendState()

    messenger.on 'emptyCarts', () ->
        for name in retailer_list
            bom_manager.emptyCart name, () ->
                sendState()
        sendState()

    messenger.on 'fillCarts', () ->
        for name in retailer_list
            bom_manager.fillCart name, ((name) ->
                bom_manager.openCart(name)
                sendState()
            ).bind(undefined, name)
        sendState()

    sendState()
