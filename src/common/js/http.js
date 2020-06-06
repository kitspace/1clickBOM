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
const Promise = require('./bluebird')
Promise.config({cancellation: true})

const {browser, XMLHttpRequest} = require('./browser')
const {badge} = require('./badge')

function network_callback(event, callback, error_callback, notify = true) {
    if (event.target.readyState === 4) {
        if (event.target.status === 200) {
            if (callback != null) {
                return callback(event.target.responseText)
            }
        } else {
            let message = event.target.status + '\n'
            message += event.target.url
            if (notify) {
                browser.notificationsCreate(
                    {
                        type: 'basic',
                        title: 'Network Error Occured',
                        message,
                        iconUrl: '/images/net_error.png'
                    },
                    function() {}
                )
                badge.setDecaying(`${event.target.status}`, '#CC00FF', 3)
            }
            if (error_callback != null) {
                return error_callback(event)
            }
        }
    }
}

function post(url, params, options, callback, error_callback) {
    if (options == null) {
        options = {}
    }
    let {notify, timeout, json} = options
    if (notify == null) {
        notify = true
    }
    if (timeout == null) {
        timeout = 60000
    }
    if (json == null) {
        json = false
    }
    const xhr = new XMLHttpRequest()
    xhr.open('POST', url, true)
    if (json) {
        xhr.setRequestHeader('Content-type', 'application/JSON')
    } else {
        xhr.setRequestHeader(
            'Content-type',
            'application/x-www-form-urlencoded'
        )
    }
    xhr.url = url
    xhr.onreadystatechange = event => {
        network_callback(event, callback, error_callback, notify)
    }
    xhr.timeout = timeout
    xhr.ontimedout = event => {
        network_callback(event, callback, error_callback, notify)
    }
    return xhr.send(params)
}

function get(url, {notify, timeout}, callback, error_callback) {
    if (notify == null) {
        notify = false
    }
    if (timeout == null) {
        timeout = 60000
    }
    const xhr = new XMLHttpRequest()
    xhr.open('GET', url, true)
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
    xhr.url = url
    xhr.onreadystatechange = event =>
        network_callback(event, callback, error_callback, notify)
    xhr.timeout = timeout
    xhr.ontimedout = event =>
        network_callback(event, callback, error_callback, notify)
    return xhr.send()
}

function getLocation(callback) {
    const used_country_codes = []
    const countries_data = require('./data/countries.json')
    for (const _ in countries_data) {
        const code = countries_data[_]
        used_country_codes.push(code)
    }
    const url = 'https://freegeoip.kitspace.org'
    return get(
        url,
        {timeout: 30000},
        responseText => {
            const response = JSON.parse(responseText)
            let code = response.country_code
            if (code === 'GB') {
                code = 'UK'
            }
            if (!__in__(code, used_country_codes)) {
                code = 'Other'
            }
            return browser.prefsSet({country: code}, callback)
        },
        () => callback()
    )
}

function promisePost(url, params, options) {
    return new Promise((resolve, reject) => {
        post(url, params, options, resolve, reject)
    })
}

function promiseGet(url) {
    return new Promise((resolve, reject) => {
        get(
            url,
            {},
            responseText => resolve(browser.parseDOM(responseText)),
            reject
        )
    })
}

exports.post = post
exports.get = get
exports.promisePost = promisePost
exports.promiseGet = promiseGet
exports.getLocation = getLocation

function __in__(needle, haystack) {
    return haystack.indexOf(needle) >= 0
}
