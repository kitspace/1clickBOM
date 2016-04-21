# The contents of this file are subject to the Common Public Attribution
# License Version 1.0 (the “License”); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
# License Version 1.1 but Sections 14 and 15 have been added to cover use of
# software over a computer network and provide for limited attribution for the
# Original Developer. In addition, Exhibit A has been modified to be consistent
# with Exhibit B.
#
# Software distributed under the License is distributed on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations under
# the License.
#
# The Original Code is 1clickBOM.
#
# The Original Developer is the Initial Developer. The Original Developer of
# the Original Code is Kaspar Emanuel.

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

#temporary; pre-defining to determine if my lack of coffeescript knowledge is the problem
loadFromPartNumber = (info, tab)-> 
  debugger
  messenger.send('loadFromPartNumber', info.selectionText)


chrome.contextMenus.create({ 
  'title'    : '1clickBOM: select a part number to add',
  'contexts' : ['page'], 
  })

root = chrome.contextMenus.create({ 
  'title'    : '1clickBOM',
  'contexts' : ['selection'], 
  }, () ->
    chrome.contextMenus.create({
      'title': 'Add by part number: "%s" then Auto-Complete to further specify',
      'contexts': ['selection'],
      'parentId': root,
      'onclick'  : loadFromPartNumber 
    })
  )
  #onclick: (evt) -> chrome.tabs.create({ url: evt.pageUrl })


# tests only work in chrome currently, open a console on background and execute
# Test() or test a specific module, e.g. Farnell, with Test('Farnell')
window.Test = (module)->
    url = browser.getURL('html/test.html')
    url += '?module=' + module if module?
    window.open(url)

window.clear = () ->
    browser.storageRemove 'bom' , () ->

background(messenger)
