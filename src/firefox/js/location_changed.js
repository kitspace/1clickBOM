const tabs = require('sdk/tabs')
const {viewFor} = require('sdk/view/core')
const {modelFor} = require('sdk/model/core')
const {Ci, Cu} = require('chrome')
const {getBrowserForTab, getTabForContentWindow} = require('sdk/tabs/utils')
Cu.import('resource://gre/modules/XPCOMUtils.jsm', this)

let listeners = []
let progressListener = {
    QueryInterface: XPCOMUtils.generateQI([
        Ci.nsIWebProgressListener,
        Ci.nsISupportsWeakReference
    ]),
    onLocationChange(aProgress, aRequest, aURI) {
        let high_level_tab = modelFor(
            getTabForContentWindow(aProgress.DOMWindow)
        )
        return listeners.map(callback => callback(high_level_tab))
    }
}

function attach(tab) {
    let low_level_tab = viewFor(tab)
    let browser = getBrowserForTab(low_level_tab)
    return browser.addProgressListener(progressListener)
}

//attach the tab location changed notifier to all existing tabs
for (let i = 0; i < tabs.length; i++) {
    let tab = tabs[i]
    attach(tab)
}

tabs.on('open', attach)

exports.on = function on(callback) {
    return listeners.push(callback)
}
