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
        if /web\/ca/.test(@cart)
            @_get_clear_viewstate_rs_online (that, viewstate, form_id) ->
                that._clear_cart_rs_online(viewstate, form_id, callback)
    _clear_cart_rs_online: (viewstate, form_id, callback) ->
        that = this
        console.log(form_id)
        url = "http" + @site + @cart
        params1 = "AJAXREQUEST=_viewRoot&shoppingBasketForm=shoppingBasketForm&=ManualEntry&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3Aj_id1085=&shoppingBasketForm%3Aj_id1091=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_listItems=Paste%20or%20type%20your%20list%20here%20and%20click%20'Add'.&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1228=505-1441&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1248=1&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionModalLayerOpenedState=&shoppingBasketForm%3AsendToColleagueWidgetPanelOpenedState=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_senderName_decorate%3AGuestUserSendToColleagueWidgetAction_senderName=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_senderEmail_decorate%3AGuestUserSendToColleagueWidgetAction_senderEmail=name%40company.com&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_mailTo_decorate%3AGuestUserSendToColleagueWidgetAction_mailTo=name%40company.com&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_subject_decorate%3AGuestUserSendToColleagueWidgetAction_subject=Copy%20of%20order%20from%20RS%20Online&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_message_decorate%3AGuestUserSendToColleagueWidgetAction_message=&shoppingBasketForm%3AsendToColleagueSuccessWidgetPanelOpenedState=&javax.faces.ViewState=" + viewstate + "&shoppingBasketForm%3AremoveMultipleLink=shoppingBasketForm%3AremoveMultipleLink&"
        params2 = "AJAXREQUEST=_viewRoot&shoppingBasketForm=shoppingBasketForm&=ManualEntry&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3Aj_id1085=&shoppingBasketForm%3Aj_id1091=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_listItems=Paste%20or%20type%20your%20list%20here%20and%20click%20'Add'.&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1228=505-1441&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1248=1&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionModalLayerOpenedState=&shoppingBasketForm%3AsendToColleagueWidgetPanelOpenedState=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_senderName_decorate%3AGuestUserSendToColleagueWidgetAction_senderName=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_senderEmail_decorate%3AGuestUserSendToColleagueWidgetAction_senderEmail=name%40company.com&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_mailTo_decorate%3AGuestUserSendToColleagueWidgetAction_mailTo=name%40company.com&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_subject_decorate%3AGuestUserSendToColleagueWidgetAction_subject=Copy%20of%20order%20from%20RS%20Online&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_message_decorate%3AGuestUserSendToColleagueWidgetAction_message=&shoppingBasketForm%3AsendToColleagueSuccessWidgetPanelOpenedState=&javax.faces.ViewState=" + viewstate + "&shoppingBasketForm%3AclearBasketButton=shoppingBasketForm%3AclearBasketButton&"
        params3 = "AJAXREQUEST=_viewRoot&" + form_id + "=" + form_id + "&javax.faces.ViewState=" + viewstate + "&ajaxSingle=j_id2373%3Aj_id2378&j_id2373%3Aj_id2378=j_id2373%3Aj_id2378&"
        params4 = "AJAXREQUEST=_viewRoot&a4jCloseForm=a4jCloseForm&autoScroll=&javax.faces.ViewState=" + viewstate + "&a4jCloseForm%3Aj_id2364=a4jCloseForm%3Aj_id2364&"
        post url, params1, () ->
            post url, params2, () ->
                post url, params3, () ->
                    post url, params4, (event) ->
                        if event.target.status == 200
                            if callback?
                                callback({success:true})
                            that.refreshCartTabs()
                            that.refreshSiteTabs()

        
    addItems: (items, callback) ->
        if /web\/ca/.test(@cart)
            @_get_adding_viewstate_rs_online (that, viewstate, form_id) ->
                that._add_items_rs_online(items, viewstate, form_id, callback)

    _add_items_rs_online: (items, viewstate, form_ids, callback) ->
            that = this
            url = "http" + @site + @cart
            params = "AJAXREQUEST=shoppingBasketForm%3A" + form_id + "&shoppingBasketForm=shoppingBasketForm&=QuickAdd&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_listItems="
            for item in items
                params += encodeURIComponent(item.part + "," + item.quantity + ",what_the_hell_is_cost_center?," + item.comment + "\n")

            params += "&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionModalLayerOpenedState=&javax.faces.ViewState=" + viewstate + "&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn=shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn&"
            post url, params, () ->
                if callback?
                    callback({success:true})
                that.refreshCartTabs()
                that.refreshSiteTabs()
                
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
                #could just hardcode them but maybe this will be more future-proof?
                #we use a regex here as DOM select methods crash on this element!
                form_id  = /AJAX.Submit\('shoppingBasketForm\:(j_id\d+)/.exec(btn_doc.innerHTML.toString())[1]
                callback(that, viewstate, form_id)
        xhr.send()

    _get_clear_viewstate_rs_online: (callback)->
        that = this
        url = "http" + @site + @cart
        xhr = new XMLHttpRequest
        xhr.open("GET", url, true)
        xhr.onreadystatechange = (data) ->
            if xhr.readyState == 4 and xhr.status == 200
                doc = new DOMParser().parseFromString(xhr.responseText, "text/html")
                viewstate  = doc.getElementById("javax.faces.ViewState").value
                form = doc.getElementById("a4jCloseForm").nextElementSibling.nextElementSibling
                #the form_id elements are different values depending on signed in our signed out
                #could just hardcode them but maybe this will be more future-proof?
                #form_ids  =  [form.id

                #form_id  = /AJAX.Submit\('shoppingBasketForm\:(j_id\d+)/.exec(btn_doc.innerHTML.toString())[1]
                console.log(form.id)
                form_id2  = RegExp(/\"cssButton secondary red enabledBtn\" href=\"#\" id=\"j_id\d+\:(j_id\d+)"/).exec(form.innerHTML.toString())[1]
                console.log(form_id2)
                callback(that, viewstate, [form.id, form_id2])
        xhr.send()
