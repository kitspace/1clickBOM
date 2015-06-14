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
util          = require './util'

exports.background = (messenger) ->

    window.paste = (callback) ->
        textarea = document.getElementById("pastebox")
        textarea.select()
        document.execCommand("paste")
        bom_manager.addToBOM(textarea.value, callback)

    get_location = (callback) ->
        countries_data = browser.getLocal("data/countries.json")
        @used_country_codes = []
        for _,code of countries_data
            @used_country_codes.push(code)
        url = "http://kaspar.h1x.com:8080/json"
        util.get url, {timeout:5000}, (event) =>
            response = JSON.parse(event.target.responseText)
            code = response.country_code
            if code == "GB" then code = "UK"
            if code not in @used_country_codes then code = "Other"
            browser.storageSet({country: code}, callback)
        , () ->
            callback()

    browser.onInstalled () ->
        get_location () ->
            browser.tabsCreate({"url": browser.getURL("html/options.html")})

    browser.storageOnChanged (changes) ->
        if changes.country || changes.settings
            bom_manager.init()

    window.tsvPageNotifier =
        onDotTSV : false
        re       : new RegExp("\.tsv$","i")
        items    : []
        invalid  : []
        _set_not_dotTSV: () ->
            util.badge.setDefault("")
            @onDotTSV = false
            @items    = []
            @invalid  = []
        checkPage: (callback) ->
            browser.tabsQuery {active:true, currentWindow:true}, (tabs) =>
                if tabs.length > 0
                    tab_url = tabs[0].url.split("?")[0]
                    if tabs.length >= 1 && tab_url.match(@re)
                        if /^http.?:\/\/github.com\//.test(tabs[0].url)
                            url = tab_url.replace(/blob/,"raw")
                        else if /^http.?:\/\/bitbucket.org\//.test(tabs[0].url)
                            url = tab_url.split("?")[0].replace(/src/,"raw")
                        else
                            url = tab_url
                        util.get url, {notify:false}, (event) =>
                            {items, invalid} = parseTSV(event.target.responseText)
                            if items.length > 0
                                util.badge.setDefault("\u2191", "#0000FF")
                                @onDotTSV = true
                                @items    = items
                                @invalid  = invalid
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
                    window.bom_manager._add_to_bom(@items, @invalid,callback)

    browser.tabsOnUpdated () =>
        tsvPageNotifier.checkPage()

    sendState = () ->
        bom_manager.getBOM (bom) ->
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
        paste () ->
            sendState()

    messenger.on "loadFromPage", () ->
        tsvPageNotifier.addToBOM () ->
            sendState()

    window.Test = (module)->
        url = browser.getURL("html/test.html")
        url += "?module=" + module if module?
        window.open(url)
