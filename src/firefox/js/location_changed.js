import tabs from 'sdk/tabs';
import { viewFor } from 'sdk/view/core';
import { modelFor } from 'sdk/model/core';
import { Ci, Cu } from 'chrome';
import { getBrowserForTab, getTabForContentWindow } from 'sdk/tabs/utils';
Cu.import('resource://gre/modules/XPCOMUtils.jsm', this);

let listeners = [];
let progressListener = {
    QueryInterface: XPCOMUtils.generateQI([Ci.nsIWebProgressListener, Ci.nsISupportsWeakReference]),
    onLocationChange(aProgress, aRequest, aURI) {
        let high_level_tab = modelFor(getTabForContentWindow(aProgress.DOMWindow));
        return listeners.map((callback) =>
            callback(high_level_tab));
    }
};

let attach = function(tab) {
    let low_level_tab = viewFor(tab);
    let browser       = getBrowserForTab(low_level_tab);
    return browser.addProgressListener(progressListener);
};

//attach the tab location changed notifier to all existing tabs
for (let i = 0; i < tabs.length; i++) {
    let tab = tabs[i];
    attach(tab);
}

tabs.on('open', attach);

export function on(callback) {
    return listeners.push(callback);
}
