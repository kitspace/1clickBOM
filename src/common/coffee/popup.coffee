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

{messenger} = require './messenger'
{retailer_list} = require './retailer_list'

element_Bom         = document.querySelector('#bom')
element_Table       = document.querySelector('#bom_table')
button_Clear        = document.querySelector('button#clear')
button_LoadFromPage = document.querySelector('button#load_from_page')
button_Complete     = document.querySelector('button#complete')
button_Copy         = document.querySelector('button#copy')
button_Paste        = document.querySelector('button#paste')

button_Clear.addEventListener 'click', () ->
    messenger.send('clearBOM')

button_Paste.addEventListener 'click', () ->
    messenger.send('paste')

button_LoadFromPage.addEventListener 'click', () ->
    messenger.send('loadFromPage')

button_Copy.addEventListener 'click', () ->
    messenger.send('copy')

hideOrShow = (bom, onDotTSV) ->
    hasBOM = Boolean(Object.keys(bom.retailers).length)
    button_Clear.hidden        = not hasBOM
    button_Complete.hidden     = not hasBOM
    button_Copy.hidden         = not hasBOM
    button_LoadFromPage.hidden = not onDotTSV
    element_Bom.hidden         = not hasBOM

startSpinning = (link) ->
    td = link.parentNode
    counter = 0
    spinner = document.createElement('div')
    spinner.className = 'spinner'
    td.appendChild(spinner)
    link.interval_id = setInterval ()->
        frames     = 12
        frameWidth = 15
        offset     = counter * -frameWidth
        spinner.style.backgroundPosition=
            offset + 'px' + ' ' + 0 + 'px'
        counter++
        if (counter>=frames)
            counter = 0
    , 50
    link.hidden   = true
    link.spinning = true

stopSpinning = (link) ->
    if link.spinning? && link.spinning
        td            = link.parentNode
        spinner       = td.querySelector('div.spinner')
        clearInterval(link.interval_id)
        td.removeChild(spinner)
        link.hidden   = false
        link.spinning = false

render = (state) ->
    bom = state.bom
    hideOrShow(bom, state.onDotTSV)
    while element_Table.hasChildNodes()
        element_Table.removeChild(element_Table.lastChild)
    any_adding   = false
    any_emptying = false
    for retailer_name in retailer_list
        items = []
        if retailer_name of bom.retailers
            items = bom.retailers[retailer_name]
        retailer = state.bom_manager.interfaces[retailer_name]
        no_of_items = 0
        for item in items
            no_of_items += item.quantity
        tr = document.createElement('tr')
        element_Table.appendChild(tr)
        td_0 = document.createElement('td')

        icon = document.createElement('img')
        icon.src = retailer.icon_src
        td_0.appendChild(icon)
        td_0.innerHTML += retailer.name
        td_0.id = 'icon'
        tr.appendChild(td_0)

        td_1 = document.createElement('td')
        t  = "#{items.length} line"
        t += 's' if (items.length > 1) or (items.length == 0)
        if items.length < bom.items.length
            td_1.style.color = 'red'
        else
            td_1.style.color= 'green'
        td_1.appendChild(document.createTextNode(t))
        tr.appendChild(td_1)

        unicode_chars = ['\uf21b', '\uf21e']
        titles = ['Empty ', 'Add items to ']
        links = []
        for i in  [0..1]
            td = document.createElement('td')
            a = document.createElement('a')
            a.value = retailer.name
            a.title = titles[i] + retailer.name + ' cart'
            a.href = '#'
            span = document.createElement('span')
            span.className = 'button_icon'
            span.appendChild(document.createTextNode(unicode_chars[i]))
            a.appendChild(span)
            td.appendChild(a)
            tr.appendChild(td)
            links.push(a)

        links[0].addEventListener 'click', () ->
            startSpinning(this)
            messenger.send 'emptyCart', @value

        links[1].addEventListener 'click', () ->
            startSpinning(this)
            messenger.send 'fillCart', @value

        if retailer.clearing_cart
            startSpinning(links[0])
        else
            stopSpinning(links[0])

        if retailer.adding_items
            startSpinning(links[1])
        else
            stopSpinning(links[1])

        any_adding   |= retailer.adding_items
        any_emptying |= retailer.clearing_cart

messenger.on 'sendBackgroundState', (state) ->
    render(state)

# For Firefox we forward the popup 'show' event from browser.coffee because
# this script seems get loaded once at startup not on popup. The 'show' message
# is never sent on Chrome.
messenger.on 'show', ()->
    messenger.send('getBackgroundState')

# For Chrome the whole script is instead re-executed each time the popup is
# opened.
messenger.send('getBackgroundState')
