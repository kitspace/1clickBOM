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


window.browser = {
    sendMessage:(obj, callback) ->
        chrome.runtime.sendMessage(object, callback)
    onMessage:(callback) ->
        chrome.runtime.onMessage(callback)
    storageGet:(keys, callback) ->
        chrome.storage.local.get(keys, callback)
    storageSet:(obj, callback) ->
        chrome.storage.local.set(obj, callback)
    storageRemove:(key) ->
        chrome.storage.local.remove(key)
    storageOnChanged:(callback) ->
        chrome.storage.onChanged.addListener (changes, namespace) ->
            if namespace == "local"
                callback(changes)
    tabsQuery:(obj, callback) ->
        chrome.tabs.query(obj, callback)
    tabsUpdate:(tab_id, obj) ->
        chrome.tabs.update(tab_id, obj)
    tabsReload:(tab_id) ->
        chrome.tabs.reload(tab_id)
    tabsHighlight:(tab_numbers) ->
        chrome.tabs.highlight({tabs:tab_numbers}, (window)->)
    tabsCreate:(obj) ->
        chrome.tabs.create(obj)
    tabsOnUpdated:(callback) ->
        chrome.tabs.onUpdated.addListener(callback)
        chrome.tabs.onActivated.addListener(callback)
        chrome.windows.onFocusChanged.addListener(callback)
    cookiesGetAll: (obj, callback) ->
        chrome.cookies.getAll(obj, callback)
    cookiesRemove: (obj, callback) ->
        chrome.cookies.remove(obj, callback)
    cookiesSet: (obj, callback) ->
        chrome.cookies.set(obj, callback)
    getBackgroundPage: (callback) ->
        chrome.runtime.getBackgroundPage(callback)
    getURL:(url) ->
        return chrome.extension.getURL(url)
    onInstalled:(callback) ->
        chrome.runtime.onInstalled.addListener (details)->
            if details.reason == "install"
                callback()
    setBadge:(obj) ->
        if obj.color?
            chrome.browserAction.setBadgeBackgroundColor({color:obj.color})
        if obj.text?
            chrome.browserAction.setBadgeText ({text:obj.text})
    notificationsCreate:(obj, callback) ->
        chrome.notifications.create "", obj, callback
}

class Badge
    constructor:() ->
        @decaying_set = false
        @priority = 0
        @default_text = ""
        @default_color = "#0000FF"
        window.browser.setBadge({text:@default_text})
    setDecaying: (text, color="#0000FF", priority = 1) ->
        if priority >= @priority
            if @decaying_set && @id > 0
                clearTimeout(@id)
            @_set(text, color, priority)
            @id = setTimeout () =>
                @decaying_set = false
                @_set(@default_text, @default_color, 0)
            , 5000
    setDefault: (text, color="#0000FF", priority = 0) ->
        if priority >= @priority
            @_set(text, color, priority)
        @default_color = color
        @default_text = text
    _set: (text, color, priority) ->
        window.browser.setBadge({color:color, text:text})
        @priority = priority

window.badge = new Badge
