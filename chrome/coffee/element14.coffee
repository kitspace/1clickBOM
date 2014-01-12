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

class @Element14 extends Retailer
    constructor: (country_code) ->
        return super "Element14", country_code, "/data/element14_international.json"

    clearCart: ->
        that = this
        chrome.cookies.remove {"name":"JSESSIONID","url":"http" + @site}, (cookie)->
            chrome.cookies.remove {"name":"CARTHOLDERID","url":"http" + that.site}, (cookie)->
                that.refreshCartTabs()
                that.refreshSiteTabs()

    addItems: (items)->
        that = this
        xhr = new XMLHttpRequest
        url = "https" + @site + @additem
        for item in items
            url += encodeURIComponent(item.part + "," + item.quantity + ",\"" + item.comment + "\"\r\n")
        xhr.onreadystatechange = () ->
            if xhr.readyState == 4
                that.refreshCartTabs()
                that.refreshSiteTabs()
        xhr.open "POST", url, true
        xhr.send()

