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

element_Bom         = document.querySelector("#bom")
element_Table       = document.querySelector("#bom_table")
button_Clear        = document.querySelector("button#clear")
button_FillCarts    = document.querySelector("button#fill_carts")
button_EmptyCarts   = document.querySelector("button#empty_carts")
button_OpenCartTabs = document.querySelector("button#open_cart_tabs")
button_LoadFromPage = document.querySelector("button#load_from_page")
button_Paste        = document.querySelector("button#paste")

button_Clear.addEventListener "click", () ->
    messenger.send("clearBOM")

button_FillCarts.addEventListener "click", () ->
    @disabled = true
    messenger.send("fillCarts")

button_EmptyCarts.addEventListener "click", () ->
    @disabled = true
    messenger.send("emptyCarts")

button_OpenCartTabs.addEventListener "click", () ->
    messenger.send("openCarts")

button_Paste.addEventListener "click", () ->
    messenger.send("paste")

button_LoadFromPage.addEventListener "click", () ->
    messenger.send("loadFromPage")

hideOrShow = (bom, onDotTSV) ->
    button_Clear.hidden        = !Boolean(Object.keys(bom).length)
    button_FillCarts.hidden    = !Boolean(Object.keys(bom).length)
    button_EmptyCarts.hidden   = !Boolean(Object.keys(bom).length)
    button_OpenCartTabs.hidden = !Boolean(Object.keys(bom).length)
    button_LoadFromPage.hidden = !onDotTSV
    element_Bom.hidden         = !Boolean(Object.keys(bom).length)

startSpinning = (link) ->
    td = link.parentNode
    counter = 0
    spinner = document.createElement("div")
    spinner.className = "spinner"
    td.appendChild(spinner)
    link.interval_id = setInterval ()->
        frames     = 12
        frameWidth = 15
        offset     = counter * -frameWidth
        spinner.style.backgroundPosition=
            offset + "px" + " " + 0 + "px"
        counter++
        if (counter>=frames)
            counter = 0
    , 50
    link.hidden=true
    link.spinning=true

stopSpinning = (link) ->
    if link.spinning? && link.spinning
        td            = link.parentNode
        spinner       = td.querySelector("div.spinner")
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
    for retailer_name of bom
        items = bom[retailer_name]
        retailer = state.bom_manager.interfaces[retailer_name]
        no_of_items = 0
        for item in items
            no_of_items += item.quantity
        tr = document.createElement("tr")
        element_Table.appendChild(tr)
        td_0 = document.createElement("td")

        icon = document.createElement("img")
        icon.src = retailer.icon_src
        td_0.appendChild(icon)
        td_0.innerHTML += retailer.interface_name
        tr.appendChild(td_0)

        td_1 = document.createElement("td")
        td_1.innerText = items.length + " line"
        td_1.innerText += "s" if (items.length > 1)
        tr.appendChild(td_1)

        td_2 = document.createElement("td")
        td_2.innerText = no_of_items + " item"
        td_2.innerText += "s" if (no_of_items > 1)
        tr.appendChild(td_2)
        td = document.createElement("td")

        unicode_chars = ["\uf21e", "\uf221", "\uf21b"]
        titles = ["Add items to " , "View ",  "Empty "]
        links = []
        for i in  [0..2]
            td = document.createElement("td")
            a = document.createElement("a")
            a.value = retailer.interface_name
            a.title = titles[i] + retailer.interface_name + " cart"
            a.href = "#"
            span = document.createElement("span")
            span.className = "button_icon"
            span.innerText = unicode_chars[i]
            a.appendChild(span)
            td.appendChild(a)
            tr.appendChild(td)
            links.push(a)

        links[0].addEventListener "click", () ->
            startSpinning(this)
            messenger.send "fillCart", @value

        links[1].addEventListener "click", () ->
            messenger.send "openCart", @value

        links[2].addEventListener "click", () ->
            startSpinning(this)
            messenger.send "emptyCart", @value

        if retailer.adding_items
            startSpinning(links[0])
        else
            stopSpinning(links[0])

        if retailer.clearing_cart
            startSpinning(links[2])
        else
            stopSpinning(links[2])

        any_adding   |= retailer.adding_items
        any_emptying |= retailer.clearing_cart

    button_FillCarts.disabled  = any_adding
    button_EmptyCarts.disabled = any_emptying

messenger.on "sendBackgroundState", (state) ->
    render(state)

messenger.send("getBackgroundState")
