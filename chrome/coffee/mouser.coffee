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
        self = this
        super "Mouser", country_code, "/data/mouser_international.json", settings
        self.icon_src = chrome.extension.getURL("images/mouser.ico")
        #posting our sub-domain as the sites are all linked and switching countries would not register properly otherwise
        post  "http" + self.site + "/Preferences/SetSubdomain", "?subdomainName=" + self.cart.split(".")[0].slice(3), () ->
    addItems: (items, callback) ->
        self = this
        self.adding_items = true
        #weird ASP shit, we need to get the viewstate first to put in every request
        self._get_adding_viewstate (self, viewstate) ->
            self._add_items(items, viewstate, callback)
    _add_items: (items, viewstate, callback) ->
        self = this
        params = self.additem_params + viewstate
        params += "&ctl00$ContentMain$hNumberOfLines=99"
        params += "&ctl00$ContentMain$txtNumberOfLines=94"
        for item,i in items
            params += "&ctl00$ContentMain$txtCustomerPartNumber" + (i+1) + "=" + item.comment
            params += "&ctl00$ContentMain$txtPartNumber" + (i+1) + "=" + item.part
            params += "&ctl00$ContentMain$txtQuantity"   + (i+1) + "=" + item.quantity
        url = "http" + self.site + self.additem
        result = {success: true, fails:[]}
        post url, params, (event) ->
            #if there is an error, there will be some error-class items with display set to ""
            doc = DOM.parse(event.target.responseText)
            errors = doc.getElementsByClassName("error")
            for error in errors
                # this padding5 error element just started appearing, doesn't indicate anything
                if error.style.display == "" && error.firstChild.nextSibling.className != "padding5"
                    part = error.getAttribute("data-partnumber")
                    if part?
                        for item in items
                            if item.part == part
                                result.fails.push(item)
                        result.success = false
            if not result.success
                viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                self._clear_errors self, viewstate, () ->
                    if callback?
                        callback(result, self, items)
                    self.refreshCartTabs()
                    self.adding_items = false
            else
                if callback?
                    callback(result, self, items)
                self.refreshCartTabs()
                self.adding_items = false

    _clear_errors: (self, viewstate, callback) ->
        self = this
        post "http" + self.site + self.cart, "__EVENTARGUMENT=&__EVENTTARGET=&__SCROLLPOSITIONX=&__SCROLLPOSITIONY=&__VIEWSTATE=" + viewstate + "&__VIEWSTATEENCRYPTED=&ctl00$ctl00$ContentMain$btn3=Errors", (event) ->
            doc = DOM.parse(event.target.responseText)
            viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
            post "http" + self.site + self.cart, "__EVENTARGUMENT=&__EVENTTARGET=&__SCROLLPOSITIONX=&__SCROLLPOSITIONY=&__VIEWSTATE=" + viewstate + "&__VIEWSTATEENCRYPTED=&ctl00$ContentMain$btn7=Update Basket", (event) ->
               if callback?
                   callback(self)

    clearCart: (callback) ->
        self = this
        self.clearing_cart = true
        self._get_cart_viewstate (self, viewstate) ->
            self._clear_cart(viewstate, callback)
    _clear_cart: (viewstate, callback)->
        self = this
        #don't ask, this is what works...
        url = "http" + self.site + self.cart
        params =  "__EVENTARGUMENT=&__EVENTTARGET=&__SCROLLPOSITIONX=&__SCROLLPOSITIONY=&__VIEWSTATE=" + viewstate + "&__VIEWSTATEENCRYPTED=&ctl00$ContentMain$btn7=Update Basket"
        post url, params, (event) ->
            if callback?
                callback({success:true}, self)
            self.refreshCartTabs()
            self.clearing_cart = false
    _get_adding_viewstate: (callback)->
        #we get the quick-add form , extend it to 99 lines (the max) and get the viewstate from the response
        #TODO more than 99 items
        self = this
        url = "http" + self.site + self.additem
        get url, (event) ->
            doc = DOM.parse(event.target.responseText)
            params = self.additem_params
            params += encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
            params += "&ctl00$ContentMain$btnAddLines=Lines to Forms"
            params += "&ctl00$ContentMain$hNumberOfLines=5"
            params += "&ctl00$ContentMain$txtNumberOfLines=94"
            post url, params, (event) ->
                if event.target.status == 200
                    doc = DOM.parse(event.target.responseText)
                    viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                    if callback?
                        callback(self, viewstate)
    _get_cart_viewstate: (callback)->
        self = this
        url = "http" + self.site + self.cart
        get url, (event) ->
            doc = DOM.parse(event.target.responseText)
            viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
            if callback?
                callback(self, viewstate)
