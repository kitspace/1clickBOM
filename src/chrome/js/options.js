// The contents of this file are subject to the Common Public Attribution
// License Version 1.0 (the “License”); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
// License Version 1.1 but Sections 14 and 15 have been added to cover use of
// software over a computer network and provide for limited attribution for the
// Original Developer. In addition, Exhibit A has been modified to be consistent
// with Exhibit B.
//
// Software distributed under the License is distributed on an
// "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
// the License for the specific language governing rights and limitations under
// the License.
//
// The Original Code is 1clickBOM.
//
// The Original Developer is the Initial Developer. The Original Developer of
// the Original Code is Kaspar Emanuel.

const { browser } = require('./browser')

let countries_data = browser.getLocal('data/countries.json')
let settings_data  = browser.getLocal('data/settings.json')

let save_options = function() {
    let select = document.getElementById('country')
    let country = select.children[select.selectedIndex].value
    let { settings } = document
    if(settings_data[country]) {
        if (!settings[country]) {
            settings[country] = {}
        }
        for (let retailer in settings_data[country]) {
            let checked = document.querySelector(`input[name=${retailer}]:checked`)
            if (checked) {
                settings[country][retailer] = {}
                settings[country][retailer]['site'] = checked.value
            }
        }
    }
    return browser.prefsSet({country, settings}, () => load_options()
    )
}

var load_options = () =>
    browser.prefsGet(['settings', 'country'], function(stored) {
        if (!stored.country) {
            stored.country = 'Other'
        }

        if (stored.settings != null) {
            document.settings = stored.settings
        } else {
            document.settings = {}
        }

        let select = document.getElementById('country')
        for (let i = 0; i < select.children.length; i++) {
            let child = select.children[i]
            if (child.value === stored.country) {
                child.selected = 'true'
                break
            }
        }

        let form = document.getElementById('settings')
        while (form.hasChildNodes()) { form.removeChild(form.lastChild); }
        return (() => {
            let result = []
            for (let retailer in settings_data[stored.country]) {
                let choices = settings_data[stored.country][retailer].site.options
                let _default = settings_data[stored.country][retailer].site.value
                let div = document.createElement('div')
                let div2 = document.createElement('div')
                div2.className = 'heading_2'
                let h2 = document.createElement('h2')
                h2.innerHTML = retailer
                div2.appendChild(h2)
                div.appendChild(div2)
                form.appendChild(div)
                for (let index = 0; index < choices.length; index++) {
                    let choice = choices[index]
                    let radio = document.createElement('input')
                    radio.type = 'radio'
                    radio.name = retailer
                    radio.value = choice.value
                    radio.id = `id_${choice.value}`
                    div = document.createElement('div')
                    div.appendChild(radio)
                    div.innerHTML += choice.label
                    div.className = 'radio_text'
                    div.onclick = function(mouse_event) {
                        let child = mouse_event.toElement.firstChild
                        if(child != null) {
                            if (child.type === 'radio') {
                                child.checked = 'checked'
                                return save_options()
                            }
                        }
                    }

                    form.appendChild(div)
                }
                if ((stored.settings != null) && (stored.settings[stored.country] != null) && (Boolean(Object.keys(stored.settings[stored.country]).length))) {
                    let id = `id_${stored.settings[stored.country][retailer].site}`
                    var selected = document.getElementById(id)
                } else {
                    var selected = document.getElementById(`id_${_default}`)
                }
                if (selected != null) {
                    selected.checked = 'checked'
                }
                result.push([].slice.call(document.getElementsByTagName('input')).map((input) => input.onclick = save_options))
            }
            return result
        })()
    }
    )


let select = document.getElementById('country')
for (let name in countries_data) {
    let code = countries_data[name]
    let opt = document.createElement('option')
    opt.innerHTML = name
    opt.value = code
    select.appendChild(opt)
}

document.addEventListener('DOMContentLoaded', load_options)
document.getElementById('country').onchange = save_options
