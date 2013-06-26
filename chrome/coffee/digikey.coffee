#    This file is part of 1clickBOM.
#
#    1clickBOM is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License version 3
#    as published by the Free Software Foundation.
#
#    1clickBOM is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with 1clickBOM.  If not, see <http://www.gnu.org/licenses/>.

class @Digikey extends Retailer
    constructor: (country_code) ->
        return super "Digikey", country_code, "/data/digikey_international.json"

    clearCart: ->
        that = this
        if /classic/.test @cart
            #for the older sites we remove the cookies
            chrome.cookies.remove {"name":"sid", "url":"https" + @site}, (cookie)->
                that.refreshCartTabs()

        else if /ShoppingCartView/.test @cart
            #for the newer sites we send a POST request
            xhr = new XMLHttpRequest
            xhr.open "POST", "https" + @site + @cart + "?explicitNewOrder=Y"
            xhr.onreadystatechange = () ->
                if xhr.readyState == 4
                    that.refreshCartTabs()
            xhr.send()

    addItems: (items) ->
        that = this
        if /classic/.test @additem
            for item in items
                xhr = new XMLHttpRequest
                xhr.open "POST", "https" + @site + @additem + "?qty=" + item.quantity + "&part=" + item.part + "&cref=" + item.comment, true
                xhr.onreadystatechange = () ->
                    if xhr.readyState == 4
                        that.refreshCartTabs()
                xhr.send()
        else if /ShoppingCartView/.test @additem
            #we mimick the quick add form and send requests of 20 parts
            #this has to be done synchronously, else we get error:302
            for _, i in items by 20
                group = items[i..i+19]
                xhr = new XMLHttpRequest
                url = "https" + @site + "/ordering/AddPart?"
                for item,j in group
                    url += "&comment_" + (j+1) + "=" + item.comment
                    url += "&quantity_" + (j+1) + "=" + item.quantity
                    url += "&reportPartNumber_" + (j+1) + "=" + item.part
                xhr.open "POST", url, false
                xhr.send()
            that.refreshCartTabs()

     
     #getCart: ->
     #   that = this
     #   parser = new DOMParser
     #   xhr = new XMLHttpRequest
     #   xhr.open "GET", "https" + @site + @cart, false
     #   xhr.send()
     #   if xhr.status == 200
     #       doc = parser.parseFromString(xhr.responseText, "text/html")
     #   #table = doc.getElementById("ctl00_ctl00_mainContentPlaceHolder_mainContentPlaceHolder_ordOrderDetails").getElementsByTagName("tbody")[0]#.getElementsById("valSubtotal")[0]
     #   subtotal = doc.getElementById("valSubtotal").innerText
     #   subtotal = subtotal.replace(/\s*/g, '')
     #   subtotal = subtotal.replace(/€/g, '')
     #   subtotal = subtotal.replace(/\,/, '.')
     #   subtotal = parseFloat(subtotal)

     #   shipping = doc.getElementById("valShipping").innerText
     #   shipping = shipping.replace(/\s*/g, '')
     #   shipping = shipping.replace(/€/g, '')
     #   shipping = shipping.replace(/\,/, '.')
     #   shipping = parseFloat(shipping)

     #   total = doc.getElementById("valTotal").innerText
     #   total = total.replace(/\s*/g, '')
     #   if total == "unknown"
     #       total = NaN
     #   else
     #       total = total.replace(/€/g, '')
     #       total = total.replace(/\,/, '.')
     #       total = parseFloat(total)

     #   #table = table.getElementByTagName("tbody")[0]
     #   return {"subtotal":subtotal, "shipping":shipping, "total": total}
