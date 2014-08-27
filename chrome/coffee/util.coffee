@get_local = (url, json=true)->
    xhr = new XMLHttpRequest()
    xhr.open("GET", chrome.extension.getURL(url), false)
    xhr.send()
    if xhr.status == 200
        if (json)
            return JSON.parse(xhr.responseText)
        else
            return xhr.responseText

@post = (url, params, callback, item, json=false, error_callback) ->
    xhr = new XMLHttpRequest
    xhr.open("POST", url, true)
    if item?
        xhr.item = item

    if (json)
        xhr.setRequestHeader("Content-type", "application/JSON")
    else
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")

    xhr.url = url

    xhr.onreadystatechange = (event) ->
        if event.target.readyState == 4
            if event.target.status == 200
                if callback?
                    callback(event)
            else
                if error_callback?
                    error_callback()
                message = event.target.status + "\n"
                message += xhr.url
                chrome.notifications.create "network_error", {type:"basic", title:"Network Error Occured", message:message, iconUrl:""}, () ->
    xhr.send(params)

@get = (url, callback, error_callback) ->
    xhr = new XMLHttpRequest
    xhr.open("GET", url, true)
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    xhr.url = url
    xhr.onreadystatechange = (event) ->
        if event.target.readyState == 4
            if event.target.status == 200
                if callback?
                    callback(event)
            else
                if error_callback?
                    error_callback()
                message = event.target.status + "\n"
                message += xhr.url
                chrome.notifications.create "network_error", {type:"basic", title:"Network Error Occured", message:message, iconUrl:""}, () ->
    xhr.send()

@trim_whitespace = (str) ->
    return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '')

@DOM = new DOMParser()
@DOM.parse = (str) ->
    DOM.parseFromString(str, "text/html")
