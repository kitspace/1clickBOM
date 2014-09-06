# This file is part of 1clickBOM.
#
# 1clickBOM is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License version 3
# as published by the Free Software Foundation.
#
# 1clickBOM is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with 1clickBOM.  If not, see <http://www.gnu.org/licenses/>.

countries_data = get_local("/data/countries.json")

window.paste = () ->
    textarea = document.getElementById("pastebox")
    textarea.select()
    document.execCommand("paste")
    bom_manager.addToBOM(textarea.value)

get_location = (callback) ->
    url = "https://freegeoip.net/json/"
    get url, (event) ->
        response = JSON.parse(event.target.responseText)
        chrome.storage.local.set {country: countries_data[response.country_name]}, ()->
            callback()
    , () ->
        callback()

chrome.runtime.onInstalled.addListener (details)->
    switch details.reason
        when "install", "upgrade"
            get_location () ->
                chrome.tabs.create({"url": chrome.runtime.getURL("html/options.html")})

window.bom_manager = new BomManager

chrome.storage.onChanged.addListener (changes, namespace) ->
    if namespace == "local"
        if changes.country || changes.settings
            window.bom_manager = new BomManager

class TSVPageNotifier
    constructor: ->
        @onDotTSV = false
        @re = new RegExp("\.tsv$","i")
        @checkPage()
        @items   = []
        @invalid = []
        chrome.tabs.onUpdated.addListener () =>
            @checkPage()
        chrome.tabs.onActivated.addListener () =>
            @checkPage()
        chrome.windows.onFocusChanged.addListener () =>
            @checkPage()
    _set_not_dotTSV: () ->
        badge.setDefault("")
        @onDotTSV = false
        @items    = []
        @invalid  = []
    checkPage: (callback) ->
        chrome.tabs.query {active:true, currentWindow:true}, (tabs) =>

            tab_url = tabs[0].url.split("?")[0]
            if tabs.length >= 1 && tab_url.match(@re)
                if /^http.?:\/\/github.com\//.test(tabs[0].url)
                    url = tab_url.replace(/blob/,"raw")
                else if /^http.?:\/\/bitbucket.org\//.test(tabs[0].url)
                    url = tab_url.split("?")[0].replace(/src/,"raw")
                else
                    url = tab_url
                get url, (event) =>
                    {items, invalid} = parseTSV(event.target.responseText)
                    if items.length > 0
                        badge.setDefault("\u2191", "#0000FF")
                        @onDotTSV = true
                        @items    = items
                        @invalid  = invalid
                    else
                        @_set_not_dotTSV()
                , () =>
                    @_set_not_dotTSV()
                , item=null, notify=false
            else
                @_set_not_dotTSV()
            if callback?
                callback()
    addToBOM: () ->
        @checkPage () =>
            if @onDotTSV
                window.bom_manager._add_to_bom(@items, @invalid)

window.tsvPageNotifier = new TSVPageNotifier

