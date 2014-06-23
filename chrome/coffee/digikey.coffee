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

class @Digikey extends RetailerInterface
    constructor: (country_code, settings) ->
        super("Digikey", country_code, "/data/digikey_international.json", settings)
        @icon_src = chrome.extension.getURL("images/digikey.ico")

    clearCart: (callback) ->
        @clearing_cart = true
        that = this
        xhr = new XMLHttpRequest
        xhr.open("GET","http" + @site + @cart + "?webid=-1", true)
        xhr.onreadystatechange = () ->
            if xhr.readyState == 4
                if callback?
                    callback({success:true})
                that.refreshCartTabs()
                that.clearing_cart = false
        xhr.send()

    addItems: (items, callback) ->
        that = this
        @adding_items = true
        result = {success:true, fails:[]}
        count = items.length
        parser = new DOMParser
        for item in items
            url = "http" + @site + @additem
            params = "qty=" + item.quantity + "&part=" + item.part + "&cref=" + item.comment
            post url, params, (event)->
                doc = parser.parseFromString(event.target.responseText, "text/html")
                #if the cart returns with a quick-add quantity filled-in there was an error
                quick_add_quant = doc.querySelector("#ctl00_ctl00_mainContentPlaceHolder_mainContentPlaceHolder_txtQuantity")
                success = (quick_add_quant?) && (quick_add_quant.value?) && (quick_add_quant.value == "")
                if not success
                    result.fails.push(event.target.item)
                result.success = result.success && success
                count--
                if (count == 0)
                    if callback?
                        callback(result, that)
                    that.refreshCartTabs()
                    that.adding_items = false
            , item
