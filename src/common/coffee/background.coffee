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

{bom_manager} = require './bom_manager'
{browser}     = require './browser'
{parseTSV}    = require './parser'
http          = require './http'
{badge}       = require './badge'

exports.background = (messenger) ->

    get_location = (callback) ->
        countries_data = browser.getLocal("data/countries.json")
        @used_country_codes = []
        for _,code of countries_data
            @used_country_codes.push(code)
        url = "http://kaspar.h1x.com:8080/json"
        http.get url, {timeout:5000}, (event) =>
            response = JSON.parse(event.target.responseText)
            code = response.country_code
            if code == "GB" then code = "UK"
            if code not in @used_country_codes then code = "Other"
            browser.storageSet({country: code}, callback)
        , () ->
            callback()

    browser.onInstalled () ->
        get_location () ->
            browser.tabsCreate(browser.getURL("html/options.html"))

    browser.storageOnChanged (changes) ->
        if changes.country || changes.settings
            bom_manager.init()

    tsvPageNotifier =
        onDotTSV : false
        re       : new RegExp("\.tsv$","i")
        items    : []
        invalid  : []
        _set_not_dotTSV: () ->
            badge.setDefault("")
            @onDotTSV = false
            @items    = []
            @invalid  = []
            sendState()
        checkPage: (callback) ->
            browser.tabsGetActive (tab) =>
                if tab?
                    tab_url = tab.url.split("?")[0]
                    if tab_url.match(@re)
                        if /^http.?:\/\/github.com\//.test(tab.url)
                            url = tab_url.replace(/blob/,"raw")
                        else if /^http.?:\/\/bitbucket.org\//.test(tab.url)
                            url = tab_url.split("?")[0].replace(/src/,"raw")
                        else
                            url = tab_url
                        http.get url, {notify:false}, (event) =>
                            {items, invalid} = parseTSV(event.target.responseText)
                            if items.length > 0
                                http.badge.setDefault("\u2191", "#0000FF")
                                @onDotTSV = true
                                @items    = items
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
                    bom_manager._add_to_bom(@items, @invalid, callback)

    browser.tabsOnUpdated () =>
        tsvPageNotifier.checkPage()

    sendState = () ->
        bom_manager.getBOM (bom) ->
            #this estimates the size needed for the firefox popup and resizes
            #it to emulate chrome behaviour
            if messenger.resizePopup?
                width  = 92
                height = 46
                nRetailers = Object.keys(bom).length
                if nRetailers > 0
                    maxItems = 0
                    maxLines = 0
                    for retailer_name of bom
                        items = bom[retailer_name]
                        no_of_items = 0
                        for item in items
                            no_of_items += item.quantity
                        if no_of_items > maxItems then maxItems = no_of_items
                        if items.length > maxLines then maxLines = items.length
                    width = 243 + (String(maxItems).length * 9) + (String(maxLines).length * 9)
                    if maxItems > 1 then width += 9 #due to 's' being added for plural
                    if maxLines > 1 then width += 9
                    height += 40 + (nRetailers * 27)
                else if tsvPageNotifier.onDotTSV
                    height += 36
                messenger.resizePopup(width, height)
            messenger.send("sendBackgroundState", {bom:bom, bom_manager:bom_manager, onDotTSV: tsvPageNotifier.onDotTSV})

    messenger.on "getBackgroundState", () ->
        sendState()

    messenger.on "fillCart", (name, callback) ->
        bom_manager.fillCart name, () ->
            sendState()
        sendState()

    messenger.on "fillCarts", () ->
        bom_manager.fillCarts undefined, () ->
            sendState()
        sendState()

    messenger.on "openCart", (name) ->
        bom_manager.openCart(name)

    messenger.on "openCarts", () ->
        bom_manager.openCarts()

    messenger.on "emptyCart", (name) ->
        bom_manager.emptyCart name, () ->
            sendState()
        sendState()

    messenger.on "emptyCarts", () ->
        bom_manager.emptyCarts undefined, () ->
            sendState()
        sendState()

    messenger.on "clearBOM", () ->
        browser.storageRemove "bom" , () ->
            sendState()

    messenger.on "paste", () ->
        bom_manager.addToBOM browser.paste(), () ->
            sendState()

    messenger.on "loadFromPage", () ->
        tsvPageNotifier.addToBOM () ->
            sendState()

    sendState()

    # tests only work in chrome currently which has the window available in the
    # background
    if window?
        window.Test = (module)->
            url = browser.getURL("html/test.html")
            url += "?module=" + module if module?
            window.open(url)
