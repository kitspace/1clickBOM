@get_local = (url, json=true)->
    xhr = new XMLHttpRequest()
    xhr.open("GET", chrome.extension.getURL(url), false)
    xhr.send()
    if xhr.status == 200
        if (json)
            return JSON.parse(xhr.responseText)
        else
            return xhr.responseText

window.onerror = (msg, url, line) ->
    chrome.storage.local.get ["error_log"], ({error_log:error_log}) ->
        if not (error_log?)
            error_log = []
        error_log.push({msg:msg, url:url, line:line})
        chrome.storage.local.set {error_log:error_log}, () ->

window.getErrorLog = () ->
    chrome.storage.local.get ["error_log"], ({error_log:error_log}) ->
        console.log(error_log)
