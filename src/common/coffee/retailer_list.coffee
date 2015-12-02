exports.retailer_list = ['Digikey', 'Mouser', 'RS', 'Newark', 'Farnell']
exports.field_list = ['partNumber', 'manufacturer']
exports.isComplete = (items) ->
    complete = true
    for item in items
        for r in exports.retailer_list
            if item.retailers[r] == ''
                complete = false
        for f in exports.field_list
            console.log(item[f])
            if item[f] == ''
                complete = false
    return complete
