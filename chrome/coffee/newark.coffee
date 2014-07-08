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

class @Newark extends RetailerInterface
    constructor: (country_code, settings) ->
        super("Newark", country_code, "/data/newark_international.json", settings)
        @icon_src = chrome.extension.getURL("images/newark.png")

    addItems: (items, callback) ->
        @adding_items = true
        that = this
        url = "https" + @site + "/PasteOrderChangeServiceItemAdd"
        params = "storeId=10194&catalogId=15003&langId=-1&omItemAdd=quickPaste&URL=AjaxOrderItemDisplayView%3FstoreId%3D10194%26catalogId%3D15003%26langId%3D-1%26quickPaste%3D*&errorViewName=QuickOrderView&calculationUsage=-1%2C-2%2C-3%2C-4%2C-5%2C-6%2C-7&isQuickPaste=true&quickPaste="
        for item in items
            params += encodeURIComponent(item.part + "," + item.quantity + "," + item.comment + "\n")
        params += "&addToBasket=Add+to+Cart"
        post url, params, (event) ->
            that.refreshCartTabs()
            that.refreshSiteTabs()
            that.adding_items = false
