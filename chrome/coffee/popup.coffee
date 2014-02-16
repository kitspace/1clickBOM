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

chrome.runtime.getBackgroundPage (bkgd_page) ->
    document.querySelector("#paste").addEventListener "click", bkgd_page.paste_action 

    document.querySelector("#clear").addEventListener "click", () ->
        chrome.storage.local.remove("bom")
        clear_error_log()

    document.querySelector("#fill_carts").addEventListener "click", bkgd_page.fill_carts
    document.querySelector("#empty_carts").addEventListener "click", bkgd_page.empty_carts
    document.querySelector("#open_cart_tabs").addEventListener "click", bkgd_page.open_cart_tabs

    #Ctrl-V event
    document.addEventListener 'keydown', (event) -> 
        if ((event.keyCode == 86) && (event.ctrlKey == true))
            bkgd_page.paste_action()

    #chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
    #    console.log(request)


bom_changed = (bom) ->
    if (!bom)
        document.querySelector("#clear").hidden=true
        document.querySelector("#fill_carts").hidden=true
        document.querySelector("#empty_carts").hidden=true
        document.querySelector("#open_cart_tabs").hidden=true
        document.querySelector("#bom").hidden=true
    else
        #BOM can still be empty
        document.querySelector("#clear").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("#fill_carts").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("#empty_carts").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("#open_cart_tabs").hidden=!Boolean(Object.keys(bom).length)
        document.querySelector("#bom").hidden=!Boolean(Object.keys(bom).length)
    table = document.querySelector("#bom_list")
    table.removeChild(table.lastChild) while table.hasChildNodes() 
    for retailer_name of bom
        retailer = bom[retailer_name].interface
        items    = bom[retailer_name].items
        no_of_items = 0
        for item in items
            no_of_items += item.quantity
        console.log(no_of_items)
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
        td_3 = document.createElement("td")
        td_3.id = "per-retailer-button-td"
        for unicode_char in ["\uf21d","\uf1b1","\uf21b"] 
            button = document.createElement("button")
            span = document.createElement("span")
            span.className = "button-icon"
            span.innerText = unicode_char 
            button.appendChild(span)
            td_3.appendChild(button)
        tr.appendChild(td_3)
        table.appendChild(tr)

chrome.storage.local.get "bom", ({bom:bom}) ->
    bom_changed bom

chrome.storage.onChanged.addListener (changes, namespace) ->
    if (namespace == "local")
        if (changes.bom)
            chrome.storage.local.get "bom", ({bom:bom}) ->
                bom_changed bom

clear_error_log  = () ->
        document.querySelector("#errors").hidden = true;
        table = document.querySelector("#error_list")
        table.removeChild(table.lastChild) while table.hasChildNodes() 

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
    if(request.invalid)
        table = document.querySelector("#error_list")
        button = document.querySelector("#clear_errors")
        button.style.display = "block"
        button.addEventListener "click", clear_error_log
        tr_top = document.createElement("tr")
        td_top = document.createElement("td")
        td_top.colSpan=3
        td_top.innerText = "Invalid data pasted:"
        td_top.id = "error_td_top"
        tr_top.appendChild(td_top)
        table.appendChild(tr_top)
        for obj in request.invalid
            tr = document.createElement("tr")
            td_0 = document.createElement("td")
            td_0.innerText = "row: " + obj.item.row
            tr.appendChild(td_0)
            td_1 = document.createElement("td")
            inner_table = document.createElement("table")
            td_1.appendChild(inner_table)
            inner_tr = document.createElement("tr")
            inner_table.appendChild(inner_tr)
            for cell in obj.item.cells
                td = document.createElement("td")
                td.innerText = cell
                inner_tr.appendChild(td)
            #td_1.innerText = "\"" + obj.item.text + "\""
            tr.appendChild(td_1)
            td_2 = document.createElement("td")
            td_2.innerText = obj.reason
            tr.appendChild(td_2)
            table.appendChild(tr)
        document.querySelector("#errors").hidden = false;
