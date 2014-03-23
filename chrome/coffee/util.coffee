@get_local = (url)->
    xhr = new XMLHttpRequest()
    xhr.open("GET", chrome.extension.getURL(url), false)
    xhr.send()
    if xhr.status == 200
        return JSON.parse(xhr.responseText)
