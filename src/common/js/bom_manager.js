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
Promise.config({cancellation: true})

const oneClickBom = require('1-click-bom')
const retailer_list = oneClickBom.getRetailers()

const http = require('./http')
const {browser} = require('./browser')
const {Digikey} = require('./digikey')
const {Farnell} = require('./farnell')
const {Mouser} = require('./mouser')
const {RS} = require('./rs')
const {LCSC} = require('./lcsc')
const {Newark} = require('./newark')
const {badge} = require('./badge')
const {autoComplete} = require('./auto_complete')

const bom_manager = {
    retailers: [Digikey, Farnell, Mouser, RS, Newark, LCSC],
    init(callback) {
        this.filling_carts = false
        this.emptying_carts = false
        return browser.prefsGet(
            ['country', 'settings'],
            ({country, settings: stored_settings}) => {
                let retailer
                let setting_values
                this.interfaces = {}
                if (!country) {
                    country = 'Other'
                }
                let count = this.retailers.length
                return this.retailers.map(
                    retailer_interface => (
                        (retailer = retailer_interface.name),
                        __guard__(
                            __guard__(stored_settings, x1 => x1[country]),
                            x => x[retailer]
                        ) != null
                            ? (setting_values =
                                  stored_settings[country][retailer])
                            : (setting_values = {}),
                        (this.interfaces[retailer] = new retailer_interface(
                            country,
                            setting_values,
                            function() {
                                count -= 1
                                if (count === 0) {
                                    return __guardFunc__(callback, f => f())
                                }
                            }
                        ))
                    )
                )
            }
        )
    },

    getBOM(callback) {
        return browser.storageGet(['bom'], ({bom}) => {
            if (bom == null) {
                bom = {}
            } else {
                const old_bom = retailer_list.reduce(
                    (prev, k) => prev || (prev = bom[k] != null),
                    false
                )
                if (old_bom) {
                    bom = {}
                }
            }
            if (bom.retailers == null) {
                bom.retailers = {}
            }
            if (bom.lines == null) {
                bom.lines = []
            }
            for (let i = 0; i < bom.lines.length; i++) {
                const line = bom.lines[i]
                if (line.partNumbers == null) {
                    line.partNumbers = []
                    if (line.partNumber !== '') {
                        line.partNumbers.push({
                            manufacturer: line.manufacturer.trim(),
                            part: line.partNumber.trim()
                        })
                    }
                }
            }
            return callback(bom)
        })
    },

    autoComplete(deep) {
        return new Promise((resolve, reject) => {
            return this.getBOM(bom => {
                const prev_lines = bom.lines
                const p = autoComplete(bom.lines, deep)
                return p.then(lines => {
                    bom = {}
                    bom.lines = lines
                    bom.retailers = this._to_retailers(lines)
                    return browser.storageSet({bom}, () =>
                        resolve(
                            oneClickBom.numberOfEmpty(prev_lines) -
                                oneClickBom.numberOfEmpty(lines)
                        )
                    )
                })
            })
        })
    },

    addToBOM(text, callback) {
        const {lines, invalid, warnings} = oneClickBom.parse(text)
        if (invalid.length > 0) {
            for (let i = 0; i < invalid.length; i++) {
                var priority
                const inv = invalid[i]
                var title = 'Could not parse row '
                title += inv.row
                var message = inv.reason + '\n'
                browser.notificationsCreate({
                    type: 'basic',
                    title,
                    message,
                    iconUrl: '/images/warning.png'
                })
                badge.setDecaying('Warn', '#FF8A00', (priority = 2))
            }
        } else if (lines.length === 0) {
            var priority
            var title = 'Nothing pasted '
            var message = 'Clipboard is empty'
            browser.notificationsCreate({
                type: 'basic',
                title,
                message,
                iconUrl: '/images/warning.png'
            })
            badge.setDecaying('Warn', '#FF8A00', (priority = 2))
        } else if (__guard__(warnings, x => x.length) > 0) {
            for (let j = 0; j < warnings.length; j++) {
                var priority
                const w = warnings[j]
                var {title} = w
                var {message} = w
                browser.notificationsCreate({
                    type: 'basic',
                    title,
                    message,
                    iconUrl: '/images/warning.png'
                })
                badge.setDecaying('Warn', '#FF8A00', (priority = 2))
            }
        } else if (lines.length > 0) {
            badge.setDecaying('OK', '#00CF0F')
        }
        return this._add_to_bom(lines, invalid, callback)
    },

    _to_retailers(lines) {
        const r = {}
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i]
            for (const retailer in line.retailers) {
                const part = line.retailers[retailer]
                if (part != null && part !== '') {
                    if (r[retailer] == null) {
                        r[retailer] = []
                    }
                    r[retailer].push({
                        part,
                        quantity: line.quantity,
                        reference: line.reference
                    })
                }
            }
        }
        return r
    },

    _add_to_bom(lines, invalid, callback) {
        return this.getBOM(bom => {
            let warnings
            ;[lines, warnings] = oneClickBom.merge(bom.lines, lines)
            bom.lines = lines
            for (let i = 0; i < warnings.length; i++) {
                var priority
                const warning = warnings[i]
                browser.notificationsCreate({
                    type: 'basic',
                    title: warning.title,
                    message: warning.message,
                    iconUrl: '/images/warning.png'
                })
                badge.setDecaying('Warn', '#FF8A00', (priority = 2))
            }
            bom.retailers = this._to_retailers(bom.lines)
            const over = []
            for (var retailer in bom.retailers) {
                lines = bom.retailers[retailer]
                if (lines.length > 100) {
                    over.push(retailer)
                }
            }
            if (over.length > 0) {
                var priority
                const title = "That's a lot of lines!"
                let message = 'You have over 100 lines for '
                message += over[0]
                if (over.length > 1) {
                    const iterable = over.slice(1, over.length - 2 + 1)
                    for (let j = 0; j < iterable.length; j++) {
                        retailer = iterable[j]
                        message += `, ${retailer}`
                    }
                    message += ' and '
                    message += over[over.length - 1]
                }
                message +=
                    '. Adding the lines may take a very long time (or even forever). It may be OK but it really depends on the site.'
                browser.notificationsCreate({
                    type: 'basic',
                    title,
                    message,
                    iconUrl: '/images/warning.png'
                })
                badge.setDecaying('Warn', '#FF8A00', (priority = 2))
            }
            return browser.storageSet({bom}, () => {
                return __guardFunc__(callback, f => f(this))
            })
        })
    },

    notifyFillCart(lines, retailer, result) {
        if (!result.success) {
            var priority
            const {fails} = result
            const failed_lines = []
            if (fails.length === 0) {
                var title = 'There may have been problems adding lines'
                title += ` to ${retailer} cart. `
                failed_lines.push({
                    title: 'Please check the cart to try and ',
                    message: ''
                })
                failed_lines.push({
                    title: 'correct any issues.',
                    message: ''
                })
            } else {
                var title = `Could not add ${fails.length}`
                title += ` out of ${lines.length} line`
                title += lines.length > 1 ? 's' : ''
                title += ` to ${retailer} cart:`
                for (let i = 0; i < fails.length; i++) {
                    const fail = fails[i]
                    failed_lines.push({
                        title: `line: ${fail.reference} | ${fail.quantity} | ${fail.part}`,
                        message: ''
                    })
                }
            }
            browser.notificationsCreate({
                type: 'list',
                title,
                message: '',
                items: failed_lines,
                iconUrl: '/images/error.png'
            })
            badge.setDecaying('Err', '#FF0000', (priority = 2))
        } else {
            badge.setDecaying('OK', '#00CF0F')
        }
        if (result.warnings != null) {
            var title
            var priority
            return result.warnings.map(
                warning => (
                    (title = warning),
                    browser.notificationsCreate({
                        type: 'basic',
                        title,
                        message: '',
                        iconUrl: '/images/warning.png'
                    }),
                    badge.setDecaying('Warn', '#FF8A00', (priority = 1))
                )
            )
        }
    },

    notifyEmptyCart(retailer, result) {
        if (!result.success) {
            let priority
            const title = `Could not empty ${retailer} cart`
            browser.notificationsCreate({
                type: 'basic',
                title,
                message: '',
                iconUrl: '/images/error.png'
            })
            return badge.setDecaying('Err', '#FF0000', (priority = 2))
        } else {
            return badge.setDecaying('OK', '#00CF0F')
        }
    },

    fillCart(retailer, callback) {
        return this.getBOM(bom => {
            if (bom.retailers[retailer] != null) {
                return this.interfaces[retailer].addLines(
                    bom.retailers[retailer],
                    result => {
                        this.notifyFillCart(
                            bom.retailers[retailer],
                            retailer,
                            result
                        )
                        return callback(result)
                    }
                )
            }
        })
    },

    emptyCart(retailer, callback) {
        return this.interfaces[retailer].clearCart(result => {
            this.notifyEmptyCart(retailer, result)
            return __guardFunc__(callback, f => f(result))
        })
    }
}

bom_manager.init()

exports.bom_manager = bom_manager

function __guard__(value, transform) {
    return typeof value !== 'undefined' && value !== null
        ? transform(value)
        : undefined
}
function __guardFunc__(func, transform) {
    return typeof func === 'function' ? transform(func) : undefined
}
