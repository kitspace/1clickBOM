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

clipboard        = require 'sdk/clipboard'
firefoxTabs      = require 'sdk/tabs'
notifications    = require 'sdk/notifications'
tabsUtils        = require 'sdk/tabs/utils'
windowUtils      = require 'sdk/window/utils'
{ActionButton}   = require 'sdk/ui/button/action'
{XMLHttpRequest} = require 'sdk/net/xhr'
{data   }        = require 'sdk/self'
{modelFor}       = require 'sdk/model/core'
timers           = require 'sdk/timers'
{storage}        = require 'sdk/simple-storage'
preferences      = require 'sdk/simple-prefs'
locationChanged  = require './locationChanged'
{Cc, Ci}         = require 'chrome'
dom = Cc["@mozilla.org/xmlextras/domparser;1"].createInstance(Ci.nsIDOMParser)

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

popup = require("sdk/panel").Panel(
    contentURL: data.url("html/popup.html")
    contentScriptFile: [data.url("popup.js")]
)

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

browser =
    prefsSet: (obj, callback) ->
        for k,v of obj
            preferences.prefs[k] = v
        callback()
    prefsGet: (keys, callback) ->
        ret = {}
        for k in keys
            ret[k] = preferences.prefs[k]
        callback(ret)
    prefsOnChanged: (keys, callback) ->
        for k in keys
            preferences.on k, (prefName) ->
                callback()
    storageGet:(keys, callback) ->
        ret = {}
        for k in keys
            ret[k] = storage[k]
        callback(ret)
    storageSet:(obj, callback) ->
        for k of obj
            storage[k] = obj[k]
        if callback?
            callback()
    storageRemove:(key, callback) ->
        delete storage[key]
        obj = {}
        obj[key] = undefined
        if callback?
            callback()
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
    tabsCreate:(url) ->
        firefoxTabs.open(url)
    tabsOnUpdated:(callback) ->
        firefoxTabs.on 'activate', callback
        locationChanged.on(callback)
    getURL: (url) ->
        data.url(url)
    getLocal:(url, json=true)->
        s = data.load(url)
        if json
            return JSON.parse(s)
        else
            return s
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
        timers.setTimeout(callback, time)
    clearTimeout: (id) ->
        timers.clearTimeout(id)
    parseDOM: (str) ->
        dom.parseFromString(str, "text/html")

exports.browser        = browser
exports.XMLHttpRequest = XMLHttpRequest
exports.popup          = popup
