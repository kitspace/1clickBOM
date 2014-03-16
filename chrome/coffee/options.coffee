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

save_options = () ->
    select = document.getElementById("country")
    country = select.children[select.selectedIndex].value
    site_settings = document.site_settings 
    if(options_data[country])
        for retailer of options_data[country]
            checked = document.querySelector("input[name='" + retailer + "']:checked")
            if (checked)
                site_settings[retailer] = checked.value
    chrome.storage.local.set {country: country, site_settings: site_settings}, () ->
        restore_options()
        if (!chrome.runtime.lastError)
            status = document.getElementById "status"
            status.innerHTML = "Options Saved."
            setTimeout ()->
                status.innerHTML = ""
            , 750

            restore_options()

restore_options = () ->
    chrome.storage.local.get "country", (obj) ->
        stored_country = obj.country
        if (!stored_country) 
            return
        select = document.getElementById("country")
        for child in select.children
            if child.value == stored_country
                child.selected = "true"
                sub_options = document.getElementById("sub_options")
                sub_options.removeChild(sub_options.lastChild) while sub_options.hasChildNodes() 
                for retailer of options_data[stored_country]
                    settings = options_data[stored_country][retailer]["settings"]
                    _default = options_data[stored_country][retailer]["default"]
                    div = document.createElement("div")
                    div.innerHTML = retailer + ":" 
                    sub_options.appendChild(div)
                    for choice of settings
                        radio = document.createElement("input")
                        radio.type = "radio"
                        radio.name = retailer
                        radio.value = choice
                        radio.id = "id_" + choice
                        radio.onclicked = save_options
                        div = document.createElement("div")
                        div.appendChild(radio)
                        div.innerHTML += settings[choice].text
                        sub_options.appendChild(div)
                    chrome.storage.local.get "site_settings", (obj) ->
                        document.site_settings = obj.site_settings
                        if (!obj.site_settings)
                            checked = document.getElementById("id_" + _default)
                            checked.checked = "checked"
                        else
                            id = "id_" + obj.site_settings[retailer]
                            checked = document.getElementById(id)
                            checked.checked = "checked"
                        input.onclick = save_options for input in document.getElementsByTagName("input")
                break

xhr = new XMLHttpRequest()
xhr.open "GET", chrome.extension.getURL("/data/countries.json"), false
xhr.send()
if xhr.status == 200
    countries = JSON.parse xhr.responseText

xhr = new XMLHttpRequest()
xhr.open("GET", chrome.extension.getURL("/data/options.json"), false)
xhr.send()
if xhr.status == 200
    options_data = JSON.parse(xhr.responseText)

select = document.getElementById("country")
for name, code of countries
    opt = document.createElement("option")
    opt.innerHTML = name 
    opt.value = code 
    select.appendChild(opt)

document.addEventListener("DOMContentLoaded", restore_options)
document.getElementById("country").onchange = save_options


#chrome.storage.onChanged.addListener (changes, namespace) ->
#    if (namespace == "local")
#        if (changes.country || changes.site_settings)
#            restore_options()
