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

{retailer_list} = require('./retailer_list')

retailer_aliases =
    'Farnell'     : 'Farnell'
    'FEC'         : 'Farnell'
    'Premier'     : 'Farnell'
    'Digikey'     : 'Digikey'
    'Digi-key'    : 'Digikey'
    'Mouser'      : 'Mouser'
    'RS'          : 'RS'
    'RSOnline'    : 'RS'
    'RS-Online'   : 'RS'
    'RS-Delivers' : 'RS'
    'RSDelivers'  : 'RS'
    'Radio Spares': 'RS'
    'RadioSpares' : 'RS'
    'Newark'      : 'Newark'

headings =
    'reference'  : 'reference'
    'references' : 'reference'
    'line-note'  : 'reference'
    'line note'  : 'reference'
    'comment'    : 'comment'
    'comments'   : 'comment'
    'qty'        : 'quantity'
    'quantity'   : 'quantity'

#a case insensitive match
lookup = (name, obj) ->
    for key of obj
        re = new RegExp(key, 'i')
        if name.match(re)
            return obj[key]
    #else
    return null

checkValidItems =  (items_incoming, invalid, warnings) ->
    items = []
    for item in items_incoming
        if invalid.length > 10
            items = []
            break
        number = parseInt(item.quantity)
        if isNaN(number)
            invalid.push {row:item.row, reason:'Quantity is not a number.'}
        else if number < 1
            invalid.push {row:item.row, reason:'Quantity is less than one.'}
        else
            item.quantity = number
            for key,v of item.retailers
                if not v?
                    v = ''
                else if key != 'Digikey'
                    v = v.replace(/-/g,'')
            items.push(item)
    return {items, invalid, warnings}

parseSimple = (rows) ->
    items = []
    invalid = []
    for row, i in rows
        if row != ''
            cells = row.split('\t')
            retailer = lookup(cells[2], retailer_aliases)
            if not retailer
                if cells[2] == ''
                    invalid.push
                        row:i + 1
                        reason: "Retailer is not defined."
                else
                    invalid.push
                        row:i + 1
                        reason: "Retailer '#{cells[2]}' is not known."
            else
                retailersObj = {}
                for r in retailer_list
                    retailersObj[r] = ''
                retailersObj["#{retailer}"] = cells[3]
                item =
                    reference : cells[0]
                    quantity  : cells[1]
                    retailers : retailersObj
                    row       : i + 1
                if !item.quantity
                    invalid.push
                        row:item.row
                        reason: 'Quantity is undefined.'
                else if !item.retailers["#{retailer}"]
                    invalid.push
                        row:item.row
                        reason: 'Part number is undefined.'
                else
                    items.push(item)
    return {items, invalid}


parseNamed = (rows, order, retailers) ->
    items = []
    invalid = []
    for row, i in rows
        if row != ''
            cells = row.split('\t')
            rs = () ->
                retailersObj = {}
                for r in retailer_list
                    retailersObj[r] = ''
                for r in retailers
                    retailersObj["#{r}"] = cells[order.indexOf(r)]
                return retailersObj
            item =
                reference : cells[order.indexOf('reference')]
                quantity  : cells[order.indexOf('quantity')]
                retailers : rs()
                row       : i + 1
            if not item.quantity?
                invalid.push
                    row:item.row
                    reason: 'Quantity is undefined.'
            else
                items.push(item)
    return {items, invalid}


hasNamedColumns = (cells) ->
    for cell in cells
        if lookup(cell, headings)?
            return true
    #else
    return false


getOrder = (cells) ->
    order = []
    retailers = []
    warnings = []

    possible_names = {}
    for k,v of headings
        possible_names[k] = v
    for k,v of retailer_aliases
        possible_names[k] = v

    for cell in cells
        if cell == ''
            #this is an empty column, it happen if you ctrl select several
            #columns in a spreadsheet for example
            order.push('')
        else
            heading = lookup(cell, possible_names)
            retailer = lookup(cell, retailer_aliases)
            if retailer?
                retailers.push(retailer)
            if heading?
                order.push(heading)
            else
                warnings.push
                    title:"Unknown column-heading '#{cell}'"
                    message:"Column #{order.length + 1} was ignored."
                order.push('')

    if retailers.length <= 0
        return {reason: 'You need at least one retailer'}
    else
        return {order, retailers, warnings}


parseTSV = (text) ->
    rows = text.split('\n')
    firstCells = rows[0].split('\t')
    warnings = []
    l = firstCells.length
    if l < 2
        return {
            items:[]
            invalid:[
                row:1
                reason:"The pasted data doesn't look like tab seperated values."
            ]
        }
    else if l < 3
        return {
            items:[]
            invalid:[
                row:1
                reason:"Only #{l} column#{if l > 1 then 's' else ''}.
                    At least 3 are required."
            ]
        }
    if hasNamedColumns(firstCells)
        {order, retailers, reason, warnings} = getOrder(firstCells)
        if not (order? && retailers?)
            return {
                items:[]
                invalid:[{row:1, reason:reason}]
            }
        {items, invalid} = parseNamed(rows[1..], order, retailers)
    else
        {items, invalid} = parseSimple(rows)
    {items, invalid, warnings} = checkValidItems(items, invalid, warnings)
    return {items, invalid, warnings}


exports.parseTSV = parseTSV
