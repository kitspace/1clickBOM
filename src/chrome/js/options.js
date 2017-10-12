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

const {browser} = require('./browser')

const countries_data = require('./data/countries.json')
const settings_data = require('./data/settings.json')

function save_options() {
    const select = document.getElementById('country')
    const country = select.children[select.selectedIndex].value
    const {settings} = document
    if (settings_data[country]) {
        if (!settings[country]) {
            settings[country] = {}
        }
        for (const retailer in settings_data[country]) {
            const checked = document.querySelector(
                `input[name=${retailer}]:checked`
            )
            if (checked) {
                settings[country][retailer] = {}
                settings[country][retailer]['site'] = checked.value
            }
        }
    }
    return browser.prefsSet({country, settings}, () => load_options())
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

        const select = document.getElementById('country')
        for (let i = 0; i < select.children.length; i++) {
            const child = select.children[i]
            if (child.value === stored.country) {
                child.selected = 'true'
                break
            }
        }

        const form = document.getElementById('settings')
        while (form.hasChildNodes()) {
            form.removeChild(form.lastChild)
        }
        return (() => {
            const result = []
            for (const retailer in settings_data[stored.country]) {
                const choices =
                    settings_data[stored.country][retailer].site.options
                const _default =
                    settings_data[stored.country][retailer].site.value
                const div = document.createElement('div')
                const div2 = document.createElement('div')
                div2.className = 'heading_2'
                const h3 = document.createElement('h3')
                h3.innerHTML = retailer
                div2.appendChild(h3)
                div.appendChild(div2)
                form.appendChild(div)
                for (let index = 0; index < choices.length; index++) {
                    const choice = choices[index]
                    const radio = document.createElement('input')
                    radio.type = 'radio'
                    radio.name = retailer
                    radio.value = choice.value
                    radio.id = `id_${choice.value}`
                    radio.label = choice.label
                    const div = document.createElement('div')
                    div.appendChild(radio)
                    div.innerHTML += choice.label
                    div.style = 'cursor: pointer;'
                    div.onclick = function(mouse_event) {
                        const child = mouse_event.target.firstChild
                        if (child != null) {
                            if (child.type === 'radio') {
                                child.checked = 'checked'
                                return save_options()
                            }
                        }
                    }

                    form.appendChild(div)
                }
                if (
                    stored.settings != null &&
                    stored.settings[stored.country] != null &&
                    Boolean(Object.keys(stored.settings[stored.country]).length)
                ) {
                    const id = `id_${stored.settings[stored.country][retailer]
                        .site}`
                    var selected = document.getElementById(id)
                } else {
                    var selected = document.getElementById(`id_${_default}`)
                }
                if (selected != null) {
                    selected.checked = 'checked'
                }
                result.push(
                    [].slice
                        .call(document.getElementsByTagName('input'))
                        .map(input => (input.onclick = save_options))
                )
            }
            return result
        })()
    })

const select = document.getElementById('country')
for (const name in countries_data) {
    const code = countries_data[name]
    const opt = document.createElement('option')
    opt.innerHTML = name
    opt.value = code
    select.appendChild(opt)
}

document.addEventListener('DOMContentLoaded', load_options)
document.getElementById('country').onchange = save_options
