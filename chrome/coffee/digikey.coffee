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

class window.Digikey extends RetailerInterface
    constructor: (country_code, settings, callback) ->
        super("Digikey", country_code, "/data/digikey.json", settings, callback)

    clearCart: (callback) ->
        @clearing_cart = true
        url = "http" + @site + @cart + "?webid=-1"
        get url, {}, () =>
            if callback?
                callback({success:true})
            @refreshCartTabs()
            @clearing_cart = false
        , () =>
            if callback?
                callback({success:false})

    addItems: (items, callback) ->
        @adding_items = true
        @_add_items items, (result) =>
            if callback?
                callback(result, this, items)
            @refreshCartTabs()
            @adding_items = false

    _add_items: (items, callback) ->
        result = {success:true, fails:[]}
        count = items.length
        for item in items
            @_add_item item, (item, item_result) =>
                if not item_result.success
                    @_get_part_id item, (item, id) =>
                        @_get_suggested item, id, "NextBreakQuanIsLowerExtPrice"
                        , (new_item) =>
                            @_add_item new_item, (_, r) =>
                                if not r.success
                                    @_get_suggested new_item, id, "TapeReelQuantityTooLow"
                                    , (new_item) =>
                                        @_add_item new_item, (_, r) ->
                                            result.success &&= r.success
                                            result.fails = result.fails.concat(r.fails)
                                            count--
                                            if (count == 0)
                                                callback(result)
                                    , () ->
                                        result.success = false
                                        result.fails.push(item)
                                        count--
                                        if (count == 0)
                                            callback(result)
                                else
                                    count--
                                    if (count == 0)
                                        callback(result)
                        , () ->
                            result.success = false
                            result.fails.push(item)
                            count--
                            if (count == 0)
                                callback(result)
                    , () ->
                        result.success = false
                        result.fails.push(item)
                        count--
                        if (count == 0)
                            callback(result)
                else
                    count--
                    if (count == 0)
                        callback(result)
    _add_item: (item, callback) ->
        url = "http" + @site + @additem
        params = "qty=" + item.quantity + "&part=" + item.part + "&cref=" + item.comment
        result = {success:true, fails:[]}
        post url, params, {item:item, timeout:600000}, (event)->
            doc = DOM.parse(event.target.responseText)
            #if the cart returns with a quick-add quantity filled-in there was an error
            quick_add_quant = doc.querySelector("#ctl00_ctl00_mainContentPlaceHolder_mainContentPlaceHolder_txtQuantity")
            result.success = (quick_add_quant?) && (quick_add_quant.value?) && (quick_add_quant.value == "")
            if not result.success
                result.fails.push(event.target.item)
            callback(event.target.item, result)
        , (event) ->
            result.success = false
            if event.target?
                result.fails.push(event.target.item)
                callback(event.target.item, result)

    _get_part_id: (item, callback, error_callback) ->
        url = "http" + @site + "/product-detail/en/EXB-38V103JV/"
        url += item.part
        get url, {item:item, notify:false}, (event) ->
            doc = DOM.parse(event.target.responseText)
            inputs = doc.querySelectorAll("input")
            for input in inputs
                if input.name == "partid"
                    callback(event.target.item, input.value)
                    break
        , error_callback
    _get_suggested: (item, id, error, callback, error_callback) =>
        url = "http" + @site + "/classic/Ordering/PackTypeDialog.aspx?"
        url += "part=" + item.part
        url += "&qty=" + item.quantity
        url += "&partId=" + id
        url += "&error=" + error + "&cref=&esc=-1&returnURL=%2f%2fwww.digikey.co.uk%2fclassic%2fordering%2faddpart.aspx&fastAdd=false&showUpsell=True"
        get url, {item:item, notify:false}, (event) ->
            doc = DOM.parse(event.target.responseText)
            switch error
                when "TapeReelQuantityTooLow"       then choice = doc.getElementById("rb1")
                when "NextBreakQuanIsLowerExtPrice" then choice = doc.getElementById("rb2")
            if choice?
                label = choice.nextElementSibling
                if label?
                    number_str = label.innerText.split(String.fromCharCode(160))[0]
                    part       = label.innerText.split(String.fromCharCode(160))[2]
                    number = parseInt(number_str.replace(/,/,""))
                    if not isNaN(number)
                        it = event.target.item
                        it.part = part
                        it.quantity = number
                        callback(it)
                    else
                        error_callback()
                else
                    error_callback()
            else
                error_callback()
        , error_callback

