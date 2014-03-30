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


    clearCart: ->
        @_get_item_ids()

    _get_item_ids: () ->
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
                that._post_clear(ids)
        xhr.send()
       
    _post_clear: (ids) ->
        that = this
        if (ids.length)
            xhr = new XMLHttpRequest
            url = "https" + @site + "/jsp/checkout/paymentMethod.jsp"
            xhr.open("POST", url, true)
            xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
            xhr.onreadystatechange = (data) ->
                if xhr.readyState == 4 and xhr.status == 200
                    that.refreshSiteTabs()
                    that.refreshCartTabs()
            txt_1 = ""
            txt_2 = ""
            for id in ids
                txt_1 += "&/pf/commerce/CartHandler.removalCommerceIds=" + id
                txt_2 += "&" + id + "=1"
            xhr.send("/pf/commerce/CartHandler.addItemCount=5&/pf/commerce/CartHandler.addLinesSuccessURL=../shoppingCart/shoppingCart.jsp&/pf/commerce/CartHandler.moveToPurchaseInfoErrorURL=../shoppingCart/shoppingCart.jsp&/pf/commerce/CartHandler.moveToPurchaseInfoSuccessURL=../checkout/paymentMethod.jsp&/pf/commerce/CartHandler.punchOutSuccessURL=orderReviewPunchOut.jsp" + txt_1 + "&/pf/commerce/CartHandler.setOrderErrorURL=../shoppingCart/shoppingCart.jsp&/pf/commerce/CartHandler.setOrderSuccessURL=../shoppingCart/shoppingCart.jsp&_D:/pf/commerce/CartHandler.addItemCount= &_D:/pf/commerce/CartHandler.addLinesSuccessURL= &_D:/pf/commerce/CartHandler.moveToPurchaseInfoErrorURL= &_D:/pf/commerce/CartHandler.moveToPurchaseInfoSuccessURL= &_D:/pf/commerce/CartHandler.punchOutSuccessURL= &_D:/pf/commerce/CartHandler.removalCommerceIds= &_D:/pf/commerce/CartHandler.setOrderErrorURL= &_D:/pf/commerce/CartHandler.setOrderSuccessURL= &_D:Submit= &_D:addEmptyLines= &_D:clearBlankLines= &_D:continueWithShipping= &_D:emptyLinesA= &_D:emptyLinesB= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote1= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:reqFromCart= &_D:textfield2= &_D:topUpdateCart= &_DARGS=/jsp/shoppingCart/fragments/shoppingCart/cartContent.jsp.cart&_dyncharset=UTF-8" + txt_2 + "&emptyLinesA=0&emptyLinesB=0&lineNote=&lineNote=&lineNote=&lineNote=&lineNote=&lineNote=&lineNote1=&lineQuantity=1&lineQuantity=1&lineQuantity=1&lineQuantity=1&lineQuantity=1&lineQuantity=1&reqFromCart=true&textfield2=&topUpdateCart=Update Basket") 

    refreshCartTabs: (site = @site, cart = @cart) ->
        #export farnell tries to go to exportHome if we have no cookie and we don't pass it the params
        if site == "://export.farnell.com"
            re = new RegExp(cart, "i")
            chrome.tabs.query {"url":"*" + site + "/*"}, (tabs)->
                for tab in tabs
                    if (tab.url.match(re))
                        protocol = tab.url.split("://")[0]
                        chrome.tabs.update tab.id, {"url": protocol + site + cart + "?_DARGS=/jsp/home/exportHome.jsp_A&_DAV=en_EX_DIRECTEXP"}
        else
            super()

    openCartTab: (site = @site, cart = @cart) ->
        #export farnell tries to go to exportHome if we have no cookie and we don't pass it the params
        if site == "://export.farnell.com"
            export_cart= cart + "?_DARGS=/jsp/home/exportHome.jsp_A&_DAV=en_EX_DIRECTEXP" 
            super(site = site, cart = export_cart)
        else
            super()

    addItems: (items, callback)->
        if @site == "://export.farnell.com"
            fix_url = "http" + @site + @cart + "?_DARGS=/jsp/home/exportHome.jsp_A&_DAV=en_EX_DIRECTEXP"
            fix_xhr = new XMLHttpRequest
            fix_xhr.open("GET", fix_url, false)
            fix_xhr.send()
        that = this
        xhr = new XMLHttpRequest
        url = "https" + @site + @additem
        request = {}
        for item in items
            url += encodeURIComponent(item.part + "," + item.quantity + ",\"" + item.comment + "\"\r\n")
        xhr.onreadystatechange = (data) ->
            if xhr.readyState == 4
                #if items successully add the request returns the basket
                parser = new DOMParser
                doc = parser.parseFromString(xhr.responseText, "text/html")
                #we determine the request has returned the basket by the body classname so it's language agnostic
                request.success = doc.querySelector("body.shoppingCart") != null
                if (callback?)
                    callback(request, that.country)
                if (request.success)
                    that.refreshCartTabs()
                    that.refreshSiteTabs()
        xhr.open("POST", url, true)
        xhr.send()
