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

rsOnline =
    clearCart: (callback) ->
        @clearing_cart = true
        @_get_clear_viewstate (viewstate, form_ids) =>
            @_clear_cart viewstate, form_ids, (result) =>
                callback?(result, this)
                @refreshCartTabs()
                @refreshSiteTabs()
                @clearing_cart = false


    _clear_cart: (viewstate, form_ids, callback) ->
        url = "http#{@site}#{@cart}"
        http.post url, 'isRemoveAll=true', {}, () ->
            callback?({success:true})
        , () ->
            callback?({success:false})

    _clear_invalid: (callback) ->
        @_get_clear_viewstate (viewstate, form_ids) =>
            params1 = "AJAXREQUEST=_viewRoot&shoppingBasketForm=shoppingBasket\
            Form&=ManualEntry&=DELIVERY&shoppingBasketForm%3AquickStockNo_0=&s\
            hoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickStockNo_\
            1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickStoc\
            kNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3Aquick\
            StockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3Aq\
            uickStockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm\
            %3AquickStockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasket\
            Form%3AquickStockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBa\
            sketForm%3AquickStockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppi\
            ngBasketForm%3AquickStockNo_8=&shoppingBasketForm%3AquickQty_8=&sh\
            oppingBasketForm%3AquickStockNo_9=&shoppingBasketForm%3AquickQty_9\
            =&shoppingBasketForm%3Aj_id1085=&shoppingBasketForm%3Aj_id1091=&sh\
            oppingBasketForm%3AQuickOrderWidgetAction_quickOrderTextBox_decora\
            te%3AQuickOrderWidgetAction_listItems=Paste%20or%20type%20your%20l\
            ist%20here%20and%20click%20'Add'.&shoppingBasketForm%3Aj_id1182%3A\
            0%3Aj_id1228=505-1441&shoppingBasketForm%3Aj_id1182%3A0%3Aj_id1248\
            =1&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetAction\
            _promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionMod\
            alLayerOpenedState=&shoppingBasketForm%3AsendToColleagueWidgetPane\
            lOpenedState=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetA\
            ction_senderName_decorate%3AGuestUserSendToColleagueWidgetAction_s\
            enderName=&shoppingBasketForm%3AGuestUserSendToColleagueWidgetActi\
            on_senderEmail_decorate%3AGuestUserSendToColleagueWidgetAction_sen\
            derEmail=name%40company.com&shoppingBasketForm%3AGuestUserSendToCo\
            lleagueWidgetAction_mailTo_decorate%3AGuestUserSendToColleagueWidg\
            etAction_mailTo=name%40company.com&shoppingBasketForm%3AGuestUserS\
            endToColleagueWidgetAction_subject_decorate%3AGuestUserSendToColle\
            agueWidgetAction_subject=Copy%20of%20order%20from%20RS%20Online&sh\
            oppingBasketForm%3AGuestUserSendToColleagueWidgetAction_message_de\
            corate%3AGuestUserSendToColleagueWidgetAction_message=&shoppingBas\
            ketForm%3AsendToColleagueSuccessWidgetPanelOpenedState=&javax.face\
            s.ViewState=#{viewstate}"
            params2 = "AJAXREQUEST=_viewRoot&#{form_ids[0]}=#{form_ids[0]}&jav\
            ax.faces.ViewState=#{viewstate}&ajaxSingle=#{form_ids[0]}%3A\
            #{form_ids[1]}&#{form_ids[0]}%3A#{form_ids[1]}=#{form_ids[0]}%3A\
            #{form_ids[1]}&"
            params3 = "AJAXREQUEST=_viewRoot&a4jCloseForm=a4jCloseForm&autoScr\
            oll=&javax.faces.ViewState=#{viewstate}&a4jCloseForm%3A\
            #{form_ids[2]}=a4jCloseForm%3A#{form_ids[2]}&"

            p = http.promiseGet("http#{@site}#{@cart}")
            p.then (doc) =>
                error_lines = doc.querySelectorAll('.dataRow.errorRow')
                a = []
                for _ in error_lines
                    a.push(null)
                #for each line we basically click the 'remove' link which also
                #asks for confirmation
                chain = a.reduce (prev) =>
                    prev.then (_doc) =>
                        if not _doc?
                            return http.promiseGet("http#{@site}#{@cart}")
                        else
                            return Promise.resolve(_doc)
                    .then (_doc) =>
                        error_line = _doc?.querySelector('.dataRow.errorRow')
                            ?.querySelector('.quantityTd')
                        id = error_line?.children[3]?.children[0]?.id
                        param_id = params1 + '&' + encodeURIComponent(id)
                        http.promisePost("http#{@site}#{@cart}", param_id)
                    .then () =>
                        http.promisePost("http#{@site}#{@cart}", params2)
                    .then () =>
                        http.promisePost("http#{@site}#{@cart}", params3)
                , Promise.resolve(doc)
                chain.then () ->
                    callback({success:true})
                chain.catch () ->
                    callback({success:false})
            .catch () ->
                callback({success:false})


    addLines: (lines, callback) ->

        if lines.length == 0
            callback({success: true, fails: []})
            return

        @adding_lines = true

        add = (lines, callback) =>
            @_clear_invalid () =>
                @_get_adding_viewstate (viewstate, form_id) =>
                    @_add_lines(lines, viewstate, form_id, callback)

        end = (result) =>
            callback(result, this, lines)
            @refreshCartTabs()
            @refreshSiteTabs()
            @adding_lines = false

        add lines, (result) ->
            if not result.success
                #do a second pass with corrected quantities
                add result.fails, (_result) ->
                    end(_result)
            else
                end(result)

    _get_and_correct_invalid_lines: (callback) ->
        url = "http#{@site}#{@cart}"
        http.get url, {}, (event) =>
            doc = browser.parseDOM(event.target.responseText)
            lines = []
            for elem in doc.querySelectorAll('.dataRow.errorRow')
                line = {}
                #detect minimimum and multiple-of quantities from description
                #and add a quantity according to those. we read the quantity
                #from the cart as this could be a line that was already in
                #the cart when we added. description is of the form:
                #blabla 10 (minimum) blablabla 10 (multiple of) blabla
                # or
                #blabla 10 (multiple of) blabla
                descr = elem.previousElementSibling?.previousElementSibling
                    ?.firstElementChild?.innerHTML
                re_min_mul = /.*?(\d+).+(\d+).*?/
                min = re_min_mul.exec(descr)?[1]
                if not min?
                    re_mul = /.*?(\d+).*?/
                    mul = parseInt(re_mul.exec(descr)?[1])
                    quantity = parseInt(elem.querySelector('.quantityTd')
                        ?.firstElementChild?.value)
                    if (not isNaN(mul)) && (not isNaN(quantity))
                        line.quantity = quantity + (mul - (quantity % mul))
                else
                    min = parseInt(min)
                    if not isNaN(min)
                        line.quantity = min
                #detect part number
                error_child = elem.children?[1]
                error_input = error_child?.querySelector('input')
                if error_input?
                    line.part = error_input.value?.replace(/-/g,'')
                lines.push(line)
            callback(lines)
        , () ->
            callback([])


    _add_lines: (lines_incoming, viewstate, form_id, callback) ->
        result = {success:true, fails:[]}
        if lines_incoming.length > 500
            result.warnings = ["RS cart cannot hold more than 500 lines."]
            result.fails = lines[500..]
            lines = lines_incoming[0..499]
        else
            lines = lines_incoming
        url = "http#{@site}#{@cart}"
        params = "AJAXREQUEST=shoppingBasketForm%3A#{form_id}&shoppingBasketFo\
        rm=shoppingBasketForm&=QuickAdd&=DELIVERY&shoppingBasketForm%3AquickSt\
        ockNo_0=&shoppingBasketForm%3AquickQty_0=&shoppingBasketForm%3AquickSt\
        ockNo_1=&shoppingBasketForm%3AquickQty_1=&shoppingBasketForm%3AquickSt\
        ockNo_2=&shoppingBasketForm%3AquickQty_2=&shoppingBasketForm%3AquickSt\
        ockNo_3=&shoppingBasketForm%3AquickQty_3=&shoppingBasketForm%3AquickSt\
        ockNo_4=&shoppingBasketForm%3AquickQty_4=&shoppingBasketForm%3AquickSt\
        ockNo_5=&shoppingBasketForm%3AquickQty_5=&shoppingBasketForm%3AquickSt\
        ockNo_6=&shoppingBasketForm%3AquickQty_6=&shoppingBasketForm%3AquickSt\
        ockNo_7=&shoppingBasketForm%3AquickQty_7=&shoppingBasketForm%3AquickSt\
        ockNo_8=&shoppingBasketForm%3AquickQty_8=&shoppingBasketForm%3AquickSt\
        ockNo_9=&shoppingBasketForm%3AquickQty_9=&shoppingBasketForm%3AQuickOr\
        derWidgetAction_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_li\
        stItems="

        for line in lines
            params += encodeURIComponent("#{line.part},#{line.quantity},,\
            #{line.reference}\n")

        params += "&deliveryOptionCode=5&shoppingBasketForm%3APromoCodeWidgetA\
        ction_promotionCode=&shoppingBasketForm%3ApromoCodeTermsAndConditionMo\
        dalLayerOpenedState=&javax.faces.ViewState=#{viewstate}&shoppingBasket\
        Form%3AQuickOrderWidgetAction_quickOrderTextBox_decorate%3AQuickOrderW\
        idgetAction_quickOrderTextBoxbtn=shoppingBasketForm%3AQuickOrderWidget\
        Action_quickOrderTextBox_decorate%3AQuickOrderWidgetAction_quickOrderT\
        extBoxbtn&"

        http.post url, params, {}, (event) =>
            @_get_and_correct_invalid_lines (invalid_lines) =>
                success = invalid_lines.length == 0
                invalid = []
                if not success
                    for line in lines
                        for inv_line in invalid_lines
                            if line.part == inv_line.part
                                if inv_line.quantity?
                                    line.quantity = inv_line.quantity
                                invalid.push(line)
                callback?(
                    success:result.success && success
                    fails:result.fails.concat(invalid)
                    warnings:result.warnings
                , this, lines_incoming)
        , () =>
            callback?(
                success:false
                fails:result.fails.concat(lines)
            , this, lines_incoming)


    _get_adding_viewstate: (callback)->
        url = "http#{@site}#{@cart}"
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
            form_id  = /AJAX.Submit\('shoppingBasketForm\:(j_id\d+)/
                .exec(btn_doc.innerHTML.toString())[1]
            callback(viewstate, form_id)
        , () ->
            callback("", "")


    _get_clear_viewstate: (callback)->
        url = "http#{@site}#{@cart}"
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
                form_id3  = doc.getElementById("a4jCloseForm")
                    .firstChild.id.split(":")[1]
                callback(viewstate, [form.id, form_id2, form_id3])
            else
                return callback("", [])
        , () ->
            callback("", [])


rsDelivers =
    clearCart: (callback) ->
        @clearing_cart = true
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


    _clear_invalid: (callback) ->
        @_get_invalid_line_ids (ids) =>
            @_delete_invalid(ids, callback)


    _delete_invalid: (ids, callback) ->
        url = "http#{@site}/ShoppingCart/NcjRevampServicePage.aspx/\
        RemoveMultiple"
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


    _get_invalid_line_ids: (callback) ->
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


    addLines: (lines, callback) ->
        if lines.length == 0
            callback({success: true, fails: []})
            return
        @adding_lines = true
        @_add_lines lines, 0, {success:true, fails:[]}, (result) =>
            @adding_lines = false
            callback(result, this, lines)
            @refreshCartTabs()
            @refreshSiteTabs()


    #adds lines recursively in batches of 100 -- requests would timeout
    #otherwise
    _add_lines: (lines_incoming, i, result, callback) ->
        if i < lines_incoming.length
            lines = lines_incoming[i..i+99]
            @_clear_invalid () =>
                url = "http#{@site}/ShoppingCart/NcjRevampServicePage.aspx/\
                BulkOrder"
                params = '{"request":{"lines":"'
                for line in lines
                    params += "#{line.part},#{line.quantity},,\
                    #{line.reference}\n"
                params += '"}}'
                http.post url, params, {json:true}, (event) =>
                    doc = browser.parseDOM(
                        JSON.parse(event.target.responseText).html)
                    success = doc.querySelector("#hidErrorAtLineLevel")
                        .value == "0"
                    if not success
                        @_get_invalid_line_ids (ids, parts) =>
                            invalid = []
                            for line in lines
                                if line.part in parts
                                    invalid.push(line)
                            @_add_lines lines_incoming
                            , i+100
                            ,
                                success:false
                                fails:result.fails.concat(invalid)
                            , callback
                    else
                        @_add_lines(lines_incoming, i+100, result, callback)
                , () =>
                    @_add_lines lines_incoming
                    , i+100
                    , {success:false, fails:result.fails.concat(lines)}
                    , callback
        else
            callback(result)


class RS extends RetailerInterface
    constructor: (country_code, settings, callback) ->
        super('RS', country_code, 'data/rs.json', settings)
        if /web\/ca/.test(@cart)
            for name, method of rsOnline
                this[name] = method
        else
            for name, method of rsDelivers
                this[name] = method
        callback?()


exports.RS = RS
