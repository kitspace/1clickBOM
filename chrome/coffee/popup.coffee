#    This file is part of 1clickBOM.
#
#    1clickBOM is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License version 3
#    as published by the Free Software Foundation.
#
#    1clickBOM is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with 1clickBOM.  If not, see <http://www.gnu.org/licenses/>.


chrome.runtime.getBackgroundPage (bkgd_page) ->
    document.querySelector("#paste").addEventListener "click", bkgd_page.paste_action 

    document.querySelector("#clear").addEventListener "click", () ->
        chrome.storage.local.remove("bom")

    document.querySelector("#fill_carts").addEventListener "click", bkgd_page.fill_carts

    document.querySelector("#clear_carts").addEventListener "click", bkgd_page.clear_carts

    #Ctrl-V event
    document.addEventListener 'keydown', (event) -> 
        if ((event.keyCode == 86) && (event.ctrlKey == true))
            bkgd_page.paste_action()

    #chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
    #    console.log(request)


chrome.storage.local.get "bom", ({bom:bom}) ->
    document.querySelector("#fill_carts").disabled=!Boolean(bom)

chrome.storage.onChanged.addListener (changes, namespace) ->
    if (namespace == "local")
        if (changes.bom)
            chrome.storage.local.get "bom", ({bom:bom}) ->
                document.querySelector("#fill_carts").disabled=!Boolean(bom)
