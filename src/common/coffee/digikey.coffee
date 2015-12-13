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

{RetailerInterface} = require './retailer_interface'
http      = require './http'
{browser} = require './browser'

post = http.post
get  = http.get

class Digikey extends RetailerInterface
    constructor: (country_code, settings, callback) ->
        super('Digikey', country_code, 'data/digikey.json', settings, callback)

    clearCart: (callback) ->
        @clearing_cart = true
        url = 'http' + @site + @cart + '?webid=-1'
        get url, {}, () =>
            if callback?
                callback({success:true})
            @refreshCartTabs()
            @clearing_cart = false
        , () =>
            if callback?
                callback({success:false})

    addLines: (lines, callback) ->
        if lines.length == 0
            callback({success: true, fails: []})
            return
        @adding_lines = true
        @_add_lines lines, (result) =>
            if callback?
                callback(result, this, lines)
            @refreshCartTabs()
            @adding_lines = false

    _add_lines: (lines, callback) ->
        result = {success:true, fails:[]}
        count = lines.length
        for line in lines
            @_add_line line, (line, line_result) =>
                if not line_result.success
                    @_get_part_id line, (line, id) =>
                        @_get_suggested line, id, 'NextBreakQuanIsLowerExtPrice'
                        , (new_line) =>
                            @_add_line new_line, (_, r) =>
                                if not r.success
                                    @_get_suggested new_line, id, 'TapeReelQuantityTooLow'
                                    , (new_line) =>
                                        @_add_line new_line, (_, r) ->
                                            result.success &&= r.success
                                            result.fails = result.fails.concat(r.fails)
                                            count--
                                            if (count == 0)
                                                callback(result)
                                    , () ->
                                        result.success = false
                                        result.fails.push(line)
                                        count--
                                        if (count == 0)
                                            callback(result)
                                else
                                    count--
                                    if (count == 0)
                                        callback(result)
                        , () ->
                            result.success = false
                            result.fails.push(line)
                            count--
                            if (count == 0)
                                callback(result)
                    , () ->
                        result.success = false
                        result.fails.push(line)
                        count--
                        if (count == 0)
                            callback(result)
                else
                    count--
                    if (count == 0)
                        callback(result)
    _add_line: (line, callback) ->
        url = 'http' + @site + @addline
        params = 'qty=' + line.quantity + '&part=' + line.part + '&cref=' + line.reference
        result = {success:true, fails:[]}
        post url, params, {line:line}, (event)->
            doc = browser.parseDOM(event.target.responseText)
            #if the cart returns with a quick-add quantity filled-in there was an error
            quick_add_quant = doc.querySelector('#ctl00_ctl00_mainContentPlaceHolder_mainContentPlaceHolder_txtQuantity')
            result.success = (quick_add_quant?) && (quick_add_quant.value?) && (quick_add_quant.value == '')
            if not result.success
                result.fails.push(event.target.line)
            callback(event.target.line, result)
        , (event) ->
            result.success = false
            if event.target?
                result.fails.push(event.target.line)
                callback(event.target.line, result)

    _get_part_id: (line, callback, error_callback) ->
        url = 'http' + @site + '/product-detail/en/'
        url += line.part + '/'
        url += line.part + '/'
        get url, {line:line, notify:false}, (event) ->
            doc = browser.parseDOM(event.target.responseText)
            inputs = doc.querySelectorAll('input')
            for input in inputs
                if input.name == 'partid'
                    callback(event.target.line, input.value)
                    return
            #we never found an id
            error_callback()
        , error_callback
    _get_suggested: (line, id, error, callback, error_callback) =>
        url = 'http' + @site + '/classic/Ordering/PackTypeDialog.aspx?'
        url += 'part=' + line.part
        url += '&qty=' + line.quantity
        url += '&partId=' + id
        url += '&error=' + error + '&cref=&esc=-1&returnURL=%2f%2fwww.digikey.co.uk%2fclassic%2fordering%2faddpart.aspx&fastAdd=false&showUpsell=True'
        get url, {line:line, notify:false}, (event) ->
            doc = browser.parseDOM(event.target.responseText)
            switch error
                when 'TapeReelQuantityTooLow'       then choice = doc.getElementById('rb1')
                when 'NextBreakQuanIsLowerExtPrice' then choice = doc.getElementById('rb2')
            if choice?
                label = choice.nextElementSibling
                if label?
                    split  = label.innerHTML.split('&nbsp;')
                    part   = split[2]
                    number = parseInt(split[0].replace(/,/,''))
                    if not isNaN(number)
                        it = event.target.line
                        it.part = part
                        it.quantity = number
                        callback(it)
                    else
                        error_callback()
                else
                    error_callback()
            else
                error_callback()
        , error_callback

exports.Digikey = Digikey
