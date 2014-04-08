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
    addItems: (items, callback) ->
        #weird ASP shit, we need to get the viewstate first to put in every request
        @_get_adding_viewstate (that, viewstate, eventvalid) ->
            that._add_items(items, viewstate, eventvalid, callback)

    _add_items: (items, viewstate, eventvalid, callback) ->
        console.log({viewstate:viewstate, eventvalid:eventvalid})
        url = "http" + @site + @cart  
        params = "ctl00$sm1=ctl00$pageContentHolder$ctl00$updMain|ctl00$pageContentHolder$ctl00$btnUpdateCart&__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=" + viewstate + "&ctl00$dropMenu$ctl00$searchTerm=Search%20by%20keyword%20or%20part%20no&ctl00$pageContentHolder$ctl00$repCartItems$ctl00$txtStockCode=505-1441&ctl00$pageContentHolder$ctl00$repCartItems$ctl00$hidStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl00$hidLineId=-1&ctl00$pageContentHolder$ctl00$repCartItems$ctl00$txtQuantity=1&ctl00$pageContentHolder$ctl00$repCartItems$ctl01$txtStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl01$hidStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl01$hidLineId=-1&ctl00$pageContentHolder$ctl00$repCartItems$ctl01$txtQuantity=&ctl00$pageContentHolder$ctl00$repCartItems$ctl02$txtStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl02$hidStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl02$hidLineId=-1&ctl00$pageContentHolder$ctl00$repCartItems$ctl02$txtQuantity=&ctl00$pageContentHolder$ctl00$repCartItems$ctl03$txtStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl03$hidStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl03$hidLineId=-1&ctl00$pageContentHolder$ctl00$repCartItems$ctl03$txtQuantity=&ctl00$pageContentHolder$ctl00$repCartItems$ctl04$txtStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl04$hidStockCode=&ctl00$pageContentHolder$ctl00$repCartItems$ctl04$hidLineId=-1&ctl00$pageContentHolder$ctl00$repCartItems$ctl04$txtQuantity=&ctl00$pageContentHolder$ctl00$cmbAddRows=1&ctl00$pageContentHolder$ctl00$txtQuickOrder=Paste%20or%20type%20your%20list%20here%20and%20press%20'Add%20to%20Enquiry'.%0A%0AAdd%20one%20product%20per%20line.%0A%0AIf%20typing%2C%20use%20COMMAS%20between%20stock%20no%20and%20quantity.%0A%0AExample%3A%0A%0A4002713%2C1&ctl00$pageContentHolder$ctl00$txtPromoCode=&ctl00$pageContentHolder$ctl00$chkShowCartImages=on&ctl00$pageContentHolder$ctl00$poNumberConfirmText=&ctl00$pageContentHolder$ctl00$ucEmailShoppingCartColleague$txtName=&ctl00$pageContentHolder$ctl00$ucEmailShoppingCartColleague$txtContactEmail=&ctl00$pageContentHolder$ctl00$ucEmailShoppingCartColleague$txtContactNo=&ctl00$pageContentHolder$ctl00$ucEmailShoppingCartColleague$txtEmailTo=&ctl00$pageContentHolder$ctl00$ucEmailShoppingCartColleague$txtEmailSubject=&ctl00$pageContentHolder$ctl00$ucEmailShoppingCartColleague$txtMessageToRecipient=&__EVENTVALIDATION=" + eventvalid + "&ctl00$pageContentHolder$ctl00$btnUpdateCart.x=57&ctl00$pageContentHolder$ctl00$btnUpdateCart.y=15"
        xhr = new XMLHttpRequest
        xhr.open("POST", url, true)
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        xhr.onreadystatechange = (event) ->
            if event.currentTarget.readyState == 4
                console.log(event)
        xhr.send(params)
    _get_adding_viewstate: (callback)->
        that = this
        url = "http" + @site + @cart
        xhr = new XMLHttpRequest
        xhr.open("GET", url, true)
        xhr.onreadystatechange = (data) ->
            if xhr.readyState == 4 and xhr.status == 200
                doc = new DOMParser().parseFromString(xhr.responseText, "text/html")
                viewstate  = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                eventvalid = encodeURIComponent(doc.getElementById("__EVENTVALIDATION").value)
                callback(that, viewstate, eventvalid)
        xhr.send()
