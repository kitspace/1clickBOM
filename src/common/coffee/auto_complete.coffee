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

{retailer_list, isComplete, field_list} = require('1-click-bom').lineData

octopart  = require './octopart'
findchips = require './findchips'

_auto_complete = (search_engine, lines, preferDescription=false) ->
    promise_array = for line in lines
        retailers = []
        other_fields = []
        for retailer in retailer_list
            if (line.retailers[retailer] == '')
                retailers.push(retailer)
        for field in field_list
            if line[field] == ''
                other_fields.push(field)
        if preferDescription
            query = line.description
            if query == ''
                query = line.partNumber
        else
            query = line.partNumber
            if query == ''
                query = line.description
        if query == ''
            for retailer in retailer_list
                if line.retailers[retailer] != ''
                    query = line.retailers[retailer]
                    break
        if retailers.length == 0 and other_fields.length == 0
            Promise.resolve(line)
        else
            p = search_engine.search(query, retailers, other_fields)
            p.then ((line, result) ->
                for field,v of result
                    if field != 'retailers' and v?
                        line[field] = v
                for retailer in retailer_list
                    if result.retailers[retailer]?
                        if retailer == 'Farnell' &&
                        /RL$/.test(result.retailers[retailer])
                            result.retailers[retailer] =
                                result.retailers[retailer].replace('RL','')
                        if retailer != 'Digikey'
                            result.retailers[retailer] = result.retailers[retailer]
                                .replace(/-/g,'')
                        line.retailers[retailer] = result.retailers[retailer]
                return line
            ).bind(undefined, line)


    final = promise_array.reduce (prev, promise) ->
        prev.then (newLines) ->
            promise.then (line) ->
                newLines.push(line)
                return newLines
    , Promise.resolve([])

    return final


autoComplete = (lines, callback) ->
    _auto_complete(octopart, lines)
        .then (newLines) ->
            if not isComplete(newLines)
                return _auto_complete(findchips, newLines)
            else
                return newLines
        .then (newLines) ->
            if not isComplete(newLines)
                return _auto_complete(octopart, newLines, preferDescription=true)
            else
                return newLines
        .then (newLines) ->
            if not isComplete(newLines)
                return _auto_complete(findchips, newLines, preferDescription=true)
            else
                return newLines
        .then (newLines) ->
            callback(newLines)


exports.autoComplete = autoComplete

