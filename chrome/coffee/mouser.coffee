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

class @Mouser extends Retailer
    constructor: (country_code) ->
        super "Mouser", country_code, "/data/mouser_international.json"
        @get_viewstate()
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
                xhr2.open("POST", url, false)
                xhr2.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
                xhr2.onreadystatechange = (data) ->
                    if xhr2.readyState == 4 and xhr2.status == 200
                        doc = new DOMParser().parseFromString(xhr2.responseText, "text/html")
                        that.viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                xhr2.send(params)
        xhr.send()
    addItems: (items) ->
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
        xhr.open("POST", url, false)
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        xhr.onreadystatechange = () ->
            if xhr.readyState == 4
                that.refreshCartTabs()
        xhr.send(params)

    test_add : ()->
        params = @additem_params + @viewstate
        params += "&ctl00$ContentMain$hNumberOfLines=99"
        params += "&ctl00$ContentMain$txtNumberOfLines=94"
        params += "&ctl00$ContentMain$txtCustomerPartNumber1=tabby"
        params += "&ctl00$ContentMain$txtPartNumber1=607-GALILEO"
        params += "&ctl00$ContentMain$txtQuantity1=1"
        params += "&ctl00$ContentMain$txtCustomerPartNumber2=tobby"
        params += "&ctl00$ContentMain$txtPartNumber2=607-GALILEO"
        params += "&ctl00$ContentMain$txtQuantity2=1"
        params += "&ctl00$ContentMain$txtCustomerPartNumber3=tobby"
        params += "&ctl00$ContentMain$txtPartNumber3=607-GALILEO"
        params += "&ctl00$ContentMain$txtQuantity3=1"
        params += "&ctl00$ContentMain$txtCustomerPartNumber4=tobby"
        params += "&ctl00$ContentMain$txtPartNumber4=607-GALILEO"
        params += "&ctl00$ContentMain$txtQuantity4=1"
        params += "&ctl00$ContentMain$txtCustomerPartNumber5=tar"
        params += "&ctl00$ContentMain$txtPartNumber5=611-PTS530GN055SMTR"
        params += "&ctl00$ContentMain$txtQuantity5=1"
        params += "&ctl00$ContentMain$txtCustomerPartNumber6=tooba"
        params += "&ctl00$ContentMain$txtPartNumber6=607-GALILEO"
        params += "&ctl00$ContentMain$txtQuantity6=1"
        xhr = new XMLHttpRequest
        url = "http" + @site + @additem
        xhr.open("POST", url, false)
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        xhr.send(params)
        if xhr.status == 200
            @refreshCartTabs()
