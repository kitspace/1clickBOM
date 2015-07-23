{messenger}   = require './messenger'
{background}  = require './background'
{getLocation} = require './http'
{browser}     = require './browser'

chrome.runtime.onInstalled.addListener (details)->
    if details.reason == 'install'
        getLocation () ->
            browser.tabsCreate(browser.getURL('html/options.html'))
        #set-up settings with default values
        set_scheme = browser.getLocal('data/settings.json')
        settings = {}
        for country,retailers of set_scheme
            settings[country] = {}
            for retailer,setting_names of retailers
                settings[country][retailer] = {}
                for setting,info of setting_names
                    settings[country][retailer][setting] = info.value
        browser.prefsSet({settings:settings})
    else if details.reason == 'update'
        browser.prefsGet ['country', 'settings']
        , ({country:country, settings:stored_settings}) =>
            #allow for graceful update as settings format has changed
            if stored_settings? &&
            stored_settings.UK? &&
            stored_settings.UK.Farnell? &&
            stored_settings.UK.Farnell == 'Onecall'
                stored_settings.UK.Farnell = {site:'://onecall.farnell.com'}
            else
                stored_settings.UK.Farnell = {site:'://uk.farnell.com'}
            browser.prefsSet({settings:stored_settings}, ()->)

# tests only work in chrome currently, open a console on background and execute
# Test() or test a specific module, e.g. Farnell, with Test('Farnell')
window.Test = (module)->
    url = browser.getURL('html/test.html')
    url += '?module=' + module if module?
    window.open(url)

background(messenger)
