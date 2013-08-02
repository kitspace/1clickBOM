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

save_options = () ->
    select = document.getElementById "country"
    country = select.children[select.selectedIndex].value
    localStorage["country"] = country;

    status = document.getElementById "status"
    status.innerHTML = "Options Saved.";
    setTimeout ()->
        status.innerHTML = ""
    , 750

restore_options = () ->
    stored = localStorage["country"]
    if (!stored) 
        return
    select = document.getElementById("country")
    for child in select.children
        if child.value == stored
            child.selected = "true"
            break

xhr = new XMLHttpRequest()
xhr.open "GET", chrome.extension.getURL("/data/countries.json"), false
xhr.send()
if xhr.status == 200
    countries = JSON.parse xhr.responseText

select = document.getElementById "country"
for name, code of countries
    opt = document.createElement("option")
    opt.innerHTML = name 
    opt.value = code 
    select.appendChild(opt)

document.addEventListener "DOMContentLoaded", restore_options
document.querySelector("#save").addEventListener "click", save_options
