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

window.browser = new Browser

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

window.get_local = (url, json=true)->
    xhr = new XMLHttpRequest()
    xhr.open("GET", window.browser.getURL(url), false)
    xhr.send()
    if xhr.status == 200
        if (json)
            return JSON.parse(xhr.responseText)
        else
            return xhr.responseText

network_callback = (event, callback, error_callback, notify=true) ->
    if event.target.readyState == 4
        if event.target.status == 200
            if callback?
                callback(event)
        else
            message = event.target.status + "\n"
            if event.target.item?
                item = event.target.item
                message += "Trying to process "
                message +=  item.part + " from " + item.retailer + "\n"
            else
                message += event.target.url
            if notify
                window.browser.notificationsCreate({type:"basic", title:"Network Error Occured", message:message, iconUrl:"/images/net_error128.png"}, () ->)

                badge.setDecaying("" + event.target.status, "#CC00FF", priority=3)
            if error_callback?
                error_callback(event.target.item)

window.post = (url, params, {item:item, notify:notify, timeout:timeout, json:json},  callback, error_callback) ->
    if not item?
        item=null
    if not notify?
        notify=true
    if not timeout?
        timeout=60000
    if not json?
        json=false
    xhr = new XMLHttpRequest
    xhr.open("POST", url, true)
    xhr.item = item
    if (json)
        xhr.setRequestHeader("Content-type", "application/JSON")
    else
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    xhr.url = url
    xhr.onreadystatechange = (event) ->
        network_callback(event, callback, error_callback, notify)
    xhr.timeout = timeout;
    xhr.ontimedout = (event) ->
        network_callback(event, callback, error_callback, notify)
    xhr.send(params)

window.get = (url, {item:item, notify:notify, timeout:timeout}, callback, error_callback) ->
    if not item?
        item=null
    if not notify?
        notify=false
    if not timeout?
        timeout=60000
    xhr = new XMLHttpRequest
    xhr.item = item
    xhr.open("GET", url, true)
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    xhr.url = url
    xhr.onreadystatechange = (event) ->
        network_callback(event, callback, error_callback, notify)
    xhr.timeout = timeout;
    xhr.ontimedout = (event) ->
        network_callback(event, callback, error_callback, notify)
    xhr.send()

window.trim_whitespace = (str) ->
    return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '')

window.DOM = new DOMParser()
window.DOM.parse = (str) ->
    DOM.parseFromString(str, "text/html")
