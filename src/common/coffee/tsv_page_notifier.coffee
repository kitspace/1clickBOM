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

{parseTSV, writeTSV} = require '1-click-bom'

http          = require './http'
{browser}     = require './browser'
{bom_manager} = require './bom_manager'
{badge}       = require './badge'

exports.tsvPageNotifier = (sendState) ->
    return {
        onDotTSV : false
        re       : new RegExp('((\.tsv$)|(^https?://.*?\.?kitnic.it/boards/)|(https?://127.0.0.1:8080/boards/))','i')
        lines    : []
        invalid  : []
        _set_not_dotTSV: () ->
            badge.setDefault('')
            @onDotTSV = false
            @lines    = []
            @invalid  = []
            sendState()
        checkPage: (callback) ->
            browser.tabsGetActive (tab) =>
                if tab?
                    tab_url = tab.url.split('?')[0]
                    if tab_url.match(@re)
                        if /^https?:\/\/.*?\.?kitnic.it\/boards\//.test(tab.url)
                            url = tab_url + '/1-click-BOM.tsv'
                        else if /^https?:\/\/127.0.0.1:8080\/boards\//.test(tab.url)
                            url = tab_url + '/1-click-BOM.tsv'
                        else if /^https?:\/\/github.com\//.test(tab.url)
                            url = tab_url.replace(/blob/,'raw')
                        else if /^https?:\/\/bitbucket.org\//.test(tab.url)
                            url = tab_url.split('?')[0].replace(/src/,'raw')
                        else
                            url = tab_url
                        http.get url, {notify:false}, (event) =>
                            {lines, invalid} = parseTSV(event.target.responseText)
                            if lines.length > 0
                                badge.setDefault('\u2191', '#0000FF')
                                @onDotTSV = true
                                @lines    = lines
                                @invalid  = invalid
                                sendState()
                            else
                                @_set_not_dotTSV()
                        , () =>
                            @_set_not_dotTSV()
                    else
                        @_set_not_dotTSV()
                    if callback?
                        callback()
                else if callback?
                    callback()
        addToBOM: (callback) ->
            @checkPage () =>
                if @onDotTSV
                    bom_manager._add_to_bom(@lines, @invalid, callback)
        quickAddToCart: (retailer) ->
            @checkPage () =>
                if @onDotTSV
                    parts = bom_manager._to_retailers(@lines)
                    bom_manager.interfaces[retailer].addLines parts[retailer], (result) ->
                        bom_manager.interfaces[retailer].openCartTab()
                        bom_manager.notifyFillCart(parts[retailer], retailer, result)
    }
