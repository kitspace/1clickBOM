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
    @data = JSON.parse xhr.responseText

#test "Clear All", () ->
#    for key of window.data.sites
#        console.log "Clear All " + key
#        d = new Digikey(key)
#        d.clearCart()
#    ok true

test "Add Items", () ->
    #for key of window.data.sites
    #    console.log "Adding item to Digikey " + key
    #    d = new Digikey(key)
    #    items = [{"part":"754-1173-1-ND","quantity":2, "comment":"test"}]
    #    d.addItems(items)
    d = new Digikey("BE")
    items = [
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        #{"part":"754-1173-1-ND","quantity":2, "comment":"test"},
        {"part":"754-1173-1-ND","quantity":2, "comment":"test"}
    ]
    d.addItems(items)
    ok true

#test "Read Cart", () ->
#    for key of window.data.sites
#        d = new Digikey(key)
#        cart = d.readCart()
#        strictEqual(cart.total, 0)
