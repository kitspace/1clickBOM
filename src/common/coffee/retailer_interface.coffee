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

http = require './http'
{md5    } = require './md5'
{browser} = require './browser'

class RetailerInterface
    constructor: (name, country_code, data_path, settings, callback) ->
        @country = country_code
        data = browser.getLocal(data_path)
        country_code_lookedup = data.lookup[country_code]
        if !country_code_lookedup
            error = new InvalidCountryError()
            error.message += ' \'' + country_code + '\' given to ' + name
            throw error

        if (settings?)
            if (settings.carts?)
                data.carts = settings.carts
            if (settings.additems?)
                data.additems = settings.additems
            if (settings.additem_params?)
                data.additem_params = settings.additem_params
            if (settings.name?)
                data.name = settings.name
            if (settings.interface_name?)
                data.interface_name = settings.interface_name
            if (settings.language?)
                data.language = settings.language

        @settings = settings

        if typeof(data.carts) == 'string'
            @cart = data.carts
        else
            @cart = data.carts[country_code_lookedup]

        if typeof(data.additems) == 'string'
            @additem = data.additems
        else
            @additem = data.additems[country_code_lookedup]

        if data.language?
            @language = data.language[country_code_lookedup]

        if (settings? && settings.site?)
            @site = settings.site
        else
            @site = data.sites[country_code_lookedup]

        @additem_params = data.additem_params
        @name           = name + ' ' + country_code_lookedup
        @interface_name = name
        @adding_items   = false
        @clearing_cart  = false
        @icon_src       = 'https://www.google.com/s2/favicons?domain=http' + @site
        #this puts the image in cache but also uses our backup if
        #google.com/s2/favicons fails
        http.get @icon_src, {notify:false},  (event) =>
            md = md5(event.target.response)
            #failure response image, different on ff vs chrome for some reason
            failure_md5_ff     = 'faaec2b6826ef502e0e3e38f652ff0b8'
            failure_md5_chrome = '6e2001c87afacf376c7df4a011376511'
            if md == failure_md5_chrome || md == failure_md5_ff
                @icon_src = browser.getURL("images/#{@interface_name.toLowerCase()}.ico")
        , () =>
            @icon_src = browser.getURL("images/#{@interface_name.toLowerCase()}.ico")
        if callback?
            callback()

    refreshCartTabs: () ->
        #we reload any tabs with the cart URL but the path is case insensitive
        #so we use a regex. we update the matching tabs to the cart URL instead
        #of using tabs.refresh so we don't re-pass any parameters to the cart
        re = new RegExp(@cart, 'i')
        browser.tabsQuery {url:"*#{@site}/*"}, (tabs) =>
            for tab in tabs
                if (tab.url.match(re))
                    protocol = tab.url.split('://')[0]
                    browser.tabsUpdate(tab, protocol + @site + @cart)
    refreshSiteTabs: () ->
        #refresh the tabs that are not the cart url. XXX could some of the
        #passed params cause problems on, say, quick-add urls?
        re = new RegExp(@cart, "i")
        browser.tabsQuery {url:"*#{@site}/*"}, (tabs) ->
            for tab in tabs
                if !(tab.url.match(re))
                    browser.tabsReload(tab)

    openCartTab: () ->
        browser.tabsQuery {url:"*#{@site}#{@cart}*" , currentWindow:true}
        , (tabs) =>
            if tabs.length > 0
                browser.tabsActivate(tabs[tabs.length - 1])
            else
                browser.tabsCreate('http' + @site + @cart)

class InvalidCountryError extends Error
    constructor: ->
        @name = 'InvalidCountryError'
        @message = 'Invalid country-code'

exports.RetailerInterface   = RetailerInterface
exports.InvalidCountryError = InvalidCountryError
