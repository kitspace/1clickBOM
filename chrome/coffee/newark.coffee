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
        params = "langId=-1&orderId=&catalogId=15003&BASE_URL=BasketPage&errorViewName=AjaxOrderItemDisplayView&storeId=10194&URL=BasketDataAjaxResponse&isEmpty=false&LoginTimeout=&LoginTimeoutURL=https%3A%2F%2Fwww.newark.com%2Fwebapp%2Fwcs%2Fstores%2Fservlet%2FOrderCalculate%3FcatalogId%3D15003%26LoginTimeout%3D%26errorViewName%3DAjaxOrderItemDisplayView%26langId%3D-1%26storeId%3D10194%26URL%3DAjaxOrderItemDisplayView&blankLinesResponse=10&orderItemDeleteAll="
        for id in ids
            params += "&orderItemDelete=" + id
        post url, params, (event) ->
            if callback?
                callback({success:true}, that)
            that.refreshCartTabs()
            that.refreshSiteTabs()
            that.clearing_cart = false

    _get_item_ids: (callback) ->
        that = this
        url = "https" + @site + @cart
        get url, (event) ->
            doc = DOM.parse(event.target.responseText)
            inputs = doc.querySelector("#order_details").querySelector("tbody").querySelectorAll("input")
            ids = []
            for input in inputs
                if input.type == "hidden" && /orderItem_/.test(input.id)
                    ids.push(input.value)
            callback(ids)

    addItems: (items, callback) ->
        that = this
        if items.length == 0
            if callback?
                callback({success:true, fails:[]}, that, items)
            return
        @adding_items = true
        url = "https" + @site + "/webapp/wcs/stores/servlet/OrderChangeServiceItemAdd"
        params = "storeId=10194&catalogId=15003&langId=-1&omItemAdd=quickOrder&URL=AjaxOrderItemDisplayView%3FstoreId%3D10194%26catalogId%3D15003%26langId%3D-1&outOrderName=orderId&errorViewName=RedirectView&calculationUsage=-1%2C-2%2C-3%2C-4%2C-5%2C-6%2C-7&hiddenEmptyCheck=true"

        "&partNumber_1=97W9272&quantity_1=1&comment_1=test&partNumber_2=32K8437&quantity_2=2&comment_2=test&partNumber_3=&quantity_3=&comment_3=&partNumber_4=&quantity_4=&comment_4=&partNumber_5=&quantity_5=&comment_5=&partNumber_6=&quantity_6=&comment_6=&partNumber_7=&quantity_7=&comment_7=&partNumber_8=&quantity_8=&comment_8=&partNumber_9=&quantity_9=&comment_9=&partNumber_10=&quantity_10=&comment_10=&partNumber_11=&quantity_11=&comment_11=&partNumber_12=&quantity_12=&comment_12="
        for item,i in items
            params += "&partNumber_" + (i+1) + "=" + encodeURIComponent(item.part)
            params += "&quantity_"   + (i+1) + "=" + encodeURIComponent(item.quantity)
            params += "&comment_"    + (i+1) + "=" + encodeURIComponent(item.comment)
        post url, params, (event) ->
            doc = DOM.parse(event.target.responseText)
            form_errors = doc.querySelector("#formErrors")
            success = true
            if form_errors?
                success = form_errors.className != ""
            if not success
                #we find out which parts are the problem, call addItems again
                #on the rest and concatenate the fails to the new result
                #returning everything together to our callback
                fail_names = []
                fails = []
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
                that.addItems retry_items, (result) ->
                    if callback?
                        result.fails = result.fails.concat(fails)
                        result.success = false
                        callback(result, that, items)
                    that.refreshCartTabs()
                    that.refreshSiteTabs()
                    that.adding_items = false
            else #success
                if callback?
                    callback({success: true, fails:[]}, that, items)
                that.refreshCartTabs()
                that.refreshSiteTabs()
                that.adding_items = false

