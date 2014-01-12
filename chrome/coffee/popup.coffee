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

    document.querySelector("#fill_carts").addEventListener "click", bkgd_page.fill_carts

    document.querySelector("#clear_carts").addEventListener "click", bkgd_page.clear_carts

    document.querySelector("#open_cart_tabs").addEventListener "click", bkgd_page.open_cart_tabs

    #Ctrl-V event
    document.addEventListener 'keydown', (event) -> 
        if ((event.keyCode == 86) && (event.ctrlKey == true))
            bkgd_page.paste_action()

    #chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
    #    console.log(request)

bom_changed = (bom) ->
    document.querySelector("#fill_carts").disabled=!Boolean(bom)
    document.querySelector("#clear_carts").disabled=!Boolean(bom)
    document.querySelector("#open_cart_tabs").disabled=!Boolean(bom)
    table = document.querySelector("#bom_list")
    table.removeChild(table.lastChild) while table.hasChildNodes() 
    for retailer of bom
        tr = document.createElement("tr")
        td_0 = document.createElement("td")
        icon = document.createElement("img")
        switch (retailer)
            when "Digikey"   then icon.src = chrome.extension.getURL("images/digikey.ico")
            when "Element14" then icon.src = chrome.extension.getURL("images/element14.ico")
        td_0.appendChild(icon)
        tr.appendChild(td_0)
        td_1 = document.createElement("td")
        td_1.innerText = retailer + ":"
        tr.appendChild(td_1)
        td_2 = document.createElement("td")
        td_2.innerText = bom[retailer].items.length + " item"
        td_2.innerText += "s" if (bom[retailer].items.length > 1)
        tr.appendChild(td_2)
        table.appendChild(tr)

chrome.storage.local.get "bom", ({bom:bom}) ->
    bom_changed bom

chrome.storage.onChanged.addListener (changes, namespace) ->
    if (namespace == "local")
        if (changes.bom)
            chrome.storage.local.get "bom", ({bom:bom}) ->
                bom_changed bom

