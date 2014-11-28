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

class window.Mouser extends RetailerInterface
    constructor: (country_code, settings) ->
        super "Mouser", country_code, "/data/mouser.json", settings
        #posting our sub-domain as the sites are all linked and switching countries would not register properly otherwise
        post "http" + @site + "/Preferences/SetSubdomain", "?subdomainName=" + @cart.split(".")[1].slice(3), {notify:false}, () ->
            ;
        , () ->
            ;
    addItems: (items, callback) ->
        @adding_items = true
        count = 0
        big_result = {success:true, fails:[]}
        @_get_cart_viewstate (viewstate) =>
            @_clear_errors viewstate, () =>
                @_get_adding_viewstate (viewstate) =>
                    for _,i in items by 99
                        _99_items = items[i..i+98]
                        count += 1
                        @_add_items _99_items, viewstate, (result) =>
                            big_result.success &&= result.success
                            big_result.fails = big_result.fails.concat(result.fails)
                            count -= 1
                            if count <= 0
                                callback(big_result, this, items)
                                @refreshCartTabs()
                                @adding_items = false
    _add_items: (items, viewstate, callback) ->
        params = @additem_params + viewstate
        params += "&ctl00$ContentMain$hNumberOfLines=99"
        params += "&ctl00$ContentMain$txtNumberOfLines=94"
        for item,i in items
            params += "&ctl00$ContentMain$txtCustomerPartNumber" + (i+1) + "=" + item.comment
            params += "&ctl00$ContentMain$txtPartNumber" + (i+1) + "=" + item.part
            params += "&ctl00$ContentMain$txtQuantity"   + (i+1) + "=" + item.quantity
        url = "http" + @site + @additem
        result = {success: true, fails:[]}
        post url, params, {}, (event) =>
            #if there is an error, there will be some error-class items with display set to ""
            doc = DOM.parse(event.target.responseText)
            errors = doc.getElementsByClassName("error")
            for error in errors
                if error.style.display == ""
                    # this padding5 error element just started appearing, doesn't indicate anything
                    if not (error.firstChild? && error.firstChild.nextSibling? && error.firstChild.nextSibling.className == "padding5")
                        part = error.getAttribute("data-partnumber")
                        if part?
                            for item in items
                                if item.part == part.replace(/-/g, '')
                                    result.fails.push(item)
                            result.success = false
            if callback?
                callback(result)
        , () ->
            if callback?
                callback({success:false, fails:items})

    _clear_errors: (viewstate, callback) ->
        post "http" + @site + @cart, "__EVENTARGUMENT=&__EVENTTARGET=&__SCROLLPOSITIONX=&__SCROLLPOSITIONY=&__VIEWSTATE=" + viewstate + "&__VIEWSTATEENCRYPTED=&ctl00$ctl00$ContentMain$btn3=Errors", {}, (event) =>
            doc = DOM.parse(event.target.responseText)
            viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
            post "http" + @site + @cart, "__EVENTARGUMENT=&__EVENTTARGET=&__SCROLLPOSITIONX=&__SCROLLPOSITIONY=&__VIEWSTATE=" + viewstate + "&__VIEWSTATEENCRYPTED=&ctl00$ContentMain$btn7=Update Basket", {}, (event) =>
               if callback?
                   callback()

    clearCart: (callback) ->
        @clearing_cart = true
        @_get_cart_viewstate (viewstate) =>
            @_clear_cart(viewstate, callback)
    _clear_cart: (viewstate, callback)->
        #don't ask, this is what works...
        url = "http" + @site + @cart
        params =  "__EVENTARGUMENT=&__EVENTTARGET=&__SCROLLPOSITIONX=&__SCROLLPOSITIONY=&__VIEWSTATE=" + viewstate + "&__VIEWSTATEENCRYPTED=&ctl00$ContentMain$btn7=Update Basket"
        post url, params, {}, (event) =>
            if callback?
                callback({success:true}, this)
            @refreshCartTabs()
            @clearing_cart = false
        , () =>
            if callback?
                callback({success:false}, this)
            @clearing_cart = false
    _get_adding_viewstate: (callback, arg)->
        #we get the quick-add form , extend it to 99 lines (the max) and get the viewstate from the response
        url = "http" + @site + @additem
        get url, {}, (event) =>
            doc = DOM.parse(event.target.responseText)
            params = @additem_params
            params += encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
            params += "&ctl00$ContentMain$btnAddLines=Lines to Forms"
            params += "&ctl00$ContentMain$hNumberOfLines=5"
            params += "&ctl00$ContentMain$txtNumberOfLines=94"
            post url, params, {}, (event) =>
                doc = DOM.parse(event.target.responseText)
                viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                if callback?
                    callback(viewstate, arg)
    _get_cart_viewstate: (callback)->
        url = "http" + @site + @cart
        get url, {}, (event) =>
            doc = DOM.parse(event.target.responseText)
            viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
            if callback?
                callback(viewstate)
