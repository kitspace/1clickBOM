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
{retailer_list, isComplete} = require './retailer_list'

element_Bom         = document.querySelector('#bom')
element_Table       = document.querySelector('#bom_table')
element_TotalLines  = document.querySelector('#total_lines')
element_TotalPartNumbers  = document.querySelector('#total_partNumbers')
element_TotalManufacturers  = document.querySelector('#total_manufacturers')
element_TotalItems  = document.querySelector('#total_items')
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

button_Complete.addEventListener 'click', () ->
    messenger.send('autoComplete')


hideOrShow = (bom, onDotTSV) ->
    hasBOM = Boolean(Object.keys(bom.items).length)

    button_Clear.disabled      = not hasBOM
    button_Complete.disabled   = (not hasBOM) or isComplete(bom.items)
    button_Copy.disabled       = not hasBOM

    button_LoadFromPage.hidden = not onDotTSV


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
    element_TotalLines.innerHTML = "#{bom.items.length}
        line#{if bom.items.length != 1 then 's' else ''}"
    part_numbers = bom.items.reduce (prev, item) ->
        prev += item.partNumber != ''
    , 0
    element_TotalPartNumbers.innerHTML = "#{part_numbers} with MPN"
    manufacturers = bom.items.reduce (prev, item) ->
        prev += item.manufacturer != ''
    , 0
    element_TotalManufacturers.innerHTML = "#{manufacturers} with M/F"
    quantity = 0
    for item in bom.items
        quantity += item.quantity
    element_TotalItems.innerHTML = "#{quantity}
        item#{if quantity != 1 then 's' else ''}"
    while element_Table.hasChildNodes()
        element_Table.removeChild(element_Table.lastChild)
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
        viewCart = document.createElement('a')
        viewCart.appendChild(icon)
        viewCart.innerHTML += retailer.name
        viewCart.value = retailer.name
        td_0.value = retailer.name
        td_0.addEventListener 'click', () ->
            messenger.send('openCart', @value)
        td_0.appendChild(viewCart)
        td_0.id = 'icon'
        tr.appendChild(td_0)

        td_1 = document.createElement('td')
        t  = "#{items.length}"
        tspan = document.createElement('span')
        tspan.appendChild(document.createTextNode(t))

        if items.length != bom.items.length
            td_1.style.backgroundColor = 'pink'

        t2 = " line#{if items.length != 1 then 's' else ''}"
        t2span = document.createElement('span')
        t2span.appendChild(document.createTextNode(t2))

        td_1.appendChild(tspan)
        td_1.appendChild(t2span)
        tr.appendChild(td_1)

        unicode_chars = ['\uf21b', '\uf21e']
        titles = ['Empty ', 'Add items to ']
        messages = ['emptyCart', 'fillCart']
        lookup = ['clearing_cart', 'adding_items']
        for i in  [0..1]
            td = document.createElement('td')
            td.className = 'button_icon_td'
            tr.appendChild(td)
            span = document.createElement('span')
            span.className = 'button_icon'
            span.appendChild(document.createTextNode(unicode_chars[i]))
            if (messages[i] == 'fillCart' and items.length == 0)
                span.style = "color: grey;"
                td.appendChild(span)
            else
                a = document.createElement('a')
                a.value = retailer.name
                a.message = messages[i]
                a.title = titles[i] + retailer.name + ' cart'
                a.href = '#'
                a.appendChild(span)
                a.addEventListener 'click', () ->
                    startSpinning(this)
                    messenger.send(@message, @value)
                td.appendChild(a)
                if retailer[lookup[i]]
                    startSpinning(a)


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
