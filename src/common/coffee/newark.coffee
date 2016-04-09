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

{RetailerInterface}   = require './retailer_interface'
{browser} = require './browser'
http = require './http'
post = http.post
get  = http.get

class Newark extends RetailerInterface
    constructor: (country_code, settings,callback) ->
        super('Newark', country_code, 'data/newark.json', settings)
        @_set_store_id () =>
            callback(this)

    clearCart: (callback) ->
        @_get_item_ids (ids) =>
            @_clear_cart ids, (obj) =>
                @refreshCartTabs()
                @refreshSiteTabs()
                if callback?
                    callback(obj)

    _set_store_id: (callback) ->
        url = 'https' + @site + @cart
        get url, {}, (event) =>
            doc = browser.parseDOM(event.target.responseText)
            id_elem = doc.getElementById('storeId')
            if id_elem?
                @store_id = id_elem.value
                callback()
        , () ->
            callback()


    _clear_cart: (ids, callback) ->
        url = "https#{@site}/webapp/wcs/stores/servlet/ProcessBasket"
        params = "langId=-1&orderId=&catalogId=15003&BASE_URL=BasketPage\
        &errorViewName=AjaxOrderItemDisplayView&storeId=#{@store_id}\
        &URL=BasketDataAjaxResponse&isEmpty=false&LoginTimeout=&LoginTimeoutURL=\
        &blankLinesResponse=10&orderItemDeleteAll="
        for id in ids
            params += '&orderItemDelete=' + id
        post url, params, {}, (event) =>
            callback({success:true}, this)
        , () =>
            #we actually successfully clear the cart on 404s
            callback({success:true}, this)

    _get_item_ids: (callback) ->
        url = 'https' + @site + @cart
        get url, {}, (event) =>
            doc = browser.parseDOM(event.target.responseText)
            order_details = doc.querySelector('#order_details')
            if order_details?
                tbody = order_details.querySelector('tbody')
                inputs = tbody.querySelectorAll('input')
            else
                inputs = []
            ids = []
            for input in inputs
                if input.type == 'hidden' && /orderItem_/.test(input.id)
                    ids.push(input.value)
            callback(ids)

    addLines: (lines, callback) ->
        if lines.length == 0
            callback({success: true, fails: []})
            return
        @_add_lines  lines, (result) =>
            @refreshCartTabs()
            @refreshSiteTabs()
            callback(result, this, lines)

    _add_lines: (lines, callback) ->
        url = 'https' + @site + '/AjaxPasteOrderChangeServiceItemAdd'
        get url, {notify:false}, () =>
            @_add_lines_ajax(lines, callback)
        , () =>
            @_add_lines_non_ajax(lines, callback)

    _add_lines_non_ajax: (lines, callback) ->
        if lines.length == 0
            if callback?
                callback({success:true, fails:[]})
            return
        url = 'https' + @site + '/webapp/wcs/stores/servlet/PasteOrderChangeServiceItemAdd'
        params = 'storeId=' + @store_id + '&catalogId=&langId=-1&omItemAdd=quickPaste&URL=AjaxOrderItemDisplayView%3FstoreId%3D10194%26catalogId%3D15003%26langId%3D-1%26quickPaste%3D*&errorViewName=QuickOrderView&calculationUsage=-1%2C-2%2C-3%2C-4%2C-5%2C-6%2C-7&isQuickPaste=true&quickPaste='
        #&addToBasket=Add+to+Cart'
        for line in lines
            params += encodeURIComponent(line.part) + ','
            params += encodeURIComponent(line.quantity) + ','
            params += encodeURIComponent(line.reference) + '\n'
        post url, params, {}, (event) =>
            doc = browser.parseDOM(event.target.responseText)
            form_errors = doc.querySelector('#formErrors')
            success = true
            if form_errors?
                success = form_errors.className != ''
            if not success
                #we find out which parts are the problem, call addLines again
                #on the rest and concatenate the fails to the new result
                #returning everything together to our callback
                fail_names  = []
                fails       = []
                retry_lines = []
                for line in lines
                        regex = new RegExp line.part, 'g'
                        result = regex.exec(form_errors.innerHTML)
                        if result != null
                            fail_names.push(result[0])
                for line in lines
                    if line.part in fail_names
                        fails.push(line)
                    else
                        retry_lines.push(line)
                @_add_lines_non_ajax retry_lines, (result) ->
                    if callback?
                        result.fails = result.fails.concat(fails)
                        result.success = false
                        callback(result)
            else #success
                if callback?
                    callback({success: true, fails:[]})
        , () =>
            if callback?
                callback({success:false,fails:lines})


    _add_lines_ajax: (lines, callback) ->
        result = {success: true, fails:[], warnings:[]}
        if lines.length == 0
            if callback?
                callback({success:true, fails:[]})
            return
        url = 'https' + @site + '/AjaxPasteOrderChangeServiceItemAdd'

        params = 'storeId=' + @store_id + '&catalogId=&langId=-1&omItemAdd=quickPaste&URL=AjaxOrderItemDisplayView%3FstoreId%3D10194%26catalogId%3D15003%26langId%3D-1%26quickPaste%3D*&errorViewName=QuickOrderView&calculationUsage=-1%2C-2%2C-3%2C-4%2C-5%2C-6%2C-7&isQuickPaste=true&quickPaste='
        for line in lines
            params += encodeURIComponent(line.part) + ','
            params += encodeURIComponent(line.quantity) + ','
            if line.reference.length > 30
                result.warnings.push("Truncated line-note when adding
                    #{@name} line to cart: #{line.reference}")
            params += encodeURIComponent(line.reference.substr(0,30)) + '\n'
        post url, params, {}, (event) =>
            stxt = event.target.responseText.split('\n')
            stxt2 = stxt[3 .. (stxt.length - 4)]
            stxt3 = ''
            for s in stxt2
                stxt3 += s
            json = JSON.parse(stxt3)
            if json.hasPartNumberErrors? or json.hasCommentErrors?
                #we find out which parts are the problem, call addLines again
                #on the rest and concatenate the fails to the new result
                #returning everything together to our callback
                fail_names  = []
                fails       = []
                retry_lines = []
                for k,v of json
                    #the rest of the json lines are the part numbers
                    if k != 'hasPartNumberErrors' and k != 'hasCommentErrors'
                        fail_names.push(v[0])
                for line in lines
                    if line.part in fail_names
                        fails.push(line)
                    else
                        retry_lines.push(line)
                @_add_lines_ajax retry_lines, (result) ->
                    if callback?
                        result.fails = result.fails.concat(fails)
                        result.success = false
                        callback(result)
            else #success
                if callback?
                    callback(result)
        , () =>
            if callback?
                callback({success:false,fails:lines,warnings:result.warnings})

exports.Newark = Newark
