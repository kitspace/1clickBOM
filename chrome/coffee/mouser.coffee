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

class window.Mouser extends RetailerInterface
    constructor: (country_code, settings) ->
        super "Mouser", country_code, "/data/mouser.json", settings
        #posting our sub-domain as the sites are all linked and switching countries would not register properly otherwise
        post("http" + @site + "/Preferences/SetSubdomain", "?subdomainName=" + @cart.split(".")[0].slice(3), {}, () ->)
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
                # this padding5 error element just started appearing, doesn't indicate anything
                if error.style.display == "" && error.firstChild.nextSibling.className != "padding5"
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
