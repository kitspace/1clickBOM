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

const {messenger} = require('./messenger')
const {browser} = require('./browser')
const {getRetailers, isComplete, hasSKUs} = require('1-click-bom-minimal')
const retailer_list = getRetailers()

const element_Bom = document.querySelector('#bom')
const element_Table = document.querySelector('#bom_table')
const element_TotalItems = document.querySelector('#total_items')
const element_TotalPartNumbers = document.querySelector('#total_partNumbers')
const element_TotalLines = document.querySelector('#total_lines')
const button_Clear = document.querySelector('button#clear')
const button_LoadFromPage = document.querySelector('button#load_from_page')
const button_DeepComplete = document.querySelector('button#deep_complete')
const button_Copy = document.querySelector('button#copy')
const button_Paste = document.querySelector('button#paste')
const button_FillCarts = document.querySelector('button#fill_carts')
const button_EmptyCarts = document.querySelector('button#empty_carts')

button_FillCarts.addEventListener('click', () => {
    this.disabled = true
    messenger.send('fillCarts')
})

button_EmptyCarts.addEventListener('click', () => {
    this.disabled = true
    messenger.send('emptyCarts')
})

button_Clear.addEventListener('click', () => {
    messenger.send('clearBOM')
})

button_Paste.addEventListener('click', e => {
    const textarea = document.getElementById('pastebox')
    textarea.select()
    document.execCommand('Paste')
})

//work-around to get the text only in firefox, no html
document.addEventListener('paste', e => {
    // cancel paste
    e.preventDefault()
    // get text representation of clipboard
    const text = e.clipboardData.getData('text/plain')
    // insert text manually
    messenger.send('paste', text)
})

button_LoadFromPage.addEventListener('click', () => {
    messenger.send('loadFromPage')
})

button_Copy.addEventListener('click', () => {
    messenger.send('copy')
})

messenger.on('copyResponse', tsv => {
    const textarea = document.getElementById('pastebox')
    textarea.value = tsv
    textarea.select()
    document.execCommand('Cut')
})

button_DeepComplete.addEventListener('click', () => {
    messenger.send('deepAutoComplete')
})

function hideOrShowButtons(bom, onDotTSV) {
    const hasBOM = Boolean(Object.keys(bom.lines).length)

    button_Clear.disabled = !hasBOM
    button_DeepComplete.disabled = !hasBOM || isComplete(bom.lines)
    button_Copy.disabled = !hasBOM

    button_LoadFromPage.hidden = !onDotTSV
}

function startSpinning(link) {
    const td = link.parentNode
    let counter = 0
    const spinner = document.createElement('div')
    spinner.className = 'spinner'
    td.appendChild(spinner)

    link.interval_id = setInterval(function() {
        const frames = 12
        const frameWidth = 15
        const offset = counter * -frameWidth
        spinner.style.backgroundPosition = offset + 'px' + ' ' + 0 + 'px'
        counter++
        if (counter >= frames) {
            return (counter = 0)
        }
    }, 50)

    link.hidden = true
    return (link.spinning = true)
}

function stopSpinning(link) {
    if (link.spinning != null && link.spinning) {
        const td = link.parentNode
        const spinner = td.querySelector('div.spinner')
        clearInterval(link.interval_id)
        td.removeChild(spinner)
        link.hidden = false
        return (link.spinning = false)
    }
}

function removeChildren(element) {
    while (element.hasChildNodes()) {
        element.removeChild(element.lastChild)
    }
}

function render(state) {
    const bom = state.bom

    hideOrShowButtons(bom, state.onDotTSV)

    removeChildren(element_TotalLines)
    element_TotalLines.appendChild(
        document.createTextNode(`${bom.lines.length}
                line${bom.lines.length !== 1 ? 's' : ''}`)
    )

    const part_numbers = bom.lines.reduce(
        (prev, line) => (prev += line.partNumbers.length > 0),
        0
    )

    removeChildren(element_TotalPartNumbers)
    element_TotalPartNumbers.appendChild(
        document.createTextNode(`${part_numbers} with MPN`)
    )

    let quantity = 0
    for (let j = 0; j < bom.lines.length; j++) {
        const line = bom.lines[j]
        quantity += line.quantity
    }

    removeChildren(element_TotalItems)
    element_TotalItems.appendChild(
        document.createTextNode(`${quantity}
        item${quantity !== 1 ? 's' : ''}`)
    )

    removeChildren(element_Table)

    let any_adding = false
    let any_emptying = false

    for (const retailer_name of retailer_list) {
        if (retailer_name === 'JLC Assembly') {
            continue
        }
        let lines = []
        if (retailer_name in bom.retailers) {
            lines = bom.retailers[retailer_name]
        }
        const retailer = state.interfaces[retailer_name]
        const tr = document.createElement('tr')
        element_Table.appendChild(tr)
        const td_0 = document.createElement('td')
        const icon = document.createElement('img')
        icon.src = browser.getURL(`images/${retailer_name.toLowerCase()}.ico`)
        const viewCart = document.createElement('a')
        viewCart.appendChild(icon)
        viewCart.innerHTML += retailer.name
        viewCart.value = retailer.name
        td_0.value = retailer.name
        td_0.addEventListener('click', function() {
            return messenger.send('openCart', this.value)
        })
        td_0.appendChild(viewCart)
        td_0.id = 'icon'
        tr.appendChild(td_0)

        const td_1 = document.createElement('td')
        const t = `${lines.length}`
        const tspan = document.createElement('span')
        tspan.appendChild(document.createTextNode(t))

        if (lines.length !== bom.lines.length) {
            td_1.style.backgroundColor = 'pink'
        }

        const t2 = ` line${lines.length !== 1 ? 's' : ''}`
        const t2span = document.createElement('span')
        t2span.appendChild(document.createTextNode(t2))

        td_1.appendChild(tspan)
        td_1.appendChild(t2span)
        tr.appendChild(td_1)

        const unicode_chars = ['\uf21e', '\uf21b']
        const titles = ['Add lines to ', 'Empty ']
        const messages = ['fillCart', 'emptyCart']
        const lookup = ['adding_lines', 'clearing_cart']
        for (let i = 0; i < 2; i++) {
            const td = document.createElement('td')
            td.className = 'button_icon_td'
            tr.appendChild(td)
            const span = document.createElement('span')
            span.className = 'button_icon'
            span.appendChild(document.createTextNode(unicode_chars[i]))
            if (messages[i] === 'fillCart' && lines.length === 0) {
                span.style.color = 'grey'
                span.style.cursor = 'default'
                td.appendChild(span)
            } else {
                const a = document.createElement('a')
                a.value = retailer.name
                a.message = messages[i]
                a.title = titles[i] + retailer.name + ' cart'
                a.href = '#'
                a.appendChild(span)
                a.addEventListener('click', function() {
                    startSpinning(this)
                    return messenger.send(this.message, this.value)
                })
                td.appendChild(a)
            }
            if (retailer[lookup[i]]) {
                startSpinning(span)
            }
            any_adding |= retailer.adding_lines
            any_emptying |= retailer.clearing_cart
        }

        button_FillCarts.disabled = any_adding || !hasSKUs(bom.lines)
        button_EmptyCarts.disabled = any_emptying
    }
}

messenger.on('sendBackgroundState', state => render(state))

// For Chrome the whole script is re-executed each time the popup is
// opened.
messenger.send('getBackgroundState')
