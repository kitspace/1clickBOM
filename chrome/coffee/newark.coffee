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

class window.Newark extends RetailerInterface
    constructor: (country_code, settings) ->
        super("Newark", country_code, "/data/newark.json", settings)
        @store_id = "10194"

    clearCart: (callback) ->
        @clearing_cart = true
        @_get_item_ids (ids) =>
            @_clear_cart(ids, callback)

    _clear_cart: (ids, callback) ->
        url = "https" + @site + "/webapp/wcs/stores/servlet/ProcessBasket"
        params = "langId=-1&orderId=&catalogId=15003&BASE_URL=BasketPage&errorViewName=AjaxOrderItemDisplayView&storeId=" + @store_id + "&URL=BasketDataAjaxResponse&isEmpty=false&LoginTimeout=&LoginTimeoutURL=https%3A%2F%2Fwww.newark.com%2Fwebapp%2Fwcs%2Fstores%2Fservlet%2FOrderCalculate%3FcatalogId%3D15003%26LoginTimeout%3D%26errorViewName%3DAjaxOrderItemDisplayView%26langId%3D-1%26storeId%3D10194%26URL%3DAjaxOrderItemDisplayView&blankLinesResponse=10&orderItemDeleteAll="
        for id in ids
            params += "&orderItemDelete=" + id
        post url, params, (event) =>
            if callback?
                callback({success:true}, this)
            @refreshCartTabs()
            @refreshSiteTabs()
            @clearing_cart = false

    _get_item_ids: (callback) ->
        url = "https" + @site + @cart
        get url, (event) =>
            doc = DOM.parse(event.target.responseText)
            order_details = doc.querySelector("#order_details")
            if order_details?
                tbody = order_details.querySelector("tbody")
                inputs = tbody.querySelectorAll("input")
            else
                inputs = []
            ids = []
            for input in inputs
                if input.type == "hidden" && /orderItem_/.test(input.id)
                    ids.push(input.value)
            callback(ids)

    addItems: (items, callback) ->
        @adding_items = true
        @_add_items  items, (result) =>
            @refreshCartTabs()
            @refreshSiteTabs()
            @adding_items = false
            callback(result, this, items)

    _add_items: (items, callback) ->
        if items.length == 0
            if callback?
                callback({success:true, fails:[]})
            return
        url = "https" + @site + "/webapp/wcs/stores/servlet/PasteOrderChangeServiceItemAdd"
        params = "storeId=" + @store_id + "&catalogId=&langId=-1&omItemAdd=quickPaste&URL=AjaxOrderItemDisplayView%3FstoreId%3D10194%26catalogId%3D15003%26langId%3D-1%26quickPaste%3D*&errorViewName=QuickOrderView&calculationUsage=-1%2C-2%2C-3%2C-4%2C-5%2C-6%2C-7&isQuickPaste=true&quickPaste="
        #&addToBasket=Add+to+Cart"
        for item in items
            params += encodeURIComponent(item.part) + ","
            params += encodeURIComponent(item.quantity) + ","
            params += encodeURIComponent(item.comment) + "\n"
        post url, params, (event) =>
            doc = DOM.parse(event.target.responseText)
            form_errors = doc.querySelector("#formErrors")
            success = true
            if form_errors?
                success = form_errors.className != ""
            if not success
                #we find out which parts are the problem, call addItems again
                #on the rest and concatenate the fails to the new result
                #returning everything together to our callback
                fail_names  = []
                fails       = []
                retry_items = []
                for item in items
                        regex = new RegExp item.part, "g"
                        result = regex.exec(form_errors.innerHTML)
                        if result != null
                            fail_names.push(result[0])
                for item in items
                    if item.part in fail_names
                        fails.push(item)
                    else
                        retry_items.push(item)
                @_add_items retry_items, (result) ->
                    if callback?
                        result.fails = result.fails.concat(fails)
                        result.success = false
                        callback(result)
            else #success
                if callback?
                    callback({success: true, fails:[]})

