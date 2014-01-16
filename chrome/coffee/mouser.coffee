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
        @viewstate = @get_viewstate()

    get_viewstate: ()->
        url = "http" + @site + @additem
        xhr = new XMLHttpRequest
        xhr.open "GET", url, false
        xhr.send()
        if xhr.status == 200
            doc = new DOMParser().parseFromString(xhr.responseText, "text/html")
            params = @additem_params
            params += encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
            params += "&ctl00$ContentMain$btnAddLines=Lines to Forms"
            params += "&ctl00$ContentMain$hNumberOfLines=5"
            params += "&ctl00$ContentMain$txtNumberOfLines=94"
            xhr2 = new XMLHttpRequest
            xhr2.open("POST", url, false)
            xhr2.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
            xhr2.send(params)
            if xhr2.status == 200
                doc = new DOMParser().parseFromString(xhr2.responseText, "text/html")
                return encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
    test_add : ()->
        params = @additem_params
        params += @viewstate
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
        params += "&ctl00$Footer1$sb=&ctl00$NavHeader$lblIsNewTerm=&ctl00$NavHeader$lblTrdTerm=&ctl00$NavHeader$txt1=&ctl00$gab1$ddlCurrencies=&ctl00$gab1$hidSelectedCurrency="
        xhr = new XMLHttpRequest
        url = "http://uk.mouser.com/EZBuy/EZBuy.aspx"
        xhr.open("POST", url, false)
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        xhr.send(params)
        if xhr.status == 200
            return xhr
