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

class window.Farnell extends RetailerInterface
    constructor: (country_code, settings) ->
        super("Farnell", country_code, "/data/farnell_international.json", settings)
        @icon_src = chrome.extension.getURL("images/farnell.ico")

        #export.farnell.com tries to go to exportHome.jsp if we have no cookie
        #and we don't do this
        if @site == "://export.farnell.com"
            fix_url = "http" + @site + @cart + "?_DARGS=/jsp/home/exportHome.jsp_A&_DAV=en_EX_DIRECTEXP"
            fix_xhr = new XMLHttpRequest
            fix_xhr.open("GET", fix_url, false)
            fix_xhr.send()
        else if country_code in ["FI", "DK", "NO", "SE"]
            #these web interfaces are like Newark's so we get all our methods
            #from Newark
            for name, method of Newark::
                this[name] = method
            switch country_code
                when "FI" then @store_id = "10159"
                when "DK" then @store_id = "10157"
                when "NO" then @store_id = "10169"
                when "SE" then @store_id = "10177"

    clearCart: (callback) ->
        @clearing_cart = true
        @_get_item_ids (ids) =>
            @_post_clear(ids, callback)

    _get_item_ids: (callback) ->
        url = "https" + @site + @cart
        get url, (event) =>
            doc = DOM.parse(event.target.responseText)
            ins = doc.getElementsByTagName("input")
            ids = []
            for element in ins
                if element.name == "/pf/commerce/CartHandler.removalCommerceIds"
                    ids.push(element.value)
            callback(ids)
        , () =>
            callback([])


    _post_clear: (ids, callback) ->
        if (ids.length)
            url = "https" + @site + "/jsp/checkout/paymentMethod.jsp"
            txt_1 = ""
            txt_2 = ""
            for id in ids
                txt_1 += "&/pf/commerce/CartHandler.removalCommerceIds=" + id
                txt_2 += "&" + id + "=1"
            params = "/pf/commerce/CartHandler.addItemCount=5&/pf/commerce/CartHandler.addLinesSuccessURL=../shoppingCart/shoppingCart.jsp&/pf/commerce/CartHandler.moveToPurchaseInfoErrorURL=../shoppingCart/shoppingCart.jsp&/pf/commerce/CartHandler.moveToPurchaseInfoSuccessURL=../checkout/paymentMethod.jsp&/pf/commerce/CartHandler.punchOutSuccessURL=orderReviewPunchOut.jsp" + txt_1 + "&/pf/commerce/CartHandler.setOrderErrorURL=../shoppingCart/shoppingCart.jsp&/pf/commerce/CartHandler.setOrderSuccessURL=../shoppingCart/shoppingCart.jsp&_D:/pf/commerce/CartHandler.addItemCount= &_D:/pf/commerce/CartHandler.addLinesSuccessURL= &_D:/pf/commerce/CartHandler.moveToPurchaseInfoErrorURL= &_D:/pf/commerce/CartHandler.moveToPurchaseInfoSuccessURL= &_D:/pf/commerce/CartHandler.punchOutSuccessURL= &_D:/pf/commerce/CartHandler.removalCommerceIds= &_D:/pf/commerce/CartHandler.setOrderErrorURL= &_D:/pf/commerce/CartHandler.setOrderSuccessURL= &_D:Submit= &_D:addEmptyLines= &_D:clearBlankLines= &_D:continueWithShipping= &_D:emptyLinesA= &_D:emptyLinesB= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote1= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:reqFromCart= &_D:textfield2= &_D:topUpdateCart= &_DARGS=/jsp/shoppingCart/fragments/shoppingCart/cartContent.jsp.cart&_dyncharset=UTF-8" + txt_2 + "&emptyLinesA=0&emptyLinesB=0&lineNote=&lineNote=&lineNote=&lineNote=&lineNote=&lineNote=&lineNote1=&lineQuantity=1&lineQuantity=1&lineQuantity=1&lineQuantity=1&lineQuantity=1&lineQuantity=1&reqFromCart=true&textfield2=&topUpdateCart=Update Basket"
            post url, params, (event) =>
                if callback?
                    callback({success:true})
                @refreshSiteTabs()
                @refreshCartTabs()
                @clearing_cart = false
            , item={part:"clear cart request", retailer:"Farnell"}, json=false
            , () =>
                if callback?
                    callback({success:false})
                @clearing_cart = false
        else
          if callback?
              callback({success:true})
          @clearing_cart = false

    addItems: (items, callback) ->
        @adding_items = true
        url = "https" + @site + @additem
        result = {success:true, fails:[]}
        #this doesn't seem to work as a parameter
        for item in items
            url += encodeURIComponent(item.part + "," + item.quantity + ",\"" + item.comment + "\"\r\n")
        post url, "", (event) =>
            #if items successully add the request returns the basket
            doc = DOM.parse(event.target.responseText)
            #we determine the request has returned the basket by the body classname
            #so it's language agnostic
            result.success = doc.querySelector("body.shoppingCart") != null
            if (result.success)
                if (callback?)
                    callback(result, this, items)
                @refreshCartTabs()
                @refreshSiteTabs()
                @adding_items = false
            else
                @_add_items_individually_via_micro_cart(items, callback)
         , item={part:"parts",retailer:"Farnell"}, json=false, () =>
                if callback?
                    callback({success:false, fails:items}, this, items)
                @adding_items = false

    _add_items_individually: (items, callback) ->
        result = {success:true, fails:[]}
        count = items.length
        for item in items
            url = "https" + @site + @additem
            #this doesn't seem to work as a parameter
            url += encodeURIComponent(item.part + "," + item.quantity + ",\"" + item.comment + "\"\r\n")
            post url, "", (event) =>
                doc = DOM.parse(event.target.responseText)
                success = doc.querySelector("body.shoppingCart") != null
                result.success = result.success && success
                if not success
                    result.fails.push(event.target.item)
                count--
                if count == 0
                    @refreshCartTabs()
                    @refreshSiteTabs()
                    if callback?
                        callback(result, this, items)
                    @adding_items = false
            , item=item, json=false, () =>
                result.fails.push(event.target.item)
                count--
                if count == 0
                    @refreshCartTabs()
                    @refreshSiteTabs()
                    if callback?
                        callback(result, this, items)
                    @adding_items = false
    _add_items_individually_via_micro_cart: (items, callback) ->
        result = {success:true, fails:[], warnings:["Unable to add line notes in Farnell cart"]}
        count = items.length
        for item in items
            url = "https" + @site + "/jsp/shoppingCart/processMicroCart.jsp"
            params = "action=buy&product=" + item.part + "&qty=" + item.quantity
            post url, params, (event) =>
                success = event.target.responseXML != null
                if not success
                    result.success = false
                    result.fails.push(event.target.item)
                count--
                if count == 0
                    @refreshCartTabs()
                    @refreshSiteTabs()
                    if callback?
                        callback(result, this, items)
                    @adding_items = false
            , item=item, json=false, (it) =>
                result.success = false
                result.fails.push(it)
                count--
                if count == 0
                    @refreshCartTabs()
                    @refreshSiteTabs()
                    if callback?
                        callback(result, this, items)
                    @adding_items = false


