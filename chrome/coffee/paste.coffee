@paste = () ->
    textarea = document.getElementById("pastebox")
    textarea.select()
    if document.execCommand("paste")
        result = textarea.value
    return result


@parseTSV = (text) ->
    #TODO safety
    rows = text.split "\n"
    items = []
    invalid = []
    for row, i in rows
        if row != ""
            cells = row.split "\t"
            item = {"comment":cells[0], "quantity":cells[1], "retailer":cells[2],"part":cells[3], "row":i}
            items.push item
    return items



@checkValidItems = (in_items) ->
    @retailer_lookup = {
        "Farnell"   : "Element14",
        "Element14" : "Element14",
        "FEC"       : "Element14",
        "Digikey"   : "Digikey"
    }
    items = []
    invalid = []
    for item in in_items
        reasons = []
        number = parseInt(item.quantity)
        if number == NaN
            invalid.push {"item":item, "reason": "Quantity is not a number."}
        else
            item.quantity = number
            if !item.retailer
                invalid.push {"item":item, "reason": "Retailer is undefined."}
            else
                #a case insensitive match to the aliases defined in the lookup
                for key of @retailer_lookup
                    re = new RegExp key, "i"
                    if item.retailer.match(re)
                        retailer = retailer_lookup[key]
                if !retailer
                    invalid.push {"item":item, "reason": "Retailer \"" + item.retailer + "\" is not known."}
                else
                    item.retailer = retailer
                    items.push(item)
    return {items, invalid}


#isIn = (item, items) ->
#    switch (typeof(items))
#        when "object"


chrome.browserAction.onClicked.addListener (tab)->
    text = @paste()
    items = @parseTSV(text)
    {items, invalid} = @checkValidItems(items)
    bom = {}
    for item in items
        found = false
        for key of bom
            if item.retailer == key
                found = true
                break
        if (!found)
            bom[item.retailer] = {"items":[]}
        bom[item.retailer].items.push(item)

    for key of bom
        switch (key)
            when "Digikey"   then bom[key].interface = new   Digikey("UK")
            when "Element14" then bom[key].interface = new Element14("UK")

    console.log(bom)
