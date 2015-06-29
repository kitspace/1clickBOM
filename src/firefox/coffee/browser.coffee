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

{storage}        = require 'sdk/simple-storage'
{data   }        = require 'sdk/self'
{XMLHttpRequest} = require 'sdk/net/xhr'
clipboard        = require 'sdk/clipboard'
notifications    = require 'sdk/notifications'
{Cc, Ci}         = require 'chrome'
{ActionButton}   = require 'sdk/ui/button/action'
locationChanged  = require './locationChanged'
firefoxTabs      = require 'sdk/tabs'
windowUtils      = require 'sdk/window/utils'
tabsUtils        = require 'sdk/tabs/utils'
{modelFor}       = require 'sdk/model/core'
{setTimeout, clearTimeout} = require 'sdk/timers'

popup = require("sdk/panel").Panel(
    contentURL: data.url("html/popup.html")
    contentScriptFile: [data.url("popup.js")]
)

globToRegex = (glob) ->
    specialChars = "\\^$*+?.()|{}[]"
    regexChars = ["^"]
    for c in glob
        switch c
            when '?'
                regexChars.push('.')
            when '*'
                regexChars.push('.*')
            else
                if (specialChars.indexOf(c) >= 0)
                    regexChars.push('\\')
                regexChars.push(c)
    regexChars.push("$")
    return new RegExp(regexChars.join(""))

button = ActionButton(
    id:"bom_button",
    label:"1clickBOM",
    icon :
        "16": "./images/button16.png"
        "32": "./images/button32.png"
    onClick: (state) ->
        popup.show({position:button})
)

popup.on "show", () ->
    popup.port.emit("show")

storageListeners = []
browser =
    storageGet:(keys, callback) ->
        ret = {}
        for k in keys
            ret[k] = storage[k]
        callback(ret)
    storageSet:(obj, callback) ->
        for k of obj
            storage[k] = obj[k]
        for listener in storageListeners
            listener(obj)
        if callback?
            callback()
    storageRemove:(key, callback) ->
        delete storage[key]
        obj = {}
        obj[key] = undefined
        for listener in storageListeners
            listener(obj)
        if callback?
            callback()
    storageOnChanged:(callback) ->
        storageListeners.push(callback)
    tabsGetActive:(callback) ->
        callback(firefoxTabs.activeTab)
    tabsQuery:({url, currentWindow}, callback) ->
        if currentWindow? && currentWindow
            current = windowUtils.getMostRecentBrowserWindow()
            tabs = []
            for tab in tabsUtils.getTabs(current)
                tabs.push(modelFor(tab))
        else
            tabs = firefoxTabs
        matches = []
        for tab in tabs
            if tab.url.match(globToRegex(url))?
                matches.push(tab)
        callback(matches)
    tabsUpdate:(tab, url) ->
        tab.url = url
    tabsReload:(tab) ->
        tab.reload()
    tabsActivate:(tab) ->
        tab.activate()
    tabsCreate:(obj) ->
        firefoxTabs.open(obj.url)
    tabsOnUpdated:(callback) ->
        firefoxTabs.on 'activate', callback
        locationChanged.on(callback)
    cookiesGetAll: (obj, callback) ->
    cookiesRemove: (obj, callback) ->
    cookiesSet: (obj, callback) ->
    getURL: (url) ->
    getLocal:(url, json=true)->
        s = data.load(url)
        if json
            return JSON.parse(s)
        else
            return s
    onInstalled:(callback) ->
    setBadge:({color, text}) ->
        button.badge = text
        button.badgeColor = color
    notificationsCreate:(obj, callback) ->
        ffObj =
            title   : obj.title
            text    : obj.message
            iconURL : "." + obj.iconUrl
        notifications.notify(ffObj)
    paste:(callback) ->
        c = clipboard.get()
        if not c?
            return ""
        else
            return c
    setTimeout: (callback, time) ->
        setTimeout(callback, time)
    clearTimeout: (id) ->
        clearTimeout(id)

DOM = Cc["@mozilla.org/xmlextras/domparser;1"].createInstance(Ci.nsIDOMParser)
DOM.parse = (str) ->
    DOM.parseFromString(str, "text/html")

exports.browser        = browser
exports.XMLHttpRequest = XMLHttpRequest
exports.DOM            = DOM
exports.popup          = popup
