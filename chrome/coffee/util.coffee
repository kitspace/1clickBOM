@get_local = (url, json=true)->
    xhr = new XMLHttpRequest()
    xhr.open("GET", chrome.extension.getURL(url), false)
    xhr.send()
    if xhr.status == 200
        if (json)
            return JSON.parse(xhr.responseText)
        else
            return xhr.responseText

@post = (url, params, callback, item, json=false) ->
    xhr = new XMLHttpRequest
    xhr.open("POST", url, true)
    if item?
        xhr.item = item

    if (json)
        xhr.setRequestHeader("Content-type", "application/JSON")
    else 
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")

    xhr.onreadystatechange = (event) ->
        if event.target.readyState == 4
            if callback?
                callback(event)
    xhr.send(params)

@get = (url, callback) ->
    xhr = new XMLHttpRequest
    xhr.open("GET", url, true)
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    xhr.onreadystatechange = (event) ->
        if event.target.readyState == 4
            if callback?
                callback(event)
    xhr.send()
    

window.onerror = (msg, url, line) ->
    chrome.storage.local.get ["error_log"], ({error_log:error_log}) ->
        if not (error_log?)
            error_log = []
        error_log.push({msg:msg, url:url, line:line})
        chrome.storage.local.set {error_log:error_log}, () ->

window.getErrorLog = () ->
    chrome.storage.local.get ["error_log"], ({error_log:error_log}) ->
        console.log(error_log)
