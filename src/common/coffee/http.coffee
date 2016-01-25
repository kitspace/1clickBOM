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

{browser, XMLHttpRequest} = require './browser'
{badge}                   = require './badge'

network_callback = (event, callback, error_callback, notify=true) ->
    if event.target.readyState == 4
        if event.target.status == 200
            if callback?
                callback(event)
        else
            message = event.target.status + '\n'
            if event.target.line?
                line = event.target.line
                message += 'Trying to process '
                message +=  line.part + '\n'
            else
                message += event.target.url
            if notify
                browser.notificationsCreate({type:'basic', title:'Network Error Occured', message:message, iconUrl:'/images/net_error.png'}, () ->)

                badge.setDecaying('' + event.target.status, '#CC00FF', priority=3)
            if error_callback?
                error_callback(event)

post = (url, params, {line:line, notify:notify, timeout:timeout, json:json},  callback, error_callback) ->
    if not line?
        line=null
    if not notify?
        notify=true
    if not timeout?
        timeout=60000
    if not json?
        json=false
    xhr = new XMLHttpRequest
    xhr.open('POST', url, true)
    xhr.line = line
    if (json)
        xhr.setRequestHeader('Content-type', 'application/JSON')
    else
        xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
    xhr.url = url
    xhr.onreadystatechange = (event) ->
        network_callback(event, callback, error_callback, notify)
    xhr.timeout = timeout
    xhr.ontimedout = (event) ->
        network_callback(event, callback, error_callback, notify)
    xhr.send(params)

get = (url, {line:line, notify:notify, timeout:timeout}, callback, error_callback) ->
    if not line?
        line=null
    if not notify?
        notify=false
    if not timeout?
        timeout=60000
    xhr = new XMLHttpRequest
    xhr.line = line
    xhr.open('GET', url, true)
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
    xhr.url = url
    xhr.onreadystatechange = (event) ->
        network_callback(event, callback, error_callback, notify)
    xhr.timeout = timeout;
    xhr.ontimedout = (event) ->
        network_callback(event, callback, error_callback, notify)
    xhr.send()

used_country_codes = []

getLocation = (callback) ->
    used_country_codes = []
    countries_data = browser.getLocal('data/countries.json')
    for _,code of countries_data
        used_country_codes.push(code)
    url = 'http://kaspar.h1x.com:8080/json'
    get url, {timeout:5000}, (event) =>
        response = JSON.parse(event.target.responseText)
        code = response.country_code
        if code == 'GB' then code = 'UK'
        if code not in used_country_codes then code = 'Other'
        browser.prefsSet({country: code}, callback)
    , () ->
        callback()

promisePost = (url, params) ->
    new Promise (resolve, reject) ->
        post url, params, {}, (event) ->
            resolve()
        , () ->
            reject()

promiseGet = (url) ->
    new Promise (resolve, reject) ->
        get url, {}, (event) ->
            resolve(browser.parseDOM(event.target.responseText))
        , (event) ->
            reject(event)


exports.post        = post
exports.get         = get
exports.promisePost = promisePost
exports.promiseGet  = promiseGet
exports.getLocation = getLocation
