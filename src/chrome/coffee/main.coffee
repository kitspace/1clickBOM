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

        if details.previousVersion != "0.5.0"
            chrome.notifications.create 'update-notification',
                type:'basic'
                title:'New UI and auto-complete!'
                message:"Hope you like the new look. Be sure to try out 1clickBOM's
                    new feature that searches Octopart and Findchips.com for you."
                isClickable:true
                iconUrl:'/images/logo128.png'

            chrome.notifications.onClicked.addListener (id) ->
                if (id == 'update-notification')
                    browser.tabsCreate('http://1clickBOM.com')

# tests only work in chrome currently, open a console on background and execute
# Test() or test a specific module, e.g. Farnell, with Test('Farnell')
window.Test = (module)->
    url = browser.getURL('html/test.html')
    url += '?module=' + module if module?
    window.open(url)

window.findchips = require('./findchips').search

window.clear = () ->
    browser.storageRemove 'bom' , () ->

background(messenger)
