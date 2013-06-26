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

xhr = new XMLHttpRequest()
xhr.open "GET", chrome.extension.getURL("/data/digikey_international.json"), false
xhr.send()
if xhr.status == 200
    @digikey_data = JSON.parse xhr.responseText

xhr = new XMLHttpRequest()
xhr.open "GET", chrome.extension.getURL("/data/element14_international.json"), false
xhr.send()
if xhr.status == 200
    @element14_data = JSON.parse xhr.responseText

test "Digikey: Clear All", () ->
    try
        for key of window.digikey_data.sites
            console.log "Digikey: Clearing all in:" + key
            d = new Digikey(key)
            d.clearCart()
    catch error
        ok false
        throw error
    ok true

test "Digikey: Add Items", () ->
    try
        for key of window.digikey_data.sites
            console.log "Digikey: Adding item in " + key
            d = new Digikey(key)
            items = [{"part":"754-1173-1-ND","quantity":2, "comment":"test"}]
            d.addItems(items)
    catch error
        ok false
        throw error
    ok true

test "Element14: Clear All", () ->
    try
        for key of window.element14_data.sites
            console.log "Element14: Clearing all in " + key
            d = new Element14(key)
            d.clearCart()
    catch error
        ok false
        throw error
    ok true

test "Element14: Add Items", () ->
    try
        for key of window.element14_data.sites
            console.log "Element14: Adding item in " + key
            d = new Element14(key)
            items = [{"part":"105321","quantity":2, "comment":"test"}]
            d.addItems(items)
    catch error
        ok false
        throw error
    ok true
