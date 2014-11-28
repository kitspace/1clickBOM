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

stop_spinning = (link) ->
    if link.spinning? && link.spinning
        td = link.parentNode
        spinner = td.querySelector("div.spinner")
        clearInterval(link.interval_id)
        td.removeChild(spinner)
        link.hidden=false
        link.spinning=false

start_spinning = (link) ->
    td = link.parentNode
    counter = 0
    spinner = document.createElement("div")
    spinner.className = "spinner"
    td.appendChild(spinner)
    link.interval_id = setInterval ()->
        frames=12; frameWidth = 15;
        offset=counter * -frameWidth;
        spinner.style.backgroundPosition=
            offset + "px" + " " + 0 + "px";
        counter++
        if (counter>=frames)
            counter =0;
    , 50
    link.hidden=true
    link.spinning=true

spin_till_you_win = (link, retailer_name, check_val) ->
    if window.bkgd_page.bom_manager.interfaces[retailer_name][check_val]
        start_spinning(link)
        id = setInterval () ->
            if not window.bkgd_page.bom_manager.interfaces[retailer_name][check_val]
                clearInterval(id)
                stop_spinning(link)
        , 10

disable_till_you_win = (button, check_val) ->
    if window.bkgd_page.bom_manager[check_val]
        button.disabled = true
        id = setInterval () ->
            if not window.bkgd_page.bom_manager[check_val]
                clearInterval(id)
                button.disabled = false
        , 10

window.browser.getBackgroundPage (bkgd_page) ->
    window.bkgd_page = bkgd_page
    document.querySelector("#paste").addEventListener "click", ()->
        window.bkgd_page.paste()

    #Ctrl-V event
    document.addEventListener 'keydown', (event) ->
        if ((event.keyCode == 86) && (event.ctrlKey == true))
            text = bkgd_page.paste()
            window.bkgd_page.bom_manager.addToBOM(text)

    show_or_hide_buttons = (bom) ->
        if (!bom)
            bom = {}
        document.querySelector("button#clear").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("button#fill_carts").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("button#empty_carts").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("button#open_cart_tabs").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("#bom").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("button#load_from_page").hidden = not bkgd_page.tsvPageNotifier.onDotTSV

    rebuild_bom_view = (bom) ->
        table = document.querySelector("#bom_list")
        table.removeChild(table.lastChild) while table.hasChildNodes()
        for retailer_name of bom
            retailer = window.bkgd_page.bom_manager.interfaces[retailer_name]
            items    = bom[retailer_name]
            no_of_items = 0
            for item in items
                no_of_items += item.quantity
            tr = document.createElement("tr")
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
                a.value = retailer_name
                a.title = titles[i] + retailer_name + " cart"
                a.href = "#"
                span = document.createElement("span")
                span.className = "button_icon"
                span.innerText = unicode_chars[i]
                a.appendChild(span)
                td.appendChild(a)
                tr.appendChild(td)
                links.push(a)

            links[0].addEventListener "click", () ->
                start_spinning(this)
                window.bkgd_page.bom_manager.fillCart @value, () =>
                    stop_spinning(this)

            links[1].addEventListener "click", () ->
                window.bkgd_page.bom_manager.openCart(@value)

            links[2].addEventListener "click", () ->
                start_spinning(this)
                window.bkgd_page.bom_manager.emptyCart @value, () =>
                    stop_spinning(this)

            table.appendChild(tr)

            spin_till_you_win(links[0], retailer_name, "adding_items")
            spin_till_you_win(links[2], retailer_name, "clearing_cart")

    bom_changed = () ->
        window.bkgd_page.bom_manager.getBOM (bom) ->
            show_or_hide_buttons(bom)
            rebuild_bom_view(bom)


    window.browser.storageOnChanged (changes, namespace) ->
        bom_changed()

    bom_changed()

    document.querySelector("button#clear").addEventListener "click", () ->
        window.browser.storageRemove("bom")

    document.querySelector("button#fill_carts").addEventListener "click", () ->
        @disabled = true
        window.bkgd_page.bom_manager.fillCarts () =>
            @disabled = false
        bom_changed()
    disable_till_you_win(document.querySelector("#fill_carts"), "filling_carts")

    document.querySelector("button#empty_carts").addEventListener "click", () ->
        @disabled = true
        window.bkgd_page.bom_manager.emptyCarts () =>
            @disabled = false
        bom_changed()
    disable_till_you_win(document.querySelector("#empty_carts"), "emptying_carts")

    document.querySelector("button#open_cart_tabs").addEventListener "click", () ->
        window.bkgd_page.bom_manager.openCarts()

    document.querySelector("button#load_from_page").addEventListener "click", () ->
        window.bkgd_page.tsvPageNotifier.addToBOM()



