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

rateLimit = require './promise-rate-limit'

http = require './http'

aliases =
    'Digi-Key'           : 'Digikey'
    'RS Components'      : 'RS'
    'Mouser Electronics' : 'Mouser'
    'Farnell element14'  : 'Farnell'
    'Newark element14'   : 'Newark'

_search = (query, retailers_to_search = [], other_fields = []) ->
    if query == ''
        return Promise.resolve({retailers:{}})
    url = "http://www.findchips.com/lite/#{encodeURIComponent(query)}"
    p = http.promiseGet(url)
        .catch ((url, event) ->
            status = event.currentTarget.status
            if status == 502
                return http.promiseGet(url)
        ).bind(null, url)
    p.then (doc)->
        result = {retailers:{}, partNumbers:[]}
        elements = doc.getElementsByClassName('distributor-title')
        for h in elements
            title = h.firstElementChild.innerHTML.trim()
            retailer = ''
            for k,v of aliases
                regex = RegExp("^#{k}")
                if regex.test(title)
                    retailer = v
                    break
            if retailer not in retailers_to_search
                continue
            min_quantities = []
            additional_elements =
                h.parentElement.getElementsByClassName('additional-title')
            for span in additional_elements
                if span.innerHTML == 'Min Qty'
                    min_quantities.push(span.nextElementSibling)
            {span, n} = min_quantities.reduce (prev, span) ->
                n = parseInt(span.innerHTML.trim())
                if prev?.n < n or isNaN(n)
                    return prev
                else
                    return {span, n}
            , {}
            if not span?
                for span in additional_elements
                    if span.innerHTML == 'Distri #:'
                        part = span.nextElementSibling.innerHTML.trim()
                        break
            else
                tr = span.parentElement?.parentElement?.parentElement
                if tr?
                    for span in tr?.getElementsByClassName('additional-title')
                        if span.innerHTML == 'Distri #:' and span.nextElementSibling?
                            part = span.nextElementSibling.innerHTML.trim()

                            #sometimes there are some erroneous 'Distri #'
                            #in the results like '77M8756 CE TMK107 B7224KA-T'
                            if (part.split(' ').length > 1)
                                part = part.split(' ')[0]

                            break
            if part?
                result.retailers[retailer] = part
        return result
    .catch (reason) ->
        return {retailers:{}, partNumbers:[]}

exports.search = rateLimit(n=60, time_period_ms=20000, _search)
