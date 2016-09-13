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

const clipboard = require('sdk/clipboard');
const firefoxTabs = require('sdk/tabs');
const notifications = require('sdk/notifications');
const tabsUtils = require('sdk/tabs/utils');
const windowUtils = require('sdk/window/utils');
const { ActionButton } = require('sdk/ui/button/action');
const { XMLHttpRequest } = require('sdk/net/xhr');
const { data } = require('sdk/self');
const { modelFor } = require('sdk/model/core');
const timers = require('sdk/timers');
const { storage } = require('sdk/simple-storage');
const preferences = require('sdk/simple-prefs');
const pageMod = require('sdk/page-mod');
const locationChanged = require('./location_changed');
const { Cc, Ci } = require('chrome');
let dom = Cc['@mozilla.org/xmlextras/domparser;1'].createInstance(Ci.nsIDOMParser);

let globToRegex = function(glob) {
    let specialChars = '\\^$*+?.()|{}[]';
    let regexChars = ['^'];
    for (let i = 0; i < glob.length; i++) {
        let c = glob[i];
        switch (c) {
            case '?':
                regexChars.push('.');
                break;
            case '*':
                regexChars.push('.*');
                break;
            default:
                if (specialChars.indexOf(c) >= 0) {
                    regexChars.push('\\');
                }
                regexChars.push(c);
        }
    }
    regexChars.push('$');
    return new RegExp(regexChars.join(''));
};

let popup = require('sdk/panel').Panel({
    contentURL: data.url('html/popup.html'),
    contentScriptFile: [data.url('popup.js')],
    width: 280,
    height: 320
});

let button = ActionButton({
    id:'bom_button',
    label:'1clickBOM',
    icon : {
        '16': './images/button16.png',
        '32': './images/button32.png'
    },
    onClick(state) {
        return popup.show({position:button});
    }
});

popup.on('show', () => popup.port.emit('show')
);

let preference_listeners = {};


let message_exchange = {adders:[], receivers:[]};
pageMod.PageMod({
    include: RegExp('https?://(.+\.)?kitnic.it/boards/.*', 'i'),
    contentScriptFile: data.url('kitnic.js'),
    onAttach(worker) {
        if (!__in__(worker, message_exchange.receivers)) {
            message_exchange.receivers.push(worker);
            worker.on('detach', function() {
                let index = message_exchange.receivers.indexOf(this);
                if (index >= 0) {
                    return message_exchange.receivers.splice(index, 1);
                }
            }
            );
        }
        return message_exchange.adders.map((add) =>
            add(worker));
    }
});

let browser = {
    prefsSet(obj, callback) {
        for (let k in obj) {
            let v = obj[k];
            preferences.prefs[k] = v;
        }
        return callback();
    },
    prefsGet(keys, callback) {
        let ret = {};
        //give preferences a faux object hierarchy so
        // {'settings.UK.Farnell':''} becomes {settings:{UK:{Farnell:''}}}
        for (let k in preferences.prefs) {
            let v = preferences.prefs[k];
            if (/\./.test(k)) {
                let ks = k.split('.');
                ks.reduce(function(prev, curr, i, arr) {
                    if (i === (arr.length - 1)) {
                        return prev[curr] = v;
                    } else {
                        return prev[curr] = {};
                    }
                }
                , ret);
            } else {
                ret[k] = v;
            }
        }
        return callback(ret);
    },
    prefsOnChanged(keys, callback) {
        return keys.map((key) =>
            (preference_listeners[key] != null) ?
                preference_listeners[key].push(callback)
            :
                preference_listeners[key] = [callback]);
    },
    storageGet(keys, callback) {
        let ret = {};
        for (let i = 0; i < keys.length; i++) {
            let key = keys[i];
            if (storage[key] != null) {
                ret[key] = JSON.parse(JSON.stringify(storage[key]));
            }
        }
        return callback(ret);
    },
    storageSet(obj, callback) {
        for (let k in obj) {
            storage[k] = obj[k];
        }
        if (callback != null) {
            return callback();
        }
    },
    storageRemove(key, callback) {
        delete storage[key];
        let obj = {};
        obj[key] = undefined;
        if (callback != null) {
            return callback();
        }
    },
    tabsGetActive(callback) {
        return callback(firefoxTabs.activeTab);
    },
    tabsQuery({url, currentWindow}, callback) {
        if ((currentWindow != null) && currentWindow) {
            let current = windowUtils.getMostRecentBrowserWindow();
            var tabs = [];
            let iterable = tabsUtils.getTabs(current);
            for (let i = 0; i < iterable.length; i++) {
                var tab = iterable[i];
                tabs.push(modelFor(tab));
            }
        } else {
            var tabs = firefoxTabs;
        }
        let matches = [];
        for (let j = 0; j < tabs.length; j++) {
            var tab = tabs[j];
            if (tab.url.match(globToRegex(url)) != null) {
                matches.push(tab);
            }
        }
        return callback(matches);
    },
    tabsUpdate(tab, url) {
        return tab.url = url;
    },
    tabsReload(tab) {
        return tab.reload();
    },
    tabsActivate(tab) {
        return tab.activate();
    },
    tabsCreate(url) {
        return firefoxTabs.open(url);
    },
    tabsOnUpdated(callback) {
        firefoxTabs.on('activate', callback);
        return locationChanged.on(callback);
    },
    getURL(url) {
        return data.url(url);
    },
    getLocal(url, json=true){
        let s = data.load(url);
        if (json) {
            return JSON.parse(s);
        } else {
            return s;
        }
    },
    setBadge({color, text}) {
        button.badge = text;
        return button.badgeColor = color;
    },
    notificationsCreate(obj, callback) {
        let ffObj = {
            title   : obj.title,
            text    : obj.message,
            iconURL : `.${obj.iconUrl}`
        };
        if (obj.type === 'list') {
            for (let j = 0; j < obj.items.length; j++) {
                let i = obj.items[j];
                ffObj.text += `\n${i.title}`;
            }
        }
        return notifications.notify(ffObj);
    },
    paste(callback) {
        let c = clipboard.get('text');
        if (c == null) {
            return '';
        } else {
            return c;
        }
    },
    copy(text) {
        return clipboard.set(text, 'text');
    },
    setTimeout(callback, time) {
        return timers.setTimeout(callback, time);
    },
    clearTimeout(id) {
        return timers.clearTimeout(id);
    },
    parseDOM(str) {
        return dom.parseFromString(str, 'text/html');
    }
};

preferences.on('', prefName =>
    (() => {
        let result = [];
        for (let name in preference_listeners) {
            let callbacks = preference_listeners[name];
            let item;
            if ((RegExp(`^${name}`)).test(prefName)) {
                item = callbacks.map((callback) =>
                    callback());
            }
            result.push(item);
        }
        return result;
    })()

);

exports.browser = browser;
exports.XMLHttpRequest = XMLHttpRequest;
exports.popup = popup;
exports.message_exchange = message_exchange;

function __in__(needle, haystack) {
  return haystack.indexOf(needle) >= 0;
}