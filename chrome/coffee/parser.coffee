# This file is part of 1clickBOM.
#
# 1clickBOM is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License version 3
# as published by the Free Software Foundation.
#
# 1clickBOM is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with 1clickBOM.  If not, see <http://www.gnu.org/licenses/>.

checkValidItems =  (items_incoming, invalid) ->
    retailer_aliases = {
        "Farnell"     : "Farnell",
        "FEC"         : "Farnell",
        "Premier"     : "Farnell",
        "Digikey"     : "Digikey",
        "Digi-key"    : "Digikey",
        "Mouser"      : "Mouser",
        "RS"          : "RS",
        "RSOnline"    : "RS",
        "RS-Online"   : "RS",
        "RS-Delivers" : "RS",
        "RSDelivers"  : "RS",
        "Newark"      : "Newark"
    }
    items = []
    for item in items_incoming
        number = parseInt(item.quantity)
        if invalid.length > 10
            items = []
            break
        if isNaN(number)
            invalid.push {item:item, reason: "Quantity is not a number."}
        else if number < 1
            invalid.push {item:item, reason:"Quantity is less than one"}
        else
            item.quantity = number
            r = ""
            #a case insensitive match to the aliases
            for key of retailer_aliases
                re = new RegExp(key, "i")
                if item.retailer.match(re)
                    r = retailer_aliases[key]
                    break
            if  r == ""
                invalid.push({item:item, reason: "Retailer \"" + item.retailer + "\" is not known."})
            else
                item.retailer = r
                if item.retailer == "Mouser"
                    item.part = item.part.replace(/-/g, '')
                items.push(item)
    return {items, invalid}

window.parseTSV =  (text) ->
    rows = text.split "\n"
    items = []
    invalid = []
    for row, i in rows
        if row != ""
            cells = row.split "\t"
            item = {comment:cells[0], quantity:cells[1], retailer:cells[2], part:cells[3], row:i + 1}
            if !item.quantity
                invalid.push {item:item, reason: "Quantity is undefined."}
            else if !item.retailer
                invalid.push {item:item, reason: "Retailer is undefined."}
            else if !item.part
                invalid.push {item:item, reason: "Part number is undefined."}
            else
                items.push item
    {items, invalid} = checkValidItems(items, invalid)
    return {items, invalid}
