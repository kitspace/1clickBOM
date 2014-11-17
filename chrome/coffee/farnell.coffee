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
    constructor: (country_code, settings, callback) ->
        super("Farnell", country_code, "/data/farnell.json", settings)
        get "http" + @site, {}, () =>
            #if there is a "pf_custom_js" element then this site is like
            #Newark's and we get all our methods from Newark, otherwise we fix
            #our cookies
            if DOM.parse(event.target.response).getElementById("pf_custom_js")?
                for name, method of Newark::
                    this[name] = method
                @cart = "/webapp/wcs/stores/servlet/AjaxOrderItemDisplayView"
                @_set_store_id()
                if callback?
                    callback(this)
            else if /element14/.test(@site)
                @_fix_cookies_element14 () =>
                    if callback?
                        callback(this)
            else
                @_fix_cookies () =>
                    if callback?
                        callback(this)

    _clear_cookies: (callback) ->
        chrome.cookies.getAll {domain:"element14.com"}, (incoming_cookies) =>
            cookies = []
            for cookie in incoming_cookies
                if not (/MAINT_NOTIFY/.test(cookie.name) or /userSelectedLocale/.test(cookie.name))
                    cookies.push(cookie)
            if cookies.length > 0
                count = cookies.length
                for cookie in cookies
                    chrome.cookies.remove {url:"http://" + cookie.domain, name:cookie.name}, () =>
                        count -= 1
                        if count <= 0
                            chrome.cookies.getAll {domain:"farnell.com"}, (incoming_cookies) =>
                                cookies = []
                                if incoming_cookies.length > 0
                                    for cookie in incoming_cookies
                                        #the cookieMessage cookie just makes sure that the EU cookie
                                        #notification thing has been agreed to so we don't want to delete that
                                        if not (/cookieMessage/.test(cookie.name) or /userSelectedLocale/.test(cookie.name))
                                            cookies.push(cookie)
                                if cookies.length == 0
                                    if callback?
                                        callback()
                                else
                                    count = cookies.length
                                    for cookie in cookies
                                        chrome.cookies.remove {url:"http://" + cookie.domain, name:cookie.name}, () =>
                                            count -= 1
                                            if count <= 0 && callback?
                                                callback()
            else if callback?
                callback()

    _fix_language_cookie: (callback) ->
        #export.farnell.com tries to go to exportHome.jsp if we have no cookie
        #and we don't do this
        if @site == "://export.farnell.com"
            fix_url = "http" + @site + @cart + "?_DARGS=/jsp/home/exportHome.jsp_A&_DAV=en_EX_DIRECTEXP"
            get fix_url, callback, callback
        else if @country in ["CH", "BE", "CN"]
            chrome.cookies.getAll {domain:@site.substring(3), name:"userSelectedLocale"}, (incoming_cookies) =>
                if incoming_cookies.length > 0
                    if callback?
                        callback()
                else
                    chrome.cookies.set {url:"http" + @site , name:"userSelectedLocale", value:@language}, () =>
                        if callback?
                            callback()
        else if callback?
            callback()

    _fix_cookies: (callback) ->
        @_clear_cookies () =>
            @_fix_language_cookie () =>
                get "http" + @site + "/jsp/home/homepage.jsp", {}, callback, callback

    _fix_cookies_element14: (callback) ->
        @_clear_cookies () =>
            #login as 1clickBOM + @country
            url = "https" + @site + "/jsp/profile/register.jsp?_DARGS=/jsp/profile/fragments/login/loginFragment.jsp.loginfragment"
            params = "_dyncharset=UTF-8&%2Fatg%2Fuserprofiling%2FProfileFormHandler.loginErrorURL=..%2Fprofile%2Flogin.jsp%3FfromPage%3Dtrue&_D%3A%2Fatg%2Fuserprofiling%2FProfileFormHandler.loginErrorURL=+&%2Fatg%2Fuserprofiling%2FProfileFormHandler.loginSuccessURL=%2Fjsp%2Fhome%2Fhomepage.jsp&_D%3A%2Fatg%2Fuserprofiling%2FProfileFormHandler.loginSuccessURL=+&login=1clickBOM" + @country + "&_D%3Alogin=+&%2Fatg%2Fuserprofiling%2FProfileFormHandler.value.password=1clickBOM&_D%3A%2Fatg%2Fuserprofiling%2FProfileFormHandler.value.password=+&s=&_D%3A%2Fatg%2Fuserprofiling%2FProfileFormHandler.autoLogin=+&%2Fatg%2Fuserprofiling%2FProfileFormHandler.login.x=28&%2Fatg%2Fuserprofiling%2FProfileFormHandler.login.y=17&%2Fatg%2Fuserprofiling%2FProfileFormHandler.login=login&_D%3A%2Fatg%2Fuserprofiling%2FProfileFormHandler.login=+&_DARGS=%2Fjsp%2Fprofile%2Ffragments%2Flogin%2FloginFragment.jsp.loginfragment"
            post url, params, {}, (event) =>
                @_add_items [{part:"2334075", comment:"fixer", quantity:1}], () =>
                    @clearCart () =>
                        #logout
                        url3 = "http" + @site + "/jsp/home/homepage.jsp?_DARGS=/jsp/commonfragments/linkE14.jsp_A&_DAV="
                        get url3, {}, callback, callback
            () ->
                callback()

    clearCart: (callback) ->
        @clearing_cart = true
        @_get_item_ids (ids) =>
            @_post_clear ids, (result) =>
                if callback?
                    callback(result)
                @refreshSiteTabs()
                @refreshCartTabs()
                @clearing_cart = false

    _get_item_ids: (callback) ->
        url = "http" + @site + @cart
        get url, {}, (event) =>
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
            url = "http" + @site + "/jsp/checkout/paymentMethod.jsp"
            txt_1 = ""
            txt_2 = ""
            for id in ids
                txt_1 += "&/pf/commerce/CartHandler.removalCommerceIds=" + id
                txt_2 += "&" + id + "=1"
            params = "/pf/commerce/CartHandler.addItemCount=5&/pf/commerce/CartHandler.addLinesSuccessURL=../shoppingCart/shoppingCart.jsp&/pf/commerce/CartHandler.moveToPurchaseInfoErrorURL=../shoppingCart/shoppingCart.jsp&/pf/commerce/CartHandler.moveToPurchaseInfoSuccessURL=../checkout/paymentMethod.jsp&/pf/commerce/CartHandler.punchOutSuccessURL=orderReviewPunchOut.jsp" + txt_1 + "&/pf/commerce/CartHandler.setOrderErrorURL=../shoppingCart/shoppingCart.jsp&/pf/commerce/CartHandler.setOrderSuccessURL=../shoppingCart/shoppingCart.jsp&_D:/pf/commerce/CartHandler.addItemCount= &_D:/pf/commerce/CartHandler.addLinesSuccessURL= &_D:/pf/commerce/CartHandler.moveToPurchaseInfoErrorURL= &_D:/pf/commerce/CartHandler.moveToPurchaseInfoSuccessURL= &_D:/pf/commerce/CartHandler.punchOutSuccessURL= &_D:/pf/commerce/CartHandler.removalCommerceIds= &_D:/pf/commerce/CartHandler.setOrderErrorURL= &_D:/pf/commerce/CartHandler.setOrderSuccessURL= &_D:Submit= &_D:addEmptyLines= &_D:clearBlankLines= &_D:continueWithShipping= &_D:emptyLinesA= &_D:emptyLinesB= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote= &_D:lineNote1= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:lineQuantity= &_D:reqFromCart= &_D:textfield2= &_D:topUpdateCart= &_DARGS=/jsp/shoppingCart/fragments/shoppingCart/cartContent.jsp.cart&_dyncharset=UTF-8" + txt_2 + "&emptyLinesA=0&emptyLinesB=0&lineNote=&lineNote=&lineNote=&lineNote=&lineNote=&lineNote=&lineNote1=&lineQuantity=1&lineQuantity=1&lineQuantity=1&lineQuantity=1&lineQuantity=1&lineQuantity=1&reqFromCart=true&textfield2=&topUpdateCart=Update Basket"
            post url, params, {item:{part:"clear cart request", retailer:"Farnell"}}, (event) =>
                if callback?
                    callback({success:true})
            , () ->
                callback({success:false})
        else
          callback({success:true})

    addItems: (items, callback) ->
        @adding_items = true
        @_add_items items, (result) =>
            callback(result, this, items)
            @refreshCartTabs()
            @refreshSiteTabs()
            @adding_items = false
    _add_items: (items, callback) ->
        url = "http" + @site + @additem
        result = {success:true, fails:[]}
        params = "dyncharset=UTF-8&%2Fpf%2Fcommerce%2Forder%2FQuickPaste.buySuccessURL=%2Fjsp%2FshoppingCart%2FshoppingCart.jsp&_D%3A%2Fpf%2Fcommerce%2Forder%2FQuickPaste.buySuccessURL=+&%2Fpf%2Fcommerce%2Forder%2FQuickPaste.buyErrorURL=%2Fjsp%2FshoppingCart%2FquickPaste.jsp&_D%3A%2Fpf%2Fcommerce%2Forder%2FQuickPaste.buyErrorURL=+&_D%3AtextBox=+&textBox="
        for item in items
            params += encodeURIComponent(item.part + "," + item.quantity + ",\"" + item.comment + "\"\r\n")
        params += "&%2Fpf%2Fcommerce%2Forder%2FQuickPaste.addPasteProducts=Add+To+Basket&_D%3A%2Fpf%2Fcommerce%2Forder%2FQuickPaste.addPasteProducts=+&submitQuickPaste=Add+To+Basket&_D%3AsubmitQuickPaste=+&_DARGS=%2Fjsp%2FshoppingCart%2Ffragments%2FquickPaste%2FquickPaste.jsp.quickpaste"
        post url, params, {item:{part:"parts",retailer:"Farnell"}}, (event) =>
            #if items successully add the request returns the basket
            doc = DOM.parse(event.target.responseText)
            #we determine the request has returned the basket by the body
            #classname so it's language agnostic
            result.success = doc.querySelector("body.shoppingCart") != null
            if not result.success
                if items.length == 1
                    result.fails = items
                    callback(result)
                else
                    @_add_items_split items, (result) =>
                        if callback?
                            callback(result)
            else
                callback(result)
         , () ->
            callback({success:false, fails:items})

    _add_items_split: (items, callback) ->
        items1 = items[0..(items.length/2 - 1)]
        items2 = items[(items.length/2)..]
        @_add_items items1, (result1)  =>
            @_add_items items2, (result2) =>
                result = {success: result1.success && result2.success, fails: result1.fails.concat(result2.fails)}
                callback(result)
