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

class @RS extends RetailerInterface
    constructor: (country_code, settings) ->
        super("RS", country_code, "data/rs_international.json", settings)
        @icon_src = chrome.extension.getURL("images/rs.ico")
    clearCart: (callback) ->
        @_get_adding_viewstate_rs_online (that, viewstate, form_id) ->
            that._clear_cart(callback, viewstate)
    _clear_cart: (callback, viewstate, form_id) ->
        console.log(viewstate, form_id)
        if /web\/ca/.test(@cart)
            url = "http" + @site + @cart
            params = "AJAXREQUEST=_viewRoot&a4jCloseForm=a4jCloseForm&autoScroll=&javax.faces.ViewState=" + "j_id23" + "&a4jCloseForm%3Aj_id2364=a4jCloseForm%3Aj_id2364&"
            xhr = new XMLHttpRequest
            xhr.open("POST", url, true)
            xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
            xhr.onreadystatechange = (event) ->
                if event.target.readyState == 4
                    if callback?
                        callback({success: true})
            xhr.send(params)
        
    addItems: (items, callback) ->
        if /web\/ca/.test(@cart)
            @_get_adding_viewstate_rs_online (that, viewstate, form_id) ->
                that._add_items_rs_online(items, viewstate, form_id, callback)

    _add_items_rs_online: (items, viewstate, form_id, callback) ->
            url = "http" + @site + @cart
            params = "AJAXREQUEST=shoppingBasketForm%3A" + form_id + "&shoppingBasketForm=shoppingBasketForm&=QuickAdd&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_listItems="
            for item in items
                params += encodeURIComponent(item.part + "," + item.quantity + ",what_the_hell_is_cost_center?," + item.comment + "\n")

            params += "&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionModalLayerOpenedState=&javax.faces.ViewState=" + viewstate + "&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn=shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn&"

            xhr = new XMLHttpRequest
            xhr.open("POST", url, true)
            xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
            xhr.onreadystatechange = (event) ->
                if event.target.readyState == 4
                    console.log(event.target)

            xhr.send(params)
    _add_items_rsdelivers: (items, viewstate, eventvalid, callback) ->
            #url = "http" + @site + @cart
            #params = "ctl00$sm1=ctl00$pageContentHolder$ctl00$updMain|ctl00$pageContentHolder$ctl00$btnUpdateCart&__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=" + viewstate + "&ctl00$dropMenu$ctl00$searchTerm=Search%20by%20keyword%20or%20part%20no&ctl00$pageContentHolder$ctl00$repCartItems$ctl00$txtStockCode=505-1441&ctl00$pageContentHolder$ctl00$repCartItems$ctl00$hidStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl00$hidLineId=-1&ctl00$pageContentHolder$ctl00$repCartItems$ctl00$txtQuantity=1&ctl00$pageContentHolder$ctl00$repCartItems$ctl01$txtStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl01$hidStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl01$hidLineId=-1&ctl00$pageContentHolder$ctl00$repCartItems$ctl01$txtQuantity=&ctl00$pageContentHolder$ctl00$repCartItems$ctl02$txtStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl02$hidStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl02$hidLineId=-1&ctl00$pageContentHolder$ctl00$repCartItems$ctl02$txtQuantity=&ctl00$pageContentHolder$ctl00$repCartItems$ctl03$txtStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl03$hidStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl03$hidLineId=-1&ctl00$pageContentHolder$ctl00$repCartItems$ctl03$txtQuantity=&ctl00$pageContentHolder$ctl00$repCartItems$ctl04$txtStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl04$hidStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl04$hidLineId=-1&ctl00$pageContentHolder$ctl00$repCartItems$ctl04$txtQuantity=&ctl00$pageContentHolder$ctl00$cmbAddRows=1&ctl00$pageContentHolder$ctl00$txtQuickOrder=Paste%20or%20type%20your%20list%20here%20and%20press%20'Add%20to%20Enquiry'.%0A%0AAdd%20one%20product%20per%20line.%0A%0AIf%20typing%2C%20use%20COMMAS%20between%20stock%20no%20and%20quantity.%0A%0AExample%3A%0A%0A4002713%2C1&ctl00$pageContentHolder$ctl00$txtPromoCode=&ctl00$pageContentHolder$ctl00$chkShowCartImages=on&ctl00$pageContentHolder$ctl00$poNumberConfirmText=&ctl00$pageContentHolder$ctl00$ucEmailShoppingCartColleague$txtName=&ctl00$pageContentHolder$ctl00$ucEmailShoppingCartColleague$txtContactEmail=&ctl00$pageContentHolder$ctl00$ucEmailShoppingCartColleague$txtContactNo=&ctl00$pageContentHolder$ctl00$ucEmailShoppingCartColleague$txtEmailTo=&ctl00$pageContentHolder$ctl00$ucEmailShoppingCartColleague$txtEmailSubject=&ctl00$pageContentHolder$ctl00$ucEmailShoppingCartColleague$txtMessageToRecipient=&__EVENTVALIDATION=" + eventvalid + "&ctl00$pageContentHolder$ctl00$btnUpdateCart.x=57&ctl00$pageContentHolder$ctl00$btnUpdateCart.y=15"
            #xhr = new XMLHttpRequest
            #xhr.open("POST", url, true)
            #xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
            #xhr.onreadystatechange = (event) ->
            #    if event.currentTarget.readyState == 4
            #xhr.send(params)
    _get_adding_viewstate_rs_online: (callback)->
        that = this
        url = "http" + @site + @cart
        xhr = new XMLHttpRequest
        xhr.open("GET", url, true)
        xhr.onreadystatechange = (data) ->
            if xhr.readyState == 4 and xhr.status == 200
                doc = new DOMParser().parseFromString(xhr.responseText, "text/html")
                viewstate  = doc.getElementById("javax.faces.ViewState").value
                btn_doc = doc.getElementById("addToOrderDiv")
                #the form_id element is different values depending on signed in our signed out
                #could just hardcode them but maybe this will be more robust?
                #we use a regex here as DOM select methods crash on this element!
                form_id  = /AJAX.Submit\('shoppingBasketForm\:(j_id\d+)/.exec(btn_doc.innerHTML.toString())[1]
                callback(that, viewstate, form_id)
        xhr.send()
        #else
        #    url = "http" + @site + @cart
        #    xhr = new XMLHttpRequest
        #    xhr.open("GET", url, true)
        #    xhr.onreadystatechange = (data) ->
        #        if xhr.readyState == 4 and xhr.status == 200
        #            doc = new DOMParser().parseFromString(xhr.responseText, "text/html")
        #            viewstate  = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
        #            eventvalid = encodeURIComponent(doc.getElementById("__EVENTVALIDATION").value)
        #            callback(that, viewstate, eventvalid)
        #    xhr.send()
