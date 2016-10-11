// The contents of this file are subject to the Common Public Attribution
// License Version 1.0 (the “License”); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
// License Version 1.1 but Sections 14 and 15 have been added to cover use of
// software over a computer network and provide for limited attribution for the
// Original Developer. In addition, Exhibit A has been modified to be consistent
// with Exhibit B.
//
// Software distributed under the License is distributed on an
// "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
// the License for the specific language governing rights and limitations under
// the License.
//
// The Original Code is 1clickBOM.
//
// The Original Developer is the Initial Developer. The Original Developer of
// the Original Code is Kaspar Emanuel.
const Promise = require('./bluebird')
Promise.config({cancellation:true})

const oneClickBOM = require('1-click-bom')
const {retailer_list, isComplete, field_list} = oneClickBOM.lineData

const octopart    = require('./octopart')
const findchips   = require('./findchips')
const commonParts = require('./common_parts')

function _next_query(line, queries) {
    let query = ''
    let other_fields = []
    let retailers = []
    for (let i = 0; i < line.partNumbers.length; i++) {
        let n = line.partNumbers[i]
        let q = `${n.manufacturer} ${n.part}`
        if (!__in__(q, queries)) {
            query = q
            break
        }
    }
    for (let j = 0; j < retailer_list.length; j++) {
        let key = retailer_list[j]
        let sku = line.retailers[key]
        if (sku !== '' && (!__in__(sku, queries))) {
            query = sku
            break
        }
    }
    for (let k = 0; k < retailer_list.length; k++) {
        let key = retailer_list[k]
        let sku = line.retailers[key]
        if (sku === '') {
            retailers.push(key)
        }
    }
    if (query === '' && line.description !== '') {
        query = line.description
        if (/R\d+/i.test(line.reference)) {
            if (!/^resistor/i.test(query)) {
                query = 'Resistor ' + query
            }
        } else if (/(^| |,)C\d+/i.test(line.reference)) {
            if (!/^capacitor/i.test(query)) {
                query = 'Capacitor ' + query
            }
        }
    }
    if (line.partNumbers.length < 1) {
        other_fields.push('partNumbers')
    }
    return {query, other_fields, retailers}
}

function _auto_complete(search_engine, lines, depth) {
    let promise_array = (() => {
        let result = []
        for (let i = 0; i < lines.length; i++) {
            let line = lines[i]
            let queries = []
            let searchPromises = []
            function search({line, queries}) {
                let {query, other_fields, retailers} = _next_query(line, queries)
                if ((retailers.length === 0 && other_fields.length === 0) || query === '') {
                    return Promise.resolve({line, queries})
                }
                queries.push(query)
                let p = search_engine.search(query, retailers, other_fields)
                return p.then((function(line, queries, result) {
                    line.partNumbers = line.partNumbers.concat(result.partNumbers)
                    for (let j = 0; j < retailer_list.length; j++) {
                        let retailer = retailer_list[j]
                        if (result.retailers[retailer] != null) {
                            //replace reeled components with non-reeled for Farnell
                            if (retailer === 'Farnell' &&
                            /RL$/.test(result.retailers[retailer])) {
                                result.retailers[retailer] =
                                    result.retailers[retailer].replace('RL','')
                            }
                            if (retailer !== 'Digikey') {
                                result.retailers[retailer] =
                                    result.retailers[retailer].replace(/-/g,'')
                            }
                            line.retailers[retailer] = result.retailers[retailer]
                        }
                    }
                    return {line, queries}
                }).bind(undefined, line, queries)
                )
            }
            let p = search({line, queries:[]})
            if ((depth - 1) > 0) {
                let iterable = __range__(1, (depth-1), true)
                for (let j = 0; j < iterable.length; j++) {
                    let _ = iterable[j]
                    p.then(search)
                }
            }
            result.push(p.then(({line, queries}) => Promise.resolve(line)))
        }
        return result
    })()

    let final = promise_array.reduce((prev, promise) =>
        prev.then(newLines =>
            promise.then(function(line) {
                newLines.push(line)
                return newLines
            })
        )

    , Promise.resolve([]))

    return final
}


function autoComplete(lines, deep=false) {
    lines = JSON.parse(JSON.stringify(lines))
    if (deep) {
        var depth = 3
    } else {
        var depth = 1
    }
    return _auto_complete(commonParts, lines, depth).then(newLines => {
        if (!isComplete(newLines)) {
            return _auto_complete(octopart, newLines, depth)
        } else {
            return newLines
        }
    }).then(newLines => {
        if (!isComplete(newLines)) {
            return _auto_complete(findchips, newLines, depth)
        } else {
            return newLines
        }
    })
}


exports.autoComplete = autoComplete


function __in__(needle, haystack) {
    return haystack.indexOf(needle) >= 0
}
function __range__(left, right, inclusive) {
    let range = []
    let ascending = left < right
    let end = !inclusive ? right : ascending ? right + 1 : right - 1
    for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
        range.push(i)
    }
    return range
}
