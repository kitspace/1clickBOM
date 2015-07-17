tabs       = require 'sdk/tabs'
{viewFor}  = require 'sdk/view/core'
{modelFor} = require 'sdk/model/core'
{Ci, Cu}   = require 'chrome'
{getBrowserForTab, getTabForContentWindow} = require 'sdk/tabs/utils'
Cu.import('resource://gre/modules/XPCOMUtils.jsm', this)

listeners = []
progressListener =
    QueryInterface: XPCOMUtils.generateQI([Ci.nsIWebProgressListener, Ci.nsISupportsWeakReference])
    onLocationChange: (aProgress, aRequest, aURI) ->
        high_level_tab = modelFor(getTabForContentWindow(aProgress.DOMWindow))
        for callback in listeners
            callback(high_level_tab)

attach = (tab) ->
    low_level_tab = viewFor(tab)
    browser       = getBrowserForTab(low_level_tab)
    browser.addProgressListener(progressListener)

#attach the tab location changed notifier to all existing tabs
browser.tabsQuery {url:'*'}, (tabs) ->
    for tab in tabs
        locationChanged.attach(tab)

tabs.on 'open', attach

exports.on = (callback) ->
    listeners.push(callback)
