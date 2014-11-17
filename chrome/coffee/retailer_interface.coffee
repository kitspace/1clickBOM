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

class window.RetailerInterface
    constructor: (name, country_code, data_path, settings, callback) ->
        @country = country_code
        data = get_local(data_path)
        country_code_lookedup = data.lookup[country_code]
        if !country_code_lookedup
            error = new InvalidCountryError()
            error.message += " \"" + country_code + "\" given to " + name
            throw error

        if (settings?)
            if (settings.carts?)
                data.carts = settings.carts
            if (settings.additems?)
                data.additems = settings.additems
            if (settings.additem_params?)
                data.additem_params = settings.additem_params
            if (settings.sites?)
                data.sites = settings.sites
            if (settings.name?)
                data.name = settings.name
            if (settings.interface_name?)
                data.interface_name = settings.interface_name
            if (settings.language?)
                data.language = settings.language

        @settings = settings

        if typeof(data.carts) == "string"
            @cart = data.carts
        else
            @cart = data.carts[country_code_lookedup]

        if typeof(data.additems) == "string"
            @additem = data.additems
        else
            @additem = data.additems[country_code_lookedup]

        if data.language?
            @language = data.language[country_code_lookedup]

        @additem_params = data.additem_params
        @site = data.sites[country_code_lookedup]
        @name = name + " " + country_code_lookedup
        @interface_name = name
        @adding_items = false
        @clearing_cart = false
        @icon_src = "http://g.etfv.co/" + "http" + @site
        #this puts the image in cache but also uses our backup if g.etfv.co fails
        get @icon_src, {notify:false},  (event) =>
            if md5(event.target.response) == "a8aca8c8c4780cbe1acd774799f326e8" #failure response image
                @icon_src = chrome.extension.getURL("/images/" + @interface_name.toLowerCase() + ".ico")
        , () =>
            @icon_src = chrome.extension.getURL("/images/" + @interface_name.toLowerCase() + ".ico")
        if callback?
            callback()

    refreshCartTabs: () ->
        #we reload any tabs with the cart URL but the path is case insensitive
        #so we use a regex. we update the matching tabs to the cart URL instead
        #of using tabs.refresh so we don't re-pass any parameters to the cart
        re = new RegExp(@cart, "i")
        chrome.tabs.query {"url":"*" + @site + "/*"}, (tabs) =>
            for tab in tabs
                if (tab.url.match(re))
                    protocol = tab.url.split("://")[0]
                    chrome.tabs.update tab.id, {"url": protocol + @site + @cart}

    refreshSiteTabs: () ->
        #refresh the tabs that are not the cart url. XXX could some of the
        #passed params cause problems on, say, quick-add urls?
        re = new RegExp(@cart, "i")
        chrome.tabs.query {"url":"*" + @site + "/*"}, (tabs) ->
            for tab in tabs
                if !(tab.url.match(re))
                    chrome.tabs.reload tab.id

    openCartTab: () ->
        chrome.tabs.query {"url":"*" + @site + @cart + "*" , currentWindow:true}
        , (tabs) =>
            if tabs.length >  0
                tab_numbers = []
                for tab in tabs
                    tab_numbers.push(tab.index)
                chrome.tabs.highlight({tabs:tab_numbers}, (window)->)
            else
                chrome.tabs.create({url: "http" + @site + @cart, active:true})


class @InvalidCountryError extends Error
    constructor: ->
        @name = "InvalidCountryError"
        @message = "Invalid country-code"

