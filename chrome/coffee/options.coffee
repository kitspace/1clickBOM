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
    sub_settings = document.sub_settings
    if(sub_settings_data[country])
        for retailer of sub_settings_data[country]
            checked = document.querySelector("input[name='" + retailer + "']:checked")
            if (checked)
                sub_settings[retailer] = checked.value
    chrome.storage.local.set {country: country, sub_settings: sub_settings}, () ->
        load_options()
        if (!chrome.runtime.lastError)
            status = document.getElementById "status"
            status.innerHTML = "Options Saved."
            setTimeout ()->
                status.innerHTML = ""
            , 750

            load_options()

load_options = () ->
    chrome.storage.local.get ["sub_settings", "country"], (stored) ->
        if (!stored.country)
            stored.country = "Other"
        if (stored.sub_settings?)
            document.sub_settings = stored.sub_settings
        else
            document.sub_settings = {}
        select = document.getElementById("country")
        for child in select.children
            if child.value == stored.country
                child.selected = "true"
                form = document.getElementById("sub_settings")
                form.removeChild(form.lastChild) while form.hasChildNodes()
                for retailer of sub_settings_data[stored.country]
                    choices = sub_settings_data[stored.country][retailer].choices
                    _default = sub_settings_data[stored.country][retailer].default
                    div = document.createElement("div")
                    div.innerHTML = retailer + ":"
                    form.appendChild(div)
                    for choice of choices
                        radio = document.createElement("input")
                        radio.type = "radio"
                        radio.name = retailer
                        radio.value = choice
                        radio.id = "id_" + choice
                        div = document.createElement("div")
                        div.appendChild(radio)
                        div.innerHTML += choices[choice].text
                        form.appendChild(div)
                    if (stored.sub_settings?)
                        id = "id_" + stored.sub_settings[retailer]
                        selected = document.getElementById(id)
                    else
                        selected = document.getElementById("id_" + _default)
                    selected.checked = "checked"
                    input.onclick = save_options for input in document.getElementsByTagName("input")
                break

xhr = new XMLHttpRequest()
xhr.open "GET", chrome.extension.getURL("/data/countries.json"), false
xhr.send()
if xhr.status == 200
    countries = JSON.parse xhr.responseText

xhr = new XMLHttpRequest()
xhr.open("GET", chrome.extension.getURL("/data/sub_settings.json"), false)
xhr.send()
if xhr.status == 200
    sub_settings_data = JSON.parse(xhr.responseText)

select = document.getElementById("country")
for name, code of countries
    opt = document.createElement("option")
    opt.innerHTML = name
    opt.value = code
    select.appendChild(opt)

document.addEventListener("DOMContentLoaded", load_options)
document.getElementById("country").onchange = save_options


#chrome.storage.onChanged.addListener (changes, namespace) ->
#    if (namespace == "local")
#        if (changes.country || changes.sub_settings)
#            load_options()
