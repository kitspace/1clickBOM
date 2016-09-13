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
const Promise = require('./bluebird');
Promise.config({cancellation:true});

const { browser, XMLHttpRequest } = require('./browser');
const { badge } = require('./badge');

let network_callback = function(event, callback, error_callback, notify=true) {
    if (event.target.readyState === 4) {
        if (event.target.status === 200) {
            if (callback != null) {
                return callback(event);
            }
        } else {
            let message = event.target.status + '\n';
            if (event.target.line != null) {
                let { line } = event.target;
                message += 'Trying to process ';
                message +=  line.part + '\n';
            } else {
                message += event.target.url;
            }
            if (notify) {
                let priority;
                browser.notificationsCreate({type:'basic', title:'Network Error Occured', message, iconUrl:'/images/net_error.png'}, function() {});

                badge.setDecaying(`${event.target.status}`, '#CC00FF', priority=3);
            }
            if (error_callback != null) {
                return error_callback(event);
            }
        }
    }
};

let post = function(url, params, {line, notify, timeout, json},  callback, error_callback) {
    if (line == null) {
        line=null;
    }
    if (notify == null) {
        notify=true;
    }
    if (timeout == null) {
        timeout=60000;
    }
    if (json == null) {
        json=false;
    }
    let xhr = new XMLHttpRequest();
    xhr.open('POST', url, true);
    xhr.line = line;
    if (json) {
        xhr.setRequestHeader('Content-type', 'application/JSON');
    } else {
        xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    }
    xhr.url = url;
    xhr.onreadystatechange = event => network_callback(event, callback, error_callback, notify);
    xhr.timeout = timeout;
    xhr.ontimedout = event => network_callback(event, callback, error_callback, notify);
    return xhr.send(params);
};

let get = function(url, {line, notify, timeout}, callback, error_callback) {
    if (line == null) {
        line=null;
    }
    if (notify == null) {
        notify=false;
    }
    if (timeout == null) {
        timeout=60000;
    }
    let xhr = new XMLHttpRequest();
    xhr.line = line;
    xhr.open('GET', url, true);
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    xhr.url = url;
    xhr.onreadystatechange = event => network_callback(event, callback, error_callback, notify);
    xhr.timeout = timeout;
    xhr.ontimedout = event => network_callback(event, callback, error_callback, notify);
    return xhr.send();
};

let used_country_codes = [];

let getLocation = function(callback) {
    used_country_codes = [];
    let countries_data = browser.getLocal('data/countries.json');
    for (let _ in countries_data) {
        let code = countries_data[_];
        used_country_codes.push(code);
    }
    let url = 'https://freegeoip.kitnic.it';
    return get(url, {timeout:5000}, event => {
        let response = JSON.parse(event.target.responseText);
        let code = response.country_code;
        if (code === 'GB') { code = 'UK'; }
        if (!__in__(code, used_country_codes)) { code = 'Other'; }
        return browser.prefsSet({country: code}, callback);
    }
    , () => callback()
    );
};

let promisePost = (url, params) =>
    new Promise((resolve, reject) =>
        post(url, params, {}, event => resolve()
        , () => reject()
        )
    )
;

let promiseGet = url =>
    new Promise((resolve, reject) =>
        get(url, {}, event => resolve(browser.parseDOM(event.target.responseText))
        , event => reject(event)
        )
    )
;


exports.post        = post;
exports.get         = get;
exports.promisePost = promisePost;
exports.promiseGet  = promiseGet;
exports.getLocation = getLocation;

function __in__(needle, haystack) {
  return haystack.indexOf(needle) >= 0;
}
