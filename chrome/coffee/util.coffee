# This file is part of 1clickBOM.
#
# 1clickBOM is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License version 3
# as published by the Free Software Foundation.
#
# 1clickBOM is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with 1clickBOM.  If not, see <http://www.gnu.org/licenses/>.

class Badge
    constructor:() ->
        @badge_set = false
        @priority = 0
        @default_text = ""
        @default_color = "#0000FF"
        chrome.browserAction.setBadgeText({text:@default_text})
    set: (text, color="#0000FF", priority = 0) ->
        if priority >= @priority
            if @badge_set && @id > 0
                clearTimeout(@id)
            @_set(text, color, priority)
            @id = setTimeout () =>
                @badge_set = false
                @_set(@default_text, @default_color, 0)
            , 5000
    _set: (text, color, priority) ->
            chrome.browserAction.setBadgeBackgroundColor({color:color})
            chrome.browserAction.setBadgeText({text:text})
            @priority = priority
            @badge_set = true
    setPermanent: (text, color="#0000FF", priority = 0) ->
        if priority >= @priority
            @_set(text, color, priority)
        @default_color = color
        @default_text = text

window.badge = new Badge

window.get_local = (url, json=true)->
    xhr = new XMLHttpRequest()
    xhr.open("GET", chrome.extension.getURL(url), false)
    xhr.send()
    if xhr.status == 200
        if (json)
            return JSON.parse(xhr.responseText)
        else
            return xhr.responseText

network_callback = (event, callback, error_callback) ->
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
            chrome.notifications.create "", {type:"basic", title:"Network Error Occured", message:message, iconUrl:"/images/net_error128.png"}, () ->

            badge.set("" + event.target.status, "#CC00FF", priority=2)
            if error_callback?
                error_callback(event.target.item)

window.post = (url, params, callback, item, json=false, error_callback) ->
    xhr = new XMLHttpRequest
    xhr.open("POST", url, true)
    if item?
        xhr.item = item
    else
        xhr.item = null
    if (json)
        xhr.setRequestHeader("Content-type", "application/JSON")
    else
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    xhr.url = url
    xhr.onreadystatechange = (event) ->
        network_callback event, callback, error_callback
    xhr.send(params)

window.get = (url, callback, error_callback, item=null) ->
    xhr = new XMLHttpRequest
    xhr.item = item
    xhr.open("GET", url, true)
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    xhr.url = url
    xhr.onreadystatechange = (event) ->
        network_callback event, callback, error_callback
    xhr.send()

window.trim_whitespace = (str) ->
    return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '')

window.DOM = new DOMParser()
window.DOM.parse = (str) ->
    DOM.parseFromString(str, "text/html")
