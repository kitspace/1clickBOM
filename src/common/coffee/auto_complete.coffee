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

{retailer_list, field_list, isComplete} = require './retailer_list'
octopart  = require './octopart'
findchips = require './findchips'

_auto_complete = (search_engine, items) ->
    promise_array = for item in items
        retailers = []
        other_fields = []
        for retailer in retailer_list
            if (item.retailers[retailer] == '')
                retailers.push(retailer)
        for field in field_list
            if item[field] == ''
                other_fields.push(field)
        query = item.partNumber
        if query == ''
            for retailer in retailer_list
                if item.retailers[retailer] != ''
                    query = item.retailers[retailer]
                    break
        if retailers.length == 0 and other_fields.length == 0
            Promise.resolve(item)
        else
            p = search_engine.search(query, retailers, other_fields)
            p.then ((item, result) ->
                for field,v of result
                    if field != 'retailers' and v?
                        item[field] = v
                for retailer in retailer_list
                    if result.retailers[retailer]?
                        item.retailers[retailer] = result.retailers[retailer]
                return item
            ).bind(undefined, item)


    final = promise_array.reduce (prev, promise) ->
        prev.then (newItems) ->
            promise.then (item) ->
                newItems.push(item)
                return newItems
    , Promise.resolve([])

    return final


autoComplete = (items, callback) ->
    p = _auto_complete(octopart, items)
    p.then (newItems) ->
        for item in newItems
            for r of item.retailers
                if r not in retailer_list
                    console.log("octopart")
        if not isComplete(newItems)
            p = _auto_complete(findchips, newItems)
            p.then (newItems_) ->
                for item in newItems_
                    for r of item.retailers
                        if r not in retailer_list
                            console.log("findchips")
                callback(newItems_)
        else
            callback(newItems)


exports.autoComplete = autoComplete

