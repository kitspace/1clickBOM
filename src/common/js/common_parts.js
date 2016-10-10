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
const fuzzy   = require('fuzzy')
const Qty     = require('js-quantities')

const { browser } = require('./browser')
const capacitors = browser.getLocal('data/capacitors.json')

exports.search = function search() {
    return Promise.resolve(_search(...arguments))
}

function _search(query, retailers = [], other_fields = []) {
    if(/capacitor/i.test(query)) {
        return getCapacitors(query)
    }
    return {retailers:{}, partNumbers:[]}
}

function getCapacitors(term) {
    let results = [].concat(capacitors)

    let match = extract.bind(null, term, results)

    results = match(/\d*\.?\d* ?(p|n|u|µ)F/i, (value, c) => {
        return Qty(c.extravals.Capacitance).eq(Qty(value))
    })

    results = match(/\d*\.?\d* ?V/i, (rating, c) => {
        return Qty(c.extravals['Voltage Rating (DC)']).eq(Qty(rating))
    })

    results = match(/\d*\.?\d* ?%/, (tolerance, c) => {
        return parseFloat(tolerance) >= parseFloat(c.extravals.Tolerance.slice(1))
    })

    results = match(/(0402|0603|0805|1206|2312|1210)/, (size, c) => {
        return c.extravals.Size === size
    })

    results = match(/(X7R|X5R|C0G|NP0)/i, (characteristic, c) => {
        return RegExp(characteristic).test(c.extravals.Characteristic)
    })

    if (results.length > 1 && term.trim() !== '') {
        const descriptions = results.map(describe)
        results = fuzzy.filter(term, descriptions).map(r => results[r.index])
    }

    return results.reduce((prev, item) => {
        Object.keys(item.retailers).forEach(name => {
            if (prev.retailers[name] == null)  {
                prev.retailers[name] = item.retailers[name][0]
            }
        })
        prev.partNumbers = prev.partNumbers.concat(item.partNumbers)
        return prev
    }, {retailers:{}, partNumbers:[]})

}

function extract(term, results, regex, f) {
    const match = regex.exec(term)
    if (match != null) {
        const value = match[0]
        term = term.replace(value, '')
        return results.filter(f.bind(null, value))
    }
    return results
}



function describe(item) {
    return "Capacitor " + Object.keys(item.extravals).reduce((prev, k) => {
        return prev + item.extravals[k] + ' '
    }, '').trim()
}
