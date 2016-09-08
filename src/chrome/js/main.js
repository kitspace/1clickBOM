import { messenger } from './messenger';
import { background } from './background';
import { getLocation } from './http';
import { browser } from './browser';

chrome.runtime.onInstalled.addListener(function(details){
    if (details.reason === 'install') {
        getLocation(() => browser.tabsCreate(browser.getURL('html/options.html')));
        //set-up settings with default values
        let set_scheme = browser.getLocal('data/settings.json');
        let settings = {};
        for (let country in set_scheme) {
            let retailers = set_scheme[country];
            settings[country] = {};
            for (let retailer in retailers) {
                let setting_names = retailers[retailer];
                settings[country][retailer] = {};
                for (let setting in setting_names) {
                    let info = setting_names[setting];
                    settings[country][retailer][setting] = info.value;
                }
            }
        }
        return browser.prefsSet({settings});
    }
});

// tests only work in chrome currently, open a console on background and execute
// Test() or test a specific module, e.g. Farnell, with Test('Farnell')
window.Test = function(module){
    let url = browser.getURL('html/test.html');
    if (module != null) { url += `?module=${module}`; }
    return window.open(url);
};

window.clear = () => browser.storageRemove('bom' , function() {});

background(messenger);
