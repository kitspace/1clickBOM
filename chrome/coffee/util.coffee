
class Badge
    constructor:() ->
        @badge_set = false
        @priority = 0
        chrome.browserAction.setBadgeText({text:""})
    set: (text, color, priority = 0) ->
        that = this
        if priority >= @priority
            chrome.browserAction.setBadgeBackgroundColor({color:color})
            chrome.browserAction.setBadgeText({text:text})
            @priority = priority
            if @badge_set && @id > 0
                clearTimeout(@id)
            @id = setTimeout () ->
                that.badge_set = false
                that.priority = 0
                chrome.browserAction.setBadgeText({text:""})
            , 5000
            @badge_set = true

@badge = new Badge


@get_local = (url, json=true)->
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
                error_callback()

@post = (url, params, callback, item, json=false, error_callback) ->
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

@post_sync = (url, params, callback, item, json=false) ->
    xhr = new XMLHttpRequest
    xhr.open("POST", url, false)
    if item?
        xhr.item = item
    else
        xhr.item = null
    if (json)
        xhr.setRequestHeader("Content-type", "application/JSON")
    else
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    xhr.url = url
    xhr.send(params)



@get = (url, callback, error_callback, item=null) ->
    xhr = new XMLHttpRequest
    xhr.item = item
    xhr.open("GET", url, true)
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    xhr.url = url
    xhr.onreadystatechange = (event) ->
        network_callback event, callback, error_callback
    xhr.send()

@trim_whitespace = (str) ->
    return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '')

@DOM = new DOMParser()
@DOM.parse = (str) ->
    DOM.parseFromString(str, "text/html")
