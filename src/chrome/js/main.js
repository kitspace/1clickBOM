const {messenger} = require('./messenger')
const {background} = require('./background')
const http = require('./http')
const {browser} = require('./browser')
const set_scheme = require('./data/settings.json')

chrome.runtime.onInstalled.addListener(function(details) {
    if (details.reason === 'install') {
        browser.tabsQuery({url: '*://kitspace.org/boards/*'}, tabs => {
            tabs.forEach(browser.tabsReload)
        })
        http.getLocation()
        //set-up settings with default values
        const settings = {}
        for (const country in set_scheme) {
            const retailers = set_scheme[country]
            settings[country] = {}
            for (const retailer in retailers) {
                const setting_names = retailers[retailer]
                settings[country][retailer] = {}
                for (const setting in setting_names) {
                    const info = setting_names[setting]
                    settings[country][retailer][setting] = info.value
                }
            }
        }
        return browser.prefsSet({settings})
    }
})

// tests only work in chrome currently, open a console on background and execute
// Test() or test a specific module, e.g. Farnell, with Test('Farnell')
window.Test = function(module) {
    let url = browser.getURL('html/test.html')
    if (module != null) {
        url += `?module=${module}`
    }
    return window.open(url)
}

window.clear = () => browser.storageRemove('bom', function() {})

background(messenger)
