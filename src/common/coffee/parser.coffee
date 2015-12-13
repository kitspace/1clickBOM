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

{retailer_list, field_list} = require('./line_data')

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
    'reference'                : 'reference'
    'references'               : 'reference'
    'line-note'                : 'reference'
    'line note'                : 'reference'
    'comment'                  : 'description'
    'comments'                 : 'description'
    'description'              : 'description'
    'qty'                      : 'quantity'
    'quantity'                 : 'quantity'
    'part-number'              : 'partNumber'
    'partnumber'               : 'partNumber'
    'part number'              : 'partNumber'
    'm/f part'                 : 'partNumber'
    'manuf. part'              : 'partNumber'
    'mpn'                      : 'partNumber'
    'm/f part number'          : 'partNumber'
    'manuf. part number'       : 'partNumber'
    'manufacturer part'        : 'partNumber'
    'manufacturer part number' : 'partNumber'
    'manufacturer'             : 'manufacturer'
    'm/f'                      : 'manufacturer'

#a case insensitive match
lookup = (name, obj) ->
    for key of obj
        re = new RegExp(key, 'i')
        if name.match(re)
            return obj[key]
    #else
    return null

checkValidLines =  (lines_incoming, invalid, warnings) ->
    lines = []
    for line in lines_incoming
        if invalid.length > 10
            lines = []
            break
        number = parseInt(line.quantity)
        if isNaN(number)
            invalid.push {row:line.row, reason:'Quantity is not a number.'}
        else if number < 1
            invalid.push {row:line.row, reason:'Quantity is less than one.'}
        else
            line.quantity = number
            for key,v of line.retailers
                if not v?
                    v = ''
                else if key != 'Digikey'
                    v = v.replace(/-/g,'')
            for field in field_list
                if not line[field]?
                    line[field] = ''
            lines.push(line)
    return {lines, invalid, warnings}

parseSimple = (rows) ->
    lines = []
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
                line =
                    reference : cells[0]
                    quantity  : cells[1]
                    retailers : retailersObj
                    row       : i + 1
                if !line.quantity
                    invalid.push
                        row:line.row
                        reason: 'Quantity is undefined.'
                else if !line.retailers["#{retailer}"]
                    invalid.push
                        row:line.row
                        reason: 'Part number is undefined.'
                else
                    lines.push(line)
    return {lines, invalid}


parseNamed = (rows, order, retailers) ->
    lines = []
    invalid = []
    for row, i in rows
        if row != ''
            cells = row.split('\t')
            rs = () ->
                retailersObj = {}
                for r in retailer_list
                    retailersObj[r] = ''
                for r in retailers
                    if cells[order.indexOf(r)]?
                        retailersObj["#{r}"] = cells[order.indexOf(r)]
                return retailersObj
            line =
                reference    : cells[order.indexOf('reference')]
                quantity     : cells[order.indexOf('quantity')]
                partNumber   : cells[order.indexOf('partNumber')]
                manufacturer : cells[order.indexOf('manufacturer')]
                description  : cells[order.indexOf('description')]
                retailers    : rs()
                row          : i + 1
            if not line.quantity?
                invalid.push
                    row:line.row
                    reason: 'Quantity is undefined.'
            else
                lines.push(line)
    return {lines, invalid}


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

    return {order, retailers, warnings}


parseTSV = (text) ->
    rows = text.split('\n')
    firstCells = rows[0].split('\t')
    warnings = []
    l = firstCells.length
    if l < 2
        return {
            lines:[]
            invalid:[
                row:1
                reason:"The pasted data doesn't look like tab seperated values."
            ]
        }
    else if l < 3
        return {
            lines:[]
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
                lines:[]
                invalid:[{row:1, reason:reason}]
            }
        {lines, invalid} = parseNamed(rows[1..], order, retailers)
    else
        {lines, invalid} = parseSimple(rows)
    {lines, invalid, warnings} = checkValidLines(lines, invalid, warnings)
    return {lines, invalid, warnings}


exports.parseTSV = parseTSV
