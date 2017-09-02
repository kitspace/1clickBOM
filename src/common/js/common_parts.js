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
const electroGrammar = require('electro-grammar')

const { browser } = require('./browser')
const cpl = {
    capacitors : browser.getLocal('data/capacitors.json'),
    resistors  : browser.getLocal('data/resistors.json'),
    leds       : browser.getLocal('data/leds.json'),
}


//we wrap in a promise to be compatible the completers that send async web requests
exports.search = function search() {
    return new Promise((resolve, reject) => {
        try {
            const result = _search(...arguments)
            resolve(result)
        } catch (e) {
            reject(e)
        }
    })
}

function _search(query, retailers = [], other_fields = []) {
    const c = electroGrammar.parse(query)
    const ids = electroGrammar.matchCPL(c)

    const components = cpl[c.type]

    const results = ids.map(id => {
        return components.reduce((prev, r) => {
            if (prev) {
                return prev
            } else if (r.cplid === id) {
                return r
            }
        }, null)
    }).filter(x => x)

    return combine(results)
}

function combine(results) {
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
