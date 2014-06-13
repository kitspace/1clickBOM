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

@paste = () ->
    textarea = document.getElementById("pastebox")
    textarea.select()
    document.execCommand("paste")
    bom_manager.addToBOM(textarea.value)

get_location = ()->
    xhr = new XMLHttpRequest
    xhr.open "GET", "https://freegeoip.net/json/", true
    xhr.onreadystatechange = (data) ->
        if xhr.readyState == 4 
            if xhr.status == 200
                response = JSON.parse(xhr.responseText)
                chrome.storage.local.set {country: countries_data[response.country_name]}, ()->
                    chrome.tabs.create({"url": chrome.runtime.getURL("html/options.html")})
            else #freegeoip is down
                chrome.tabs.create({"url": chrome.runtime.getURL("html/options.html")})
    xhr.send()

chrome.runtime.onInstalled.addListener (details)->
    switch details.reason
        when "install", "upgrade"
            get_location()

@bom_manager = new BomManager

chrome.storage.onChanged.addListener (changes, namespace) ->
    if namespace == "local"
        if changes.country || changes.settings
            @bom_manager = new BomManager
