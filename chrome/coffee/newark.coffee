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

class @Newark extends RetailerInterface
    constructor: (country_code, settings) ->
        super("Newark", country_code, "/data/newark_international.json", settings)
        @icon_src = chrome.extension.getURL("images/newark.png")

    clearCart: (callback) ->
        that = this
        @clearing_cart = true
        @_get_item_ids (ids) ->
            that._clear_cart(ids, callback)

    _clear_cart: (ids, callback) ->
        that = this
        url = "https" + @site + "/webapp/wcs/stores/servlet/ProcessBasket"
        params = "langId=-1&orderId=36546637&catalogId=15003&BASE_URL=BasketPage&errorViewName=AjaxOrderItemDisplayView&storeId=10194&URL=BasketDataAjaxResponse&isEmpty=false&LoginTimeout=&LoginTimeoutURL=https%3A%2F%2Fwww.newark.com%2Fwebapp%2Fwcs%2Fstores%2Fservlet%2FOrderCalculate%3FcatalogId%3D15003%26LoginTimeout%3D%26errorViewName%3DAjaxOrderItemDisplayView%26langId%3D-1%26storeId%3D10194%26URL%3DAjaxOrderItemDisplayView&blankLinesResponse=10&orderItemDeleteAll="
        for id in ids
            params += "&orderItemDelete=" + id 
        post url, params, (event) ->
            if callback?
                callback({success:true})
            that.refreshCartTabs()
            that.refreshSiteTabs()
            that.clearing_cart = false

    _get_item_ids: (callback) ->
        that = this
        url = "https" + @site + @cart
        get url, (event) ->
            doc = DOM.parseFromString(event.target.responseText, "text/html")
            inputs = doc.querySelector("#order_details").querySelector("tbody").querySelectorAll("input")
            ids = []
            for input in inputs
                if input.type == "hidden" && /orderItem_/.test(input.id)
                    ids.push(input.value)
            if callback?
                callback(ids)

    addItems: (items, callback) ->
        that = this
        @adding_items = true
        url = "https" + @site + "/PasteOrderChangeServiceItemAdd"
        params = "storeId=10194&catalogId=15003&langId=-1&omItemAdd=quickPaste&URL=AjaxOrderItemDisplayView%3FstoreId%3D10194%26catalogId%3D15003%26langId%3D-1%26quickPaste%3D*&errorViewName=QuickOrderView&calculationUsage=-1%2C-2%2C-3%2C-4%2C-5%2C-6%2C-7&isQuickPaste=true&quickPaste="
        for item in items
            #XXX comments with commas!
            params += encodeURIComponent(item.part + "," + item.quantity + "," + item.comment + "\n")
        params += "&addToBasket=Add+to+Cart"
        post url, params, (event) ->
            if callback?
                callback({success: true})
            that.refreshCartTabs()
            that.refreshSiteTabs()
            that.adding_items = false
