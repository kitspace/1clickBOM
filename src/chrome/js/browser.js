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

const dom = new DOMParser()

const browser = {
    storageGet(keys, callback) {
        return new Promise((resolve, reject) => {
            chrome.storage.local.get(keys, result => {
                resolve(result)
                callback && callback(result)
            })
        })
    },
    storageSet(obj, callback) {
        return new Promise((resolve, reject) => {
            chrome.storage.local.set(obj, () => {
                resolve()
                callback && callback()
            })
        })
    },
    prefsGet(keys, callback) {
        return this.storageGet(keys, callback)
    },
    prefsSet(obj, callback) {
        return this.storageSet(keys, callback)
    },
    storageRemove(key, callback) {
        return new Promise((resolve, reject) => {
            chrome.storage.local.remove(key, () => {
                resolve()
                callback && callback()
            })
        })
    },
    prefsOnChanged(keys, callback) {
        return chrome.storage.onChanged.addListener((changes, namespace) => {
            if (
                namespace === 'local' &&
                keys.filter(x => x in changes).length > 0
            ) {
                callback()
            }
        })
    },
    tabsGetActive(callback) {
        return chrome.tabs.query({active: true, currentWindow: true}, tabs => {
            if (tabs.length >= 1) {
                callback(tabs[0])
            } else {
                callback(null)
            }
        })
    },
    tabsQuery(obj, callback) {
        return new Promise((resolve, reject) => {
            chrome.tabs.query(obj, tabs => {
                resolve(tabs)
                callback && callback(tabs)
            })
        })
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
        chrome.windows.onFocusChanged.addListener(callback)
    },
    getURL(url) {
        return chrome.extension.getURL(url)
    },
    setBadge(obj) {
        if (obj.color != null) {
            chrome.browserAction.setBadgeBackgroundColor({color: obj.color})
        }
        if (obj.text != null) {
            chrome.browserAction.setBadgeText({text: obj.text})
        }
    },
    notificationsCreate(obj, callback) {
        return chrome.notifications.create('', obj, callback)
    },
    paste() {
        const textarea = document.getElementById('pastebox')
        console.log('textarea', textarea)
        textarea.focus()
        document.execCommand('Paste')
        console.log(textarea.value)
        return textarea.value
    },
    copy(text) {
        const textarea = document.getElementById('pastebox')
        textarea.value = text
        textarea.select()
        document.execCommand('SelectAll')
        return document.execCommand('Cut')
    },
    setTimeout(callback, time) {
        return setTimeout(callback, time)
    },
    clearTimeout(id) {
        return clearTimeout(id)
    },
    parseDOM(str) {
        return dom.parseFromString(str, 'text/html')
    },
    getCookies(obj) {
        return new Promise((resolve, reject) => {
            chrome.cookies.getAll(obj, cookies => {
                if (cookies == null) {
                    reject()
                } else {
                    resolve(cookies)
                }
            })
        })
    },
    setCookie(cookie) {
        return new Promise((resolve, reject) => {
            chrome.cookies.set(cookie, details => {
                if (details == null) {
                    reject()
                } else {
                    resolve(details)
                }
            })
        })
    },
    removeCookie(obj) {
        return new Promise((resolve, reject) => {
            chrome.cookies.remove(obj, details => {
                if (details == null) {
                    reject()
                } else {
                    resolve(details)
                }
            })
        })
    }
}

exports.browser = browser
exports.XMLHttpRequest = XMLHttpRequest
