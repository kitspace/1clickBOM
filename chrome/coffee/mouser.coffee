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

class @Mouser extends RetailerInterface
    constructor: (country_code, settings) ->
        super "Mouser", country_code, "/data/mouser_international.json", settings
        that = this
        xhr = new XMLHttpRequest
        xhr.open("POST", "http://uk.mouser.com/api/Preferences/SetSubdomain?subdomainName=" + @cart.split(".")[0].slice(3), true)
        xhr.onreadystatechange = ()->
            that.get_viewstate()
        xhr.send()
        @icon_src = chrome.extension.getURL("images/mouser.ico")
    get_viewstate: ()->
        that = this
        url = "http" + @site + @additem
        xhr = new XMLHttpRequest
        xhr.open "GET", url, true
        xhr.onreadystatechange = (data) ->
            if xhr.readyState == 4 and xhr.status == 200
                doc = new DOMParser().parseFromString(xhr.responseText, "text/html")
                params = that.additem_params
                params += encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                params += "&ctl00$ContentMain$btnAddLines=Lines to Forms"
                params += "&ctl00$ContentMain$hNumberOfLines=5"
                params += "&ctl00$ContentMain$txtNumberOfLines=94"
                xhr2 = new XMLHttpRequest
                xhr2.open("POST", url, true)
                xhr2.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
                xhr2.onreadystatechange = (data) ->
                    if xhr2.readyState == 4 and xhr2.status == 200
                        doc = new DOMParser().parseFromString(xhr2.responseText, "text/html")
                        that.viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                xhr2.send(params)
        xhr.send()
    _get_viewstate: (callback)->
        that = this
        url = "http" + @site + @cart
        xhr = new XMLHttpRequest
        xhr.open "GET", url, true
        xhr.onreadystatechange = (data) ->
            if xhr.readyState == 4 and xhr.status == 200
                doc = new DOMParser().parseFromString(xhr.responseText, "text/html")
                that.viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                callback(that)
        xhr.send()
    addItems: (items) ->
        #wait for viewstate if we don't have it
        that = this
        id = setInterval ()->
            if that.viewstate != undefined
                that._addItems(items)
                clearInterval(id)
        , 1
        #timeout in-case we can't get it
        setTimeout ()->
            clearInterval(id)
        , 5000
    _addItems: (items) ->
        that = this
        params = @additem_params + @viewstate
        params += "&ctl00$ContentMain$hNumberOfLines=99"
        params += "&ctl00$ContentMain$txtNumberOfLines=94"
        for item,i in items
            params += "&ctl00$ContentMain$txtCustomerPartNumber" + (i+1) + "=" + item.comment
            params += "&ctl00$ContentMain$txtPartNumber" + (i+1) + "=" + item.part
            params += "&ctl00$ContentMain$txtQuantity"   + (i+1) + "=" + item.quantity
        url = "http" + @site + @additem
        xhr = new XMLHttpRequest
        xhr.open("POST", url, true)
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        xhr.onreadystatechange = () ->
            if xhr.readyState == 4
                that.refreshCartTabs()
        xhr.send(params)

    #clearCart: ->
    #    that = this
    #    chrome.cookies.remove {"name":"ASP.NET_SessionId","url":"http" + "://mouser.com"}, (cookie)->
    #        chrome.cookies.remove {"name":"CARTCOOKIEUUID","url":"http" + "://mouser.com"}, (cookie)->
    #            that.refreshCartTabs()
    #            that.refreshSiteTabs()
    clearCart: () ->
        @_get_viewstate(@_clearCart)
    _clearCart: (that)->
        xhr = new XMLHttpRequest
        xhr.open("POST", "http://uk.mouser.com/Cart/Cart.aspx", true)
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        xhr.onreadystatechange = () ->
            if xhr.readyState == 4
                that.refreshCartTabs()
                that.refreshSiteTabs()
        xhr.send("__EVENTARGUMENT=&__EVENTTARGET=&__SCROLLPOSITIONX=&__SCROLLPOSITIONY=&__VIEWSTATE=" + that.viewstate + "&__VIEWSTATEENCRYPTED=&ctl00$ContentMain$btn7=Update Basket")
