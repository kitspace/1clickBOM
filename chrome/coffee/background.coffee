#    This file is part of 1clickBOM.
#
#    1clickBOM is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License version 3
#    as published by the Free Software Foundation.
#
#    1clickBOM is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with 1clickBOM.  If not, see <http://www.gnu.org/licenses/>.

paste = () ->
    textarea = document.getElementById("pastebox")
    textarea.select()
    if document.execCommand("paste")
        result = textarea.value
    return result

parseTSV = (text) ->
    #TODO safety
    rows = text.split "\n"
    items = []
    invalid = []
    for row, i in rows
        if row != ""
            cells = row.split "\t"
            item = {"comment":cells[0], "quantity":cells[1], "retailer":cells[2],"part":cells[3], "row":i}
            if !item.quantity
                invalid.push {"item":item, "reason": "Quantity is undefined."}
            else if !item.retailer
                invalid.push {"item":item, "reason": "Retailer is undefined."}
            else if !item.part
                invalid.push {"item":item, "reason": "Part number is undefined."}
            else
                items.push item
    return {items, invalid}



checkValidItems = (items_incoming, invalid) ->
    @retailer_lookup = {
        "Farnell"   : "Element14",
        "Element14" : "Element14",
        "FEC"       : "Element14",
        "Digikey"   : "Digikey"
    }
    items = []
    for item in items_incoming
        reasons = []
        number = parseInt(item.quantity)
        if number == NaN
            invalid.push {"item":item, "reason": "Quantity is not a number."}
        else
            item.quantity = number
            r = ""
            #a case insensitive match to the aliases defined in the lookup
            for key of @retailer_lookup
                re = new RegExp key, "i"
                if item.retailer.match(re)
                    r = retailer_lookup[key]
                    break

            if  r == ""
                invalid.push {"item":item, "reason": "Retailer \"" + item.retailer + "\" is not known."}
            else
                item.retailer = r
                items.push(item)
    return {items, invalid}

@paste_action = ()->
    console.log("paste action")
    text = paste()
    console.log(text)
    {items, invalid} = parseTSV(text)
    {items, invalid} = checkValidItems(items, invalid)

    if invalid.length > 0
        console.error (invalid)

    @bom = {}
    for item in items
        found = false
        for key of @bom
            if item.retailer == key
                found = true
                break
        if (!found)
            @bom[item.retailer] = {"items":[]}
        @bom[item.retailer].items.push(item)

    country = localStorage["country"]

    for key of @bom
        switch (key)
            when "Digikey"   then @bom[key].interface = new   Digikey(country)
            when "Element14" then @bom[key].interface = new Element14(country)

    console.log(@bom)
