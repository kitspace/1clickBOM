// The contents of this file are subject to the Common Public Attribution
// License Version 1.0 (the “License”); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
// License Version 1.1 but Sections 14 and 15 have been added to cover use of
// software over a computer network and provide for limited attribution for the
// Original Developer. In addition, Exhibit A has been modified to be consistent
// with Exhibit B.
//
// Software distributed under the License is distributed on an
// "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
// the License for the specific language governing rights and limitations under
// the License.
//
// The Original Code is 1clickBOM.
//
// The Original Developer is the Initial Developer. The Original Developer of
// the Original Code is Kaspar Emanuel.

let dom = new DOMParser()

let browser = {
    storageGet(keys, callback) {
        return chrome.storage.local.get(keys, callback)
    },
    storageSet(obj, callback) {
        return chrome.storage.local.set(obj, callback)
    },
    prefsGet(keys, callback) {
        return chrome.storage.local.get(keys, callback)
    },
    prefsSet(obj, callback) {
        return chrome.storage.local.set(obj, callback)
    },
    storageRemove(key, callback) {
        return chrome.storage.local.remove(key, function() {
            if (callback != null) {
                return callback()
            }
        }
        )
    },
    prefsOnChanged(keys, callback) {
        return chrome.storage.onChanged.addListener(function(changes, namespace) {
            if (namespace === 'local' && (keys.filter(x => x in changes).length > 0)) {
                return callback()
            }
        })
    },
    tabsGetActive(callback) {
        return chrome.tabs.query({active:true, currentWindow:true}, function(tabs) {
            if (tabs.length >= 1) {
                return callback(tabs[0])
            } else {
                return callback(null)
            }
        }
        )
    },
    tabsQuery(obj, callback) {
        return chrome.tabs.query(obj, callback)
    },
    tabsUpdate(tab, url) {
        return chrome.tabs.update(tab.id, {url})
    },
    tabsReload(tab) {
        return chrome.tabs.reload(tab.id)
    },
    tabsActivate(tab) {
        return chrome.tabs.update(tab.id, {active: true})
    },
    tabsCreate(url) {
        return chrome.tabs.create({url, active: true})
    },
    tabsOnUpdated(callback) {
        chrome.tabs.onUpdated.addListener(callback)
        chrome.tabs.onActivated.addListener(callback)
        return chrome.windows.onFocusChanged.addListener(callback)
    },
    getBackgroundPage(callback) {
        return chrome.runtime.getBackgroundPage(callback)
    },
    getURL(url) {
        return chrome.extension.getURL(url)
    },
    setBadge(obj) {
        if (obj.color != null) {
            chrome.browserAction.setBadgeBackgroundColor({color:obj.color})
        }
        if (obj.text != null) {
            return chrome.browserAction.setBadgeText(({text:obj.text}))
        }
    },
    notificationsCreate(obj, callback) {
        return chrome.notifications.create('', obj, callback)
    },
    paste() {
        let textarea = document.getElementById('pastebox')
        textarea.select()
        document.execCommand('paste')
        return textarea.value
    },
    copy(text) {
        let textarea = document.getElementById('pastebox')
        textarea.value = text
        textarea.select()
        document.execCommand('SelectAll')
        return document.execCommand('Copy')
    },
    setTimeout(callback, time) {
        return setTimeout(callback, time)
    },
    clearTimeout(id) {
        return clearTimeout(id)
    },
    parseDOM(str) {
        return dom.parseFromString(str, 'text/html')
    }
}

exports.browser = browser
exports.XMLHttpRequest = XMLHttpRequest
