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
Promise = require('./bluebird')
Promise.config({cancellation:true})

{retailer_list, isComplete, field_list} = require('1-click-bom').lineData

octopart  = require './octopart'
findchips = require './findchips'

_next_query = (line, queries) ->
    query = ''
    other_fields = []
    retailers = []
    for n in line.partNumbers
        q = "#{n.manufacturer} #{n.part}"
        if q not in queries
            query = q
            break
    for key in retailer_list
        sku = line.retailers[key]
        if sku != '' && (sku not in queries)
            query = sku
            break
    for key in retailer_list
        sku = line.retailers[key]
        if sku == ''
            retailers.push(key)
    if query == ''
        query = line.description
    if line.partNumbers.length < 1
        other_fields.push('partNumbers')
    return {query, other_fields, retailers}

_auto_complete = (search_engine, lines, depth) ->
    promise_array = for line in lines
        queries = []
        searchPromises = []
        search = ({line, queries}) ->
            {query, other_fields, retailers} = _next_query(line, queries)
            if (retailers.length == 0 and other_fields.length == 0) or query == ''
                return Promise.resolve({line, queries})
            queries.push(query)
            p = search_engine.search(query, retailers, other_fields)
            return p.then ((line, queries, result) ->
                line.partNumbers = line.partNumbers.concat(result.partNumbers)
                for retailer in retailer_list
                    if result.retailers[retailer]?
                        #replace reeled components with non-reeled for Farnell
                        if retailer == 'Farnell' &&
                        /RL$/.test(result.retailers[retailer])
                            result.retailers[retailer] =
                                result.retailers[retailer].replace('RL','')
                        if retailer != 'Digikey'
                            result.retailers[retailer] =
                                result.retailers[retailer].replace(/-/g,'')
                        line.retailers[retailer] = result.retailers[retailer]
                return {line, queries}
            ).bind(undefined, line, queries)
        p = search({line:line, queries:[]})
        if (depth - 1) > 0
            for _ in [1..(depth-1)]
                p.then search
        p.then ({line, queries}) ->
            Promise.resolve(line)

    final = promise_array.reduce (prev, promise) ->
        prev.then (newLines) ->
            promise.then (line) ->
                newLines.push(line)
                return newLines
    , Promise.resolve([])

    return final


autoComplete = (lines, deep=false) ->
    lines = JSON.parse(JSON.stringify(lines))
    if deep
        depth = 3
    else
        depth = 1
    p = _auto_complete(octopart, lines, depth)
    p.then (newLines) ->
        if not isComplete(newLines)
            p = _auto_complete(findchips, newLines, depth)
            p.then (newLines_) ->
                return newLines_
        else
            return newLines


exports.autoComplete = autoComplete

