# The contents of this file are subject to the Common Public Attribution
# License Version 1.0 (the “License”); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
# License Version 1.1 but Sections 14 and 15 have been added to cover use of
# software over a computer network and provide for limited attribution for the
# Original Developer. In addition, Exhibit A has been modified to be consistent
# with Exhibit B.
#
# Software distributed under the License is distributed on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations under
# the License.
#
# The Original Code is 1clickBOM.
#
# The Original Developer is the Initial Developer. The Original Developer of
# the Original Code is Kaspar Emanuel.

{RetailerInterface} = require './retailer_interface'
http      = require './http'
{browser} = require './browser'

class RS extends RetailerInterface
    constructor: (country_code, settings, callback) ->
        super('RS', country_code, 'data/rs.json', settings, callback)
    clearCart: (callback) ->
        @clearing_cart = true
        if /web\/ca/.test(@cart)
            @_get_clear_viewstate_rs_online (viewstate, form_ids) =>
                @_clear_cart_rs_online viewstate, form_ids, (result) =>
                    if callback?
                        callback(result, this)
                    @refreshCartTabs()
                    @refreshSiteTabs()
                    @clearing_cart = false
        else
            url = "http#{@site}/ShoppingCart/NcjRevampServicePage.aspx/EmptyCart"
            http.post url, '', {json:true}, (event) =>
                if callback?
                    callback({success: true}, this)
                @refreshSiteTabs()
                @refreshCartTabs()
                @clearing_cart = false
            , () =>
                callback({success: false}, this)
                @clearing_cart = false

    _clear_cart_rs_online: (viewstate, form_ids, callback) ->
        url = "http" + @site + @cart
        #TODO consolidate and move these massive strings somewhere sensible
        params1 = "AJAXREQUEST=_viewRoot&shoppingBasketForm=shoppingBasketForm&\
        =ManualEntry&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&shoppingBas\
        ketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBask\
        etForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBaske\
        tForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBasket\
        Form%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasketF\
        orm%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketFo\
        rm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketFor\
        m%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketForm\
        %3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm%\
        3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3\
        AquickQty_9=&shoppingBasketForm%3Aj_id1085=&shoppingBasketForm%3Aj_id10\
        91=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decor\
        ate%3AQuickOrderWidgetAction_listItems=Paste%20or%20type%20your%20list%\
        20here%20and%20click%20'Add'.&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1\
        228=505-1441&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1248=1&deliveryOpt\
        ionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&sho\
        ppingBasketForm%3ApromoCodeTermsAndConditionModalLayerOpenedState=&shop\
        pingBasketForm%3AsendToColleagueWidgetPanelOpenedState=&shoppingBasketF\
        orm%3AGuestUserSendToColleagueWidgetAction_senderName_decorate%3AGuestU\
        serSendToColleagueWidgetAction_senderName=&shoppingBasketForm%3AGuestUs\
        erSendToColleagueWidgetAction_senderEmail_decorate%3AGuestUserSendToCol\
        leagueWidgetAction_senderEmail=name%40company.com&shoppingBasketForm%3A\
        GuestUserSendToColleagueWidgetAction_mailTo_decorate%3AGuestUserSendToC\
        olleagueWidgetAction_mailTo=name%40company.com&shoppingBasketForm%3AGue\
        stUserSendToColleagueWidgetAction_subject_decorate%3AGuestUserSendToCol\
        leagueWidgetAction_subject=Copy%20of%20order%20from%20RS%20Online&shopp\
        ingBasketForm%3AGuestUserSendToColleagueWidgetAction_message_decorate%3\
        AGuestUserSendToColleagueWidgetAction_message=&shoppingBasketForm%3Asen\
        dToColleagueSuccessWidgetPanelOpenedState=&javax.faces.ViewState=\
        #{viewstate}&shoppingBasketForm%3AclearBasketButton=shoppingBasketForm%\
        3AclearBasketButton&"
        params2 = "AJAXREQUEST=_viewRoot&#{form_ids[0]}=#{form_ids[0]}&javax\
        .faces.ViewState=#{viewstate}&ajaxSingle=#{form_ids[0]}%3A\
        #{form_ids[1]}&#{form_ids[0]}%3A#{form_ids[1]}=#{form_ids[0]}%3A\
        #{form_ids[1]}&"
        params3 = "AJAXREQUEST=_viewRoot&a4jCloseForm=a4jCloseForm&autoScro\
        ll=&javax.faces.ViewState=#{viewstate}&a4jCloseForm%3A#{form_ids[2]}\
        =a4jCloseForm%3A#{form_ids[2]}&"
        http.post url, params1, {}, () ->
            http.post url, params2, {}, () ->
                http.post url, params3, {}, () ->
                   if callback?
                       callback({success:true})
                , () ->
                    if callback?
                        callback({success:false})
            , () ->
                if callback?
                    callback({success:false})
        , () ->
            if callback?
                callback({success:false})

    _clear_invalid_rs_online: (callback) ->

        url = "http" + @site + @cart

        @_get_clear_viewstate_rs_online (viewstate, form_ids) ->
            params1 = "AJAXREQUEST=_viewRoot&shoppingBasketForm=shoppingBasketForm\
            &=ManualEntry&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&shoppingBa\
            sketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBas\
            ketForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBask\
            etForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBaske\
            tForm%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasket\
            Form%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketF\
            orm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketFo\
            rm%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketFor\
            m%3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm\
            %3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%\
            3AquickQty_9=&shoppingBasketForm%3Aj_id1085=&shoppingBasketForm%3Aj_id1\
            091=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_deco\
            rate%3AQuickOrderWidgetAction_listItems=Paste%20or%20type%20your%20list\
            %20here%20and%20click%20'Add'.&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id\
            1228=505-1441&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1248=1&deliveryOp\
            tionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&sh\
            oppingBasketForm%3ApromoCodeTermsAndConditionModalLayerOpenedState=&sho\
            ppingBasketForm%3AsendToColleagueWidgetPanelOpenedState=&shoppingBasket\
            Form%3AGuestUserSendToColleagueWidgetAction_senderName_decorate%3AGuest\
            UserSendToColleagueWidgetAction_senderName=&shoppingBasketForm%3AGuestU\
            serSendToColleagueWidgetAction_senderEmail_decorate%3AGuestUserSendToCo\
            lleagueWidgetAction_senderEmail=name%40company.com&shoppingBasketForm%3\
            AGuestUserSendToColleagueWidgetAction_mailTo_decorate%3AGuestUserSendTo\
            ColleagueWidgetAction_mailTo=name%40company.com&shoppingBasketForm%3AGu\
            estUserSendToColleagueWidgetAction_subject_decorate%3AGuestUserSendToCo\
            lleagueWidgetAction_subject=Copy%20of%20order%20from%20RS%20Online&shop\
            pingBasketForm%3AGuestUserSendToColleagueWidgetAction_message_decorate%\
            3AGuestUserSendToColleagueWidgetAction_message=&shoppingBasketForm%3Ase\
            ndToColleagueSuccessWidgetPanelOpenedState=\
            &javax.faces.ViewState=#{viewstate}"
            params2 = "AJAXREQUEST=_viewRoot&#{form_ids[0]}=#{form_ids[0]}&javax\
            .faces.ViewState=#{viewstate}&ajaxSingle=#{form_ids[0]}%3A\
            #{form_ids[1]}&#{form_ids[0]}%3A#{form_ids[1]}=#{form_ids[0]}%3A\
            #{form_ids[1]}&"
            params3 = "AJAXREQUEST=_viewRoot&a4jCloseForm=a4jCloseForm&autoScro\
            ll=&javax.faces.ViewState=#{viewstate}&a4jCloseForm%3A#{form_ids[2]}\
            =a4jCloseForm%3A#{form_ids[2]}&"

            p = http.promiseGet(url)
            p.then (doc) ->
                error_items = doc.querySelectorAll('.errorRow')
                a = []
                for _ in error_items
                    a.push(null)
                chain = a.reduce (prev) ->
                    prev.then (_doc) ->
                        if not _doc?
                            return http.promiseGet(url)
                        else
                            return Promise.resolve(_doc)
                    .then (_doc) ->
                        error_item = _doc.querySelector('.errorRow')
                            .querySelector('.quantityTd')
                        id = error_item.children[3].children[0].id
                        param_id = params1 + '&' + encodeURIComponent(id)
                        http.promisePost(url, param_id)
                    .then () ->
                        http.promisePost(url, params2)
                    .then () ->
                        http.promisePost(url, params3)
                , Promise.resolve(doc)
                chain.then () ->
                    callback({success:true})
                chain.catch () ->
                    callback({success:false})
            .catch () ->
                callback({success:false})

    _get_invalid_item_ids_rs_online: (callback) ->
        url = "http" + @site + @cart
        http.get url, {}, (event) =>
            doc = browser.parseDOM(event.target.responseText)
            ids = []
            parts = []
            for elem in doc.querySelectorAll('.errorRow')
                error_quantity_input = elem.querySelector('.quantityTd')
                if error_quantity_input?
                    ids.push(error_quantity_input.children[3].children[0].id)
                error_child = elem.children[1]
                if error_child?
                    error_input = error_child.querySelector('input')
                    if error_input?
                        parts.push(error_input.value.replace(/-/g,''))
            callback(ids, parts)
        , () ->
            callback([],[])

    _clear_invalid_rs_delivers: (callback) ->
        @_get_invalid_item_ids_rs_delivers (ids) =>
            @_delete_invalid_rs_delivers(ids, callback)

    _delete_invalid_rs_delivers: (ids, callback) ->
        url = "http#{@site}/ShoppingCart/NcjRevampServicePage.aspx/RemoveMultiple"
        params = '{"request":{"encodedString":"'
        for id in ids
            params += id + "|"
        params += '"}}'
        http.post url, params, {json:true}, () ->
            if callback?
                callback()
        , () ->
            if callback?
                callback()

    _get_invalid_item_ids_rs_delivers: (callback) ->
        url = "http#{@site}/ShoppingCart/NcjRevampServicePage.aspx/GetCartHtml"
        http.post url, undefined, {json:true}, (event) ->
            doc = browser.parseDOM(JSON.parse(event.target.responseText).html)
            ids = []
            parts = []
            for elem in doc.getElementsByClassName("errorOrderLine")
                ids.push(elem.parentElement.nextElementSibling
                    .querySelector(".quantityTd").firstElementChild
                    .classList[3].split("_")[1])
                parts.push(elem.parentElement.nextElementSibling
                    .querySelector(".descriptionTd").firstElementChild
                    .nextElementSibling.firstElementChild.nextElementSibling
                    .innerText.trim())
            callback(ids, parts)
        , () ->
            callback([],[])

    addItems: (items, callback) ->
        @adding_items = true
        if /web\/ca/.test(@cart)
            @_clear_invalid_rs_online () =>
                @_get_adding_viewstate_rs_online (viewstate, form_id) =>
                    @_add_items_rs_online items, viewstate, form_id, (result) =>
                        callback(result, this, items)
                        @refreshCartTabs()
                        @refreshSiteTabs()
                        @adding_items = false

        else
            @_add_items_rs_delivers items, 0, {success:true, fails:[]}, (result) =>
                callback(result, this, items)
                @refreshCartTabs()
                @refreshSiteTabs()
                @adding_items = false

    #adds items recursively in batches of 100 -- requests would timeout otherwise
    _add_items_rs_delivers: (items_incoming, i, result, callback) ->
        if i < items_incoming.length
            items = items_incoming[i..i+99]
            @_clear_invalid_rs_delivers () =>
                url = "http#{@site}/ShoppingCart/NcjRevampServicePage.aspx/BulkOrder"
                params = '{"request":{"lines":"'
                for item in items
                    params += "#{item.part},#{item.quantity},,#{item.comment}\n"
                params += '"}}'
                http.post url, params, {json:true}, (event) =>
                    doc = browser.parseDOM(JSON.parse(event.target.responseText).html)
                    success = doc.querySelector("#hidErrorAtLineLevel").value == "0"
                    if not success
                        @_get_invalid_item_ids_rs_delivers (ids, parts) =>
                            invalid = []
                            for item in items
                                if item.part in parts
                                    invalid.push(item)
                            @_add_items_rs_delivers(items_incoming, i+100, {success:false, fails:result.fails.concat(invalid)}, callback)
                    else
                        @_add_items_rs_delivers(items_incoming, i+100, result, callback)
                , () =>
                    @_add_items_rs_delivers(items_incoming, i+100, {success:false, fails:result.fails.concat(items)}, callback)
        else
            callback(result)
    _add_items_rs_online: (items_incoming, viewstate, form_id, callback) ->
        result = {success:true, fails:[]}
        if items_incoming.length > 500
            result.warnings = ["RS cart cannot hold more than 500 lines."]
            result.fails = items[500..]
            items = items_incoming[0..499]
        else
            items = items_incoming
        url = "http" + @site + @cart
        params = "AJAXREQUEST=shoppingBasketForm%3A" + form_id + "&shoppingBasketForm=shoppingBasketForm&=QuickAdd&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickStockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_listItems="
        for item in items
            params += encodeURIComponent(item.part + "," + item.quantity + ",," + item.comment + "\n")

        params += "&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionModalLayerOpenedState=&javax.faces.ViewState=" + viewstate + "&shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn=shoppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderTextBoxbtn&"
        http.post url, params, {}, (event) =>
            @_get_invalid_item_ids_rs_online (ids, parts) =>
                success = parts.length == 0
                invalid = []
                if not success
                    for item in items
                        if item.part in parts
                            invalid.push(item)
                if callback?
                    callback({success:result.success && success, fails:result.fails.concat(invalid), warnings:result.warnings}, this, items_incoming)
                @refreshCartTabs()
                @refreshSiteTabs()
                @adding_items = false
        , () =>
            if callback?
                callback({success:false, fails:result.fails.concat(items)}, this, items_incoming)

    _get_adding_viewstate_rs_online: (callback)->
        url = "http" + @site + @cart
        http.get url, {}, (event) =>
            doc = browser.parseDOM(event.target.responseText)
            viewstate_element  = doc.getElementById("javax.faces.ViewState")
            if viewstate_element?
                viewstate = viewstate_element.value
            else
                return callback("", "")
            btn_doc = doc.getElementById("addToOrderDiv")
            #the form_id element is different values depending on signed in or
            #signed out could just hardcode them but maybe this will be more
            #future-proof?  we use a regex here as DOM select methods crash on
            #this element!
            form_id  = /AJAX.Submit\('shoppingBasketForm\:(j_id\d+)/.exec(btn_doc.innerHTML.toString())[1]
            callback(viewstate, form_id)
        , () ->
            callback("", "")

    _get_clear_viewstate_rs_online: (callback)->
        url = "http" + @site + @cart
        http.get url, {}, (event) =>
            doc = browser.parseDOM(event.target.responseText)
            viewstate_elem = doc.getElementById("javax.faces.ViewState")
            if viewstate_elem?
                viewstate = doc.getElementById("javax.faces.ViewState").value
            else
                return callback("", [])

            form_elem = doc.getElementById("a4jCloseForm")
            if form_elem?
                form = form_elem.nextElementSibling.nextElementSibling
                #the form_id elements are different values depending on signed
                #in or signed out could just hardcode them but maybe this will
                #be more future-proof?
                form_id2  = /"cssButton secondary red enabledBtn" href="#" id="j_id\d+\:(j_id\d+)"/.exec(form.innerHTML.toString())[1]
                form_id3  = doc.getElementById("a4jCloseForm").firstChild.id.split(":")[1]
                callback(viewstate, [form.id, form_id2, form_id3])
            else
                return callback("", [])
        , () ->
            callback("", [])

exports.RS = RS
