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

class window.RS extends RetailerInterface
    constructor: (country_code, settings) ->
        self = this
        super("RS", country_code, "data/rs_international.json", settings)
        self.icon_src = chrome.extension.getURL("images/rs.ico")
    clearCart: (callback) ->
        self = this
        self.clearing_cart = true
        if /web\/ca/.test(self.cart)
            self._get_clear_viewstate_rs_online (self, viewstate, form_ids) ->
                self._clear_cart_rs_online(viewstate, form_ids, callback)
        else
            url = "http" + self.site + "/ShoppingCart/NcjRevampServicePage.aspx/EmptyCart"
            post url, "", (event) ->
                if callback?
                    callback({success: true}, self)
                self.refreshSiteTabs()
                self.refreshCartTabs()
                self.clearing_cart = false
            , item=undefined , json=true
    _clear_cart_rs_online: (viewstate, form_ids, callback) ->
        self = this
        url = "http" + self.site + self.cart
        #TODO get rid of these massive strings
        params1 = "AJAXREQUEST=_viewRoot&shoppingBasketForm=shoppingBasketForm&=ManualEntry&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3Aj_id1085=&shoppingBasketForm%3Aj_id1091=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_listItems=Paste%20or%20type%20your%20list%20here%20and%20click%20'Add'.&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1228=505-1441&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1248=1&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionModalLayerOpenedState=&shoppingBasketForm%3AsendToColleagueWidgetPanelOpenedState=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_senderName_decorate%3AGuestUserSendToColleagueWidgetAction_senderName=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_senderEmail_decorate%3AGuestUserSendToColleagueWidgetAction_senderEmail=name%40company.com&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_mailTo_decorate%3AGuestUserSendToColleagueWidgetAction_mailTo=name%40company.com&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_subject_decorate%3AGuestUserSendToColleagueWidgetAction_subject=Copy%20of%20order%20from%20RS%20Online&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_message_decorate%3AGuestUserSendToColleagueWidgetAction_message=&shoppingBasketForm%3AsendToColleagueSuccessWidgetPanelOpenedState=&javax.faces.ViewState=" + viewstate + "&shoppingBasketForm%3AremoveMultipleLink=shoppingBasketForm%3AremoveMultipleLink&"
        params2 = "AJAXREQUEST=_viewRoot&shoppingBasketForm=shoppingBasketForm&=ManualEntry&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3Aj_id1085=&shoppingBasketForm%3Aj_id1091=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_listItems=Paste%20or%20type%20your%20list%20here%20and%20click%20'Add'.&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1228=505-1441&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1248=1&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionModalLayerOpenedState=&shoppingBasketForm%3AsendToColleagueWidgetPanelOpenedState=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_senderName_decorate%3AGuestUserSendToColleagueWidgetAction_senderName=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_senderEmail_decorate%3AGuestUserSendToColleagueWidgetAction_senderEmail=name%40company.com&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_mailTo_decorate%3AGuestUserSendToColleagueWidgetAction_mailTo=name%40company.com&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_subject_decorate%3AGuestUserSendToColleagueWidgetAction_subject=Copy%20of%20order%20from%20RS%20Online&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_message_decorate%3AGuestUserSendToColleagueWidgetAction_message=&shoppingBasketForm%3AsendToColleagueSuccessWidgetPanelOpenedState=&javax.faces.ViewState=" + viewstate + "&shoppingBasketForm%3AclearBasketButton=shoppingBasketForm%3AclearBasketButton&"
        params3 = "AJAXREQUEST=_viewRoot&" + form_ids[0] + "=" + form_ids[0] + "&javax.faces.ViewState=" + viewstate + "&ajaxSingle=" + form_ids[0] + "%3A" + form_ids[1] + "&" + form_ids[0] + "%3A" + form_ids[1] + "=" + form_ids[0] + "%3A" + form_ids[1] + "&"
        params4 = "AJAXREQUEST=_viewRoot&a4jCloseForm=a4jCloseForm&autoScroll=&javax.faces.ViewState=" + viewstate + "&a4jCloseForm%3A" + form_ids[2] + "=a4jCloseForm%3A" + form_ids[2] + "&"
        post url, params1, () ->
            post url, params2, () ->
                post url, params3, () ->
                    post url, params4, (event) -> #stairway to heaven lol
                       if callback?
                           callback({success:true}, self)
                       self.refreshCartTabs()
                       self.refreshSiteTabs()
                       self.clearing_cart = false
    _clear_invalid_rs_online: (callback) ->
        self = this
        if /web\/ca/.test(self.cart)
            self = this
            self._get_invalid_item_ids_rs_online (ids) ->
                if ids.length == 0
                    if callback?
                        callback()
                else
                    self._get_invalid_viewstate_rs_online (self, viewstate, form_ids) ->
                        self._delete_invalid_rs_online(viewstate, form_ids, ids, callback)
    _get_invalid_item_ids_rs_online: (callback) ->
        self = this
        url = "http" + self.site + self.cart
        get url, (event) ->
            doc = DOM.parse(event.target.responseText)
            ids = []
            parts = []
            for elem in doc.querySelectorAll(".errorRow")
                ids.push(elem.firstElementChild.nextElementSibling.querySelector("input").name.split(":")[2])
                parts.push(elem.firstElementChild.nextElementSibling.querySelector("input").value)
            callback(ids, parts)
    _clear_invalid_rs_delivers: (callback) ->
        self = this
        self._get_invalid_item_ids_rs_delivers (ids) ->
            self._delete_invalid_rs_delivers(ids, callback)
    _delete_invalid_rs_delivers: (ids, callback) ->
        self = this
        url = "http" + self.site + "/ShoppingCart/NcjRevampServicePage.aspx/RemoveMultiple"
        params = '{"request":{"encodedString":"'
        for id in ids
            params += id + "|"
        params += '"}}'
        post url, params, (event) ->
            if callback?
                callback()
        ,item=undefined, json=true



    _get_invalid_item_ids_rs_delivers: (callback) ->
        self = this
        url = "http" + self.site + "/ShoppingCart/NcjRevampServicePage.aspx/GetCartHtml"
        post url, undefined, (event) ->
            doc = DOM.parse(JSON.parse(event.target.responseText).html)
            ids = []
            parts = []
            for elem in doc.getElementsByClassName("errorOrderLine")
                ids.push(elem.parentElement.nextElementSibling.querySelector(".quantityTd").firstElementChild.classList[3].split("_")[1])
                parts.push(trim_whitespace(elem.parentElement.nextElementSibling.querySelector(".descriptionTd").firstElementChild.nextElementSibling.firstElementChild.nextElementSibling.innerText))
            callback(ids, parts)
        ,item=undefined, json=true

    _delete_invalid_rs_online: (viewstate, form_ids, ids, callback) ->
        self = this
        url = "http" + self.site + self.cart
        #TODO get rid of these massive strings
        params1 = "AJAXREQUEST=_viewRoot&shoppingBasketForm=shoppingBasketForm&=ManualEntry&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3Aj_id1085=&shoppingBasketForm%3Aj_id1091=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_listItems=Paste%20or%20type%20your%20list%20here%20and%20click%20'Add'.&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1228=505-1441&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1248=1&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionModalLayerOpenedState=&shoppingBasketForm%3AsendToColleagueWidgetPanelOpenedState=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_senderName_decorate%3AGuestUserSendToColleagueWidgetAction_senderName=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_senderEmail_decorate%3AGuestUserSendToColleagueWidgetAction_senderEmail=name%40company.com&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_mailTo_decorate%3AGuestUserSendToColleagueWidgetAction_mailTo=name%40company.com&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_subject_decorate%3AGuestUserSendToColleagueWidgetAction_subject=Copy%20of%20order%20from%20RS%20Online&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_message_decorate%3AGuestUserSendToColleagueWidgetAction_message=&shoppingBasketForm%3AsendToColleagueSuccessWidgetPanelOpenedState=&javax.faces.ViewState=" + viewstate + "&shoppingBasketForm%3AremoveMultipleLink=shoppingBasketForm%3AremoveMultipleLink&"
        params2 = "AJAXREQUEST=_viewRoot&shoppingBasketForm=shoppingBasketForm&=ManualEntry&shoppingBasketForm%3AquickStockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3Aj_id1085=&shoppingBasketForm%3Aj_id1045=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_listItems=F%C3%BCgen%20Sie%20hier%20die%20gew%C3%BCnschten%20Produkte%20ein%20und%20klicken%20Sie%20auf%20'Hinzuf%C3%BCgen'."
        for id in ids
            params2 += "&shoppingBasketForm%3A" + form_ids[3] + "%3A" + id + "%3Achk_=on"

        #hack on-top of a hack, let's hope they retire the site before it
        #becomes a problem
        if form_ids[3] == "j_id1136"
            form_id5 = "j_id1541"
        else
            form_id5 = "j_id1587"

        params2 += "&shoppingBasketForm%3A" + form_ids[3] + "%3A0%3Aj_id1180=fail&shoppingBasketForm%3A" + form_ids[3] + "%3A0%3Aj_id1202=2&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionModalLayerOpenedState=&shoppingBasketForm%3AsendToColleagueWidgetPanelOpenedState=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_senderName_decorate%3AGuestUserSendToColleagueWidgetAction_senderName=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_senderEmail_decorate%3AGuestUserSendToColleagueWidgetAction_senderEmail=name%40firma.at&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_mailTo_decorate%3AGuestUserSendToColleagueWidgetAction_mailTo=name%40firma.at&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_subject_decorate%3AGuestUserSendToColleagueWidgetAction_subject=Kopie%20des%20Warenkorbs&shoppingBasketForm%3AGuestUserSendToColleagueWidgetAction_message_decorate%3AGuestUserSendToColleagueWidgetAction_message=&shoppingBasketForm%3AsendToColleagueSuccessWidgetPanelOpenedState=&javax.faces.ViewState=" + viewstate + "&shoppingBasketForm%3A" + form_id5 + "=shoppingBasketForm%3A" + form_id5 + "&"

        params3 = "AJAXREQUEST=_viewRoot&" + form_ids[0] + "=" + form_ids[0] + "&javax.faces.ViewState=" + viewstate + "&ajaxSingle=" + form_ids[0] + "%3A" + form_ids[1] + "&" + form_ids[0] + "%3A" + form_ids[1] + "=" + form_ids[0] + "%3A" + form_ids[1] + "&"
        params4 = "AJAXREQUEST=_viewRoot&a4jCloseForm=a4jCloseForm&autoScroll=&javax.faces.ViewState=" + viewstate + "&a4jCloseForm%3A" + form_ids[2] + "=a4jCloseForm%3A" + form_ids[2] + "&"
        post url, params1, () ->
            post url, params2, () ->
                post url, params3, () ->
                    post url, params4, (event) -> #stairway to heaven lol
                        if event.target.status == 200
                            if callback?
                                callback()
                            self.refreshCartTabs()
                            self.refreshSiteTabs()
                            self.clearing_cart = false

    addItems: (items, callback) ->
        self = this
        self.adding_items = true
        if /web\/ca/.test(self.cart)
            self._clear_invalid_rs_online () ->
                self._get_adding_viewstate_rs_online (self, viewstate, form_id) ->
                    self._add_items_rs_online(items, viewstate, form_id, callback)
        else
            self._clear_invalid_rs_delivers () ->
                url = "http" + self.site + "/ShoppingCart/NcjRevampServicePage.aspx/BulkOrder"
                params = '{"request":{"lines":"'
                for item in items
                    params += item.part + "," + item.quantity + ",what_the_hell_is_cost_center," + item.comment + "\n"
                params += '"}}'
                post url, params, (event) ->
                    doc = DOM.parse(JSON.parse(event.target.responseText).html)
                    success = doc.querySelector("#hidErrorAtLineLevel").value == "0"
                    if not success
                        if callback?
                            self._get_invalid_item_ids_rs_delivers (ids, parts) ->
                                invalid = []
                                for item in items
                                    if item.part in parts
                                        invalid.push(item)
                                callback({success:false, fails:invalid}, self, items)
                    else
                        if callback?
                            callback({success:true, fails:[]}, self, items)
                    self.refreshCartTabs()
                    self.refreshSiteTabs()
                    self.adding_items = false
                , item=undefined, json=true

    _add_items_rs_online: (items, viewstate, form_id, callback) ->
        self = this
        url = "http" + self.site + self.cart
        params = "AJAXREQUEST=shoppingBasketForm%3A" + form_id + "&shoppingBasketForm=shoppingBasketForm&=QuickAdd&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_listItems="
        for item in items
            params += encodeURIComponent(item.part + "," + item.quantity + ",what_the_hell_is_cost_center?," + item.comment + "\n")

        params += "&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionModalLayerOpenedState=&javax.faces.ViewState=" + viewstate + "&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn=shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn&"
        post url, params, (event) ->
            self._get_invalid_item_ids_rs_online (ids, parts) ->
                success = parts.length == 0
                invalid = []
                if not success
                    for item in items
                        if item.part in parts
                            invalid.push(item)
                if callback?
                    callback({success:success, fails:invalid}, self, items)
                self.refreshCartTabs()
                self.refreshSiteTabs()
                self.adding_items = false

    _get_adding_viewstate_rs_online: (callback)->
        self = this
        url = "http" + self.site + self.cart
        get url, (event) ->
            doc = DOM.parse(event.target.responseText)
            viewstate  = doc.getElementById("javax.faces.ViewState").value
            btn_doc = doc.getElementById("addToOrderDiv")
            #the form_id element is different values depending on signed in or signed out
            #could just hardcode them but maybe this will be more future-proof?
            #we use a regex here as DOM select methods crash on this element!
            form_id  = /AJAX.Submit\('shoppingBasketForm\:(j_id\d+)/.exec(btn_doc.innerHTML.toString())[1]
            callback(self, viewstate, form_id)
        , () ->
            callback(self, "", "")

    _get_clear_viewstate_rs_online: (callback)->
        self = this
        url = "http" + self.site + self.cart
        get url, (event) ->
            doc = DOM.parse(event.target.responseText)
            viewstate  = doc.getElementById("javax.faces.ViewState").value
            form = doc.getElementById("a4jCloseForm").nextElementSibling.nextElementSibling
            #the form_id elements are different values depending on signed in or signed out
            #could just hardcode them but maybe this will be more future-proof?
            form_id2  = /"cssButton secondary red enabledBtn" href="#" id="j_id\d+\:(j_id\d+)"/.exec(form.innerHTML.toString())[1]
            form_id3  = doc.getElementById("a4jCloseForm").firstChild.id.split(":")[1]
            callback(self, viewstate, [form.id, form_id2, form_id3])
        , () ->
            callback(self, "", [])

    _get_invalid_viewstate_rs_online: (callback)->
        self = this
        url = "http" + self.site + self.cart
        get url, (event) ->
            doc = DOM.parse(event.target.responseText)
            viewstate  = doc.getElementById("javax.faces.ViewState").value
            form = doc.getElementById("a4jCloseForm").nextElementSibling.nextElementSibling
            #the form_id elements are different values depending on signed in or signed out
            #could just hardcode them but maybe this will be more future-proof?
            form_id2  = /"cssButton secondary red enabledBtn" href="#" id="j_id\d+\:(j_id\d+)"/.exec(form.innerHTML.toString())[1]
            form_id3  = doc.getElementById("a4jCloseForm").firstChild.id.split(":")[1]
            form_id4  = /"shoppingBasketForm:(j_id\d+):\d+:chk_"/.exec(event.target.responseText)[1]
            callback(self, viewstate, [form.id, form_id2, form_id3, form_id4])
        , () ->
            callback(self, "", [])

