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

class @Farnell extends RetailerInterface
    constructor: (country_code, settings) ->
        super("Farnell", country_code, "/data/farnell_international.json", settings)
        @icon_src = chrome.extension.getURL("images/farnell.ico")

        #export farnell tries to go to exportHome if we have no cookie and we don't pass it the params
        if @site == "://export.farnell.com"
            fix_url = "http" + @site + @cart + "?_DARGS=/jsp/home/exportHome.jsp_A&_DAV=en_EX_DIRECTEXP"
            fix_xhr = new XMLHttpRequest
            fix_xhr.open("GET", fix_url, false)
            fix_xhr.send()

    clearCart: (callback)->
        @clearing_cart = true
        @_get_item_ids(callback)

    _get_item_ids: (callback) ->
        that = this
        xhr = new XMLHttpRequest
        parser = new DOMParser
        url = "https" + @site + @cart  
        xhr.open("GET", url, true)
        xhr.onreadystatechange = (data) ->
            if xhr.readyState == 4 and xhr.status == 200
                doc = parser.parseFromString(xhr.responseText, "text/html")
                ins = doc.getElementsByTagName("input")
                ids = []
                for element in ins
                    if element.name == "/pf/commerce/CartHandler.removalCommerceIds"
                        ids.push(element.value)
                that._post_clear(ids, callback)
        xhr.send()
       
    _post_clear: (ids, callback) ->
        that = this
        if (ids.length)
            xhr = new XMLHttpRequest
            url = "https" + @site + "/jsp/checkout/paymentMethod.jsp"
            xhr.open("POST", url, true)
            xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
            xhr.onreadystatechange = (data) ->
                if xhr.readyState == 4 and xhr.status == 200
                    if callback?
                        callback()
                    that.refreshSiteTabs()
                    that.refreshCartTabs()
                    that.clearing_cart = false
            txt_1 = ""
            txt_2 = ""
            for id in ids
                txt_1 += "&/pf/commerce/CartHandler.removalCommerceIds=" + id
                txt_2 += "&" + id + "=1"
            xhr.send("/pf/commerce/CartHandler.addItemCount=5&/pf/commerce/CartHandler.addLinesSuccessURL=../shoppingCart/shoppingCart.jsp&/pf/commerce/CartHandler.moveToPurchaseInfoErrorURL=../shoppingCart/shoppingCart.jsp&/pf/commerce/CartHandler.moveToPurchaseInfoSuccessURL=../checkout/paymentMethod.jsp&/pf/commerce/CartHandler.punchOutSuccessURL=orderReviewPunchOut.jsp" + txt_1 + "&/pf/commerce/CartHandler.setOrderErrorURL=../shoppingCart/shoppingCart.jsp&/pf/commerce/CartHandler.setOrderSuccessURL=../shoppingCart/shoppingCart.jsp&_D:/pf/commerce/CartHandler.addItemCount= &_D:/pf/commerce/CartHandler.addLinesSuccessURL= &_D:/pf/commerce/CartHandler.moveToPurchaseInfoErrorURL= &_D:/pf/commerce/CartHandler.moveToPurchaseInfoSuccessURL= &_D:/pf/commerce/CartHandler.punchOutSuccessURL= &_D:/pf/commerce/CartHandler.removalCommerceIds= &_D:/pf/commerce/CartHandler.setOrderErrorURL= &_D:/pf/commerce/CartHandler.setOrderSuccessURL= &_D:Submit= &_D:addEmptyLines= &_D:clearBlankLines= &_D:continueWithShipping= &_D:emptyLinesA= &_D:emptyLinesB= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote1= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:reqFromCart= &_D:textfield2= &_D:topUpdateCart= &_DARGS=/jsp/shoppingCart/fragments/shoppingCart/cartContent.jsp.cart&_dyncharset=UTF-8" + txt_2 + "&emptyLinesA=0&emptyLinesB=0&lineNote=&lineNote=&lineNote=&lineNote=&lineNote=&lineNote=&lineNote1=&lineQuantity=1&lineQuantity=1&lineQuantity=1&lineQuantity=1&lineQuantity=1&lineQuantity=1&reqFromCart=true&textfield2=&topUpdateCart=Update Basket") 

    addItems: (items, callback) ->
        @adding_items = true
        that = this
        xhr = new XMLHttpRequest
        url = "https" + @site + @additem
        result = {}
        for item in items
            url += encodeURIComponent(item.part + "," + item.quantity + ",\"" + item.comment + "\"\r\n")
        xhr.onreadystatechange = (event) ->
            if event.currentTarget.readyState == 4
                #if items successully add the request returns the basket
                parser = new DOMParser
                doc = parser.parseFromString(xhr.responseText, "text/html")
                #we determine the request has returned the basket by the body classname 
                #so it's language agnostic
                result.success = doc.querySelector("body.shoppingCart") != null
                if (result.success)
                    if (callback?)
                        callback(result, that)
                    that.refreshCartTabs()
                    that.refreshSiteTabs()
                    that.adding_items = false
                else 
                    that._add_items_individually(items, callback)
        xhr.open("POST", url, true)
        xhr.send()

    _add_items_individually: (items, callback) ->
        that = this
        result = {success:true, fails:[]}
        count = items.length
        for item in items
            xhr = new XMLHttpRequest
            url = "https" + @site + @additem
            url += encodeURIComponent(item.part + "," + item.quantity + ",\"" + item.comment + "\"\r\n")
            xhr.open("POST", url, true)
            xhr.item = item
            xhr.onreadystatechange = (event) ->
                if event.currentTarget.readyState == 4
                    doc = (new DOMParser).parseFromString(event.currentTarget.responseText, "text/html")
                    success = doc.querySelector("body.shoppingCart") != null
                    result.success = result.success && success
                    if not success
                        result.fails.push(event.currentTarget.item)
                    count--
                    if count == 0
                        that.refreshCartTabs()
                        that.refreshSiteTabs()
                        if callback?
                            callback(result, that)
                        that.adding_items = false
            xhr.send()

    _add_items_individually_via_micro_cart: (items, callback) ->
        that = this
        result = {success:true, fails:[], no_item_comments:true}
        count = items.length
        for item in items
            xhr = new XMLHttpRequest
            url = "https" + @site + "/jsp/shoppingCart/processMicroCart.jsp?action=buy&product=" + item.part + "&qty=" + item.quantity
            xhr.open("POST", url, true)
            xhr.item = item
            xhr.onreadystatechange = (event) ->
                if event.currentTarget.readyState == 4
                    success = xhr.responseXML != null
                    result.success = result.success && success
                    if not success
                        result.fails.push(event.currentTarget.item)
                    count--
                    if count == 0
                        that.refreshCartTabs()
                        that.refreshSiteTabs()
                        if callback?
                            callback(result, that)
            xhr.send()




