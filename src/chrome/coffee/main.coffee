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

# tests only work in chrome currently, open a console on background and execute
# Test() or test a specific module, e.g. Farnell, with Test('Farnell')
window.Test = (module)->
    url = browser.getURL('html/test.html')
    url += '?module=' + module if module?
    window.open(url)

window.clear = () ->
    browser.storageRemove 'bom' , () ->

background(messenger)
