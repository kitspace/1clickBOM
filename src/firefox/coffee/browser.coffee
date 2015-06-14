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

{storage} = require 'sdk/simple-storage'
{data   } = require 'sdk/self'

storageListeners = []
browser =
    storageGet:(keys, callback) ->
        ret = {}
        console.log(storage)
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
    tabsQuery:(obj, callback) ->
    tabsUpdate:(tab_id, obj) ->
    tabsReload:(tab_id) ->
    tabsHighlight:(tab_numbers) ->
    tabsCreate:(obj) ->
    tabsOnUpdated:(callback) ->
    cookiesGetAll: (obj, callback) ->
    cookiesRemove: (obj, callback) ->
    cookiesSet: (obj, callback) ->
    getLocal:(url, json=true)->
        s = data.load(url)
        if json
            return JSON.parse(s)
        else
            return s
    onInstalled:(callback) ->
    setBadge:(obj) ->
    notificationsCreate:(obj, callback) ->

exports.browser = browser
