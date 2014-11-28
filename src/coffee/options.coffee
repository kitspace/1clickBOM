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

countries_data = window.get_local("/data/countries.json")
settings_data  = window.get_local("/data/settings.json")

save_options = () ->
    select = document.getElementById("country")
    country = select.children[select.selectedIndex].value
    settings = document.settings
    if(settings_data[country])
        if (!settings[country])
            settings[country] = {}
        for retailer of settings_data[country]
            checked = document.querySelector("input[name='" + retailer + "']:checked")
            if (checked)
                settings[country][retailer] = checked.value
    browser.storageSet {country: country, settings: settings}, () ->
        load_options()

load_options = () ->
    browser.storageGet ["settings", "country"], (stored) ->
        if (!stored.country)
            stored.country = "Other"

        if (stored.settings?)
            document.settings = stored.settings
        else
            document.settings = {}

        select = document.getElementById("country")
        for child in select.children
            if child.value == stored.country
                child.selected = "true"
                break

        form = document.getElementById("settings")
        form.removeChild(form.lastChild) while form.hasChildNodes()
        for retailer of settings_data[stored.country]
            choices = settings_data[stored.country][retailer].choices
            _default = settings_data[stored.country][retailer].default
            div = document.createElement("div")
            div2 = document.createElement("div")
            div2.className = "heading_2"
            h2 = document.createElement("h2")
            h2.innerHTML = retailer
            div2.appendChild(h2)
            div.appendChild(div2)
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
                div.className = "radio_text"
                div.onclick = (mouse_event) ->
                    child = mouse_event.toElement.firstChild
                    if(child?)
                        if (child.type == "radio")
                            child.checked = "checked"
                            save_options()

                form.appendChild(div)
            if (stored.settings? && (stored.settings[stored.country]?) && (Boolean(Object.keys(stored.settings[stored.country]).length)))
                id = "id_" + stored.settings[stored.country][retailer]
                selected = document.getElementById(id)
            else
                selected = document.getElementById("id_" + _default)
            selected.checked = "checked"
            input.onclick = save_options for input in document.getElementsByTagName("input")

select = document.getElementById("country")
for name, code of countries_data
    opt = document.createElement("option")
    opt.innerHTML = name
    opt.value = code
    select.appendChild(opt)

document.addEventListener("DOMContentLoaded", load_options)
document.getElementById("country").onchange = save_options
