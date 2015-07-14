{messenger}   = require './messenger'
{background}  = require './background'
{getLocation} = require './http'
{browser}     = require './browser'

chrome.runtime.onInstalled.addListener (details)->
    if details.reason == "install"
        getLocation () ->
            browser.tabsCreate(browser.getURL("html/options.html"))

# tests only work in chrome currently, open a console on background and execute
# Test()
window.Test = (module)->
    url = browser.getURL("html/test.html")
    url += "?module=" + module if module?
    window.open(url)

background(messenger)
