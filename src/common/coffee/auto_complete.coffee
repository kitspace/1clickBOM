
{retailer_list, field_list, isComplete} = require './retailer_list'
octopart = require './octopart'

autoComplete = (items, callback) ->
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
        p = octopart.search(query, retailers, other_fields)
        p.then ((item, result) ->
            for field,v of result
                if field != 'retailers' and v?
                    item[field] = v
            for retailer,v of result.retailers
                if v?
                    item.retailers[retailer] = v
            return item
        ).bind(undefined, item)

    final = promise_array.reduce (prev, promise) ->
        prev.then (newItems) ->
            promise.then (item) ->
                newItems.push(item)
                return newItems
    , Promise.resolve([])

    final.then (newItems) ->
        callback(newItems)

exports.autoComplete = autoComplete

