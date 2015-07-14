{messenger}   = require './messenger'
{background}  = require './background'
{getLocation} = require './http'
{browser}     = require './browser'

chrome.runtime.onInstalled.addListener (details)->
    if details.reason == "install"
        getLocation () ->
            browser.tabsCreate(browser.getURL("html/options.html"))

background(messenger)
