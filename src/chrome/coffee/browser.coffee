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

dom = new DOMParser()

browser =
    storageGet:(keys, callback) ->
        chrome.storage.local.get(keys, callback)
    storageSet:(obj, callback) ->
        chrome.storage.local.set(obj, callback)
    prefsGet:(keys, callback) ->
        chrome.storage.local.get(keys, callback)
    prefsSet:(obj, callback) ->
        chrome.storage.local.set(obj, callback)
    storageRemove:(key, callback) ->
        chrome.storage.local.remove key, () ->
            if callback?
                callback()
    prefsOnChanged:(keys, callback) ->
        chrome.storage.onChanged.addListener (changes, namespace) ->
            if namespace == "local" && (keys.filter((x) -> x of changes).length > 0)
                callback()
    tabsGetActive: (callback) ->
        chrome.tabs.query {active:true, currentWindow:true}, (tabs) ->
            if tabs.length >= 1
                callback(tabs[0])
            else
                callback(null)
    tabsQuery:(obj, callback) ->
        chrome.tabs.query(obj, callback)
    tabsUpdate:(tab, url) ->
        chrome.tabs.update(tab.id, {url: url})
    tabsReload:(tab) ->
        chrome.tabs.reload(tab.id)
    tabsActivate: (tab) ->
        chrome.tabs.update(tab.id, {active: true})
    tabsCreate:(url) ->
        chrome.tabs.create({url: url, active: true})
    tabsOnUpdated:(callback) ->
        chrome.tabs.onUpdated.addListener(callback)
        chrome.tabs.onActivated.addListener(callback)
        chrome.windows.onFocusChanged.addListener(callback)
    getBackgroundPage: (callback) ->
        chrome.runtime.getBackgroundPage(callback)
    getURL: (url) ->
        chrome.extension.getURL(url)
    getLocal:(url, json=true)->
        xhr = new XMLHttpRequest()
        xhr.open("GET", chrome.extension.getURL(url), false)
        xhr.send()
        if xhr.status == 200
            if (json)
                return JSON.parse(xhr.responseText)
            else
                return xhr.responseText
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
    paste:() ->
        textarea = document.getElementById("pastebox")
        textarea.select()
        document.execCommand("paste")
        return textarea.value
    setTimeout: (callback, time) ->
        setTimeout(callback, time)
    clearTimeout: (id) ->
        clearTimeout(id)
    parseDOM: (str) ->
        dom.parseFromString(str, "text/html")

exports.browser        = browser
exports.XMLHttpRequest = XMLHttpRequest
