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


chrome.runtime.getBackgroundPage (bkgd_page) ->
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
        document.querySelector("#clear").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("#fill_carts").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("#empty_carts").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("#open_cart_tabs").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("#bom").hidden=!Boolean(Object.keys(bom).length)

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
                that = this
                start_spinning(this)
                window.bkgd_page.bom_manager.fillCart this.value, () ->
                    stop_spinning(that)

            links[1].addEventListener "click", () ->
                window.bkgd_page.bom_manager.openCart(@value)

            links[2].addEventListener "click", () ->
                that = this
                start_spinning(this)
                window.bkgd_page.bom_manager.emptyCart this.value, () ->
                    stop_spinning(that)

            table.appendChild(tr)

            spin_till_you_win(links[0], retailer_name, "adding_items")
            spin_till_you_win(links[2], retailer_name, "clearing_cart")

    bom_changed = () ->
        window.bkgd_page.bom_manager.getBOM (bom) ->
            show_or_hide_buttons(bom)
            rebuild_bom_view(bom)


    chrome.storage.onChanged.addListener (changes, namespace) ->
        bom_changed()

    bom_changed()


    chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
        if(request.invalid)
            console.log(request.invalid)

    document.querySelector("#clear").addEventListener "click", () ->
        chrome.storage.local.remove("bom")

    document.querySelector("#fill_carts").addEventListener "click", () ->
        that = this
        this.disabled = true
        window.bkgd_page.bom_manager.fillCarts () ->
                that.disabled = false
        bom_changed()
    disable_till_you_win(document.querySelector("#fill_carts"), "filling_carts")

    document.querySelector("#empty_carts").addEventListener "click", () ->
        that = this
        this.disabled = true
        window.bkgd_page.bom_manager.emptyCarts () ->
                that.disabled = false
        bom_changed()
    disable_till_you_win(document.querySelector("#empty_carts"), "emptying_carts")

    document.querySelector("#open_cart_tabs").addEventListener "click", () ->
        window.bkgd_page.bom_manager.openCarts()




