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

const oneClickBom = require('1-click-bom')
const retailer_list = require('1-click-bom').getRetailers()

const {bom_manager} = require('./bom_manager')
const {browser} = require('./browser')
const http = require('./http')
const {badge} = require('./badge')

exports.background = function background(messenger) {
    browser.prefsOnChanged(['country', 'settings'], () => bom_manager.init())

    const sendState = () =>
        bom_manager.getBOM(function(bom) {
            messenger.send('sendBackgroundState', {
                bom,
                interfaces: bom_manager.interfaces,
                onDotTSV: tsvPageNotifier.onDotTSV
            })
            console.log('updateKitnic')
            messenger.send('updateKitnic', bom_manager.interfaces)
        })

    var tsvPageNotifier = require('./tsv_page_notifier').tsvPageNotifier(
        sendState,
        bom_manager
    )

    browser.tabsOnUpdated(() => {
        return tsvPageNotifier.checkPage()
    })

    function autoComplete(deep = false) {
        function finish(timeout_id, no_of_completed) {
            browser.clearTimeout(timeout_id)
            sendState()
            if (no_of_completed > 0) {
                browser.notificationsCreate({
                    type: 'basic',
                    title: 'Auto-complete successful',
                    message:
                        `Completed ${no_of_completed} fields for you ` +
                        'by matching against the CPL and searching Octopart ' +
                        'and Findchips.',
                    iconUrl: '/images/ok.png'
                })
                return badge.setDecaying('OK', '#00CF0F')
            } else {
                browser.notificationsCreate({
                    type: 'basic',
                    title: 'Auto-complete returned 0 results',
                    message: 'Could not complete any fields for you.',
                    iconUrl: '/images/warning.png'
                })
                return badge.setDecaying('Warn', '#FF8A00')
            }
        }
        const timeout_id = browser.setTimeout(function() {
            promise.cancel()
            return finish(timeout_id, 0)
        }, 180000)
        var promise = bom_manager.autoComplete(deep)
        return promise.then(no_of_completed =>
            finish(timeout_id, no_of_completed)
        )
    }

    function emptyCart(name) {
        bom_manager.interfaces[name].clearing_cart = true
        const timeout_id = browser.setTimeout(
            function(name) {
                bom_manager.interfaces[name].clearing_cart = false
                return sendState()
            }.bind(null, name),
            180000
        )
        bom_manager.emptyCart(
            name,
            function(name, timeout_id) {
                browser.clearTimeout(timeout_id)
                bom_manager.interfaces[name].clearing_cart = false
                bom_manager.interfaces[name].openCartTab()
                return sendState()
            }.bind(null, name, timeout_id)
        )
        return sendState()
    }

    function fillCart(name) {
        bom_manager.interfaces[name].adding_lines = true
        const timeout_id = browser.setTimeout(
            function(name) {
                bom_manager.interfaces[name].adding_lines = false
                return sendState()
            }.bind(null, name),
            180000
        )
        bom_manager.fillCart(
            name,
            function(name, timeout_id) {
                browser.clearTimeout(timeout_id)
                bom_manager.interfaces[name].adding_lines = false
                bom_manager.interfaces[name].openCartTab()
                return sendState()
            }.bind(null, name, timeout_id)
        )
        return sendState()
    }

    messenger.on('getBackgroundState', () => sendState())

    messenger.on('fillCart', fillCart)

    messenger.on('openCart', name => bom_manager.interfaces[name].openCartTab())

    messenger.on('deepAutoComplete', function() {
        let deep
        return autoComplete((deep = true))
    })

    messenger.on('emptyCart', emptyCart)

    messenger.on('clearBOM', () =>
        browser.storageRemove('bom', () => sendState())
    )

    messenger.on('paste', text => {
        bom_manager.addToBOM(text, () => sendState())
    })

    messenger.on('copy', () =>
        bom_manager.getBOM(function(bom) {
            messenger.send('copyResponse', oneClickBom.writeTSV(bom.lines))
            return badge.setDecaying('OK', '#00CF0F')
        })
    )

    messenger.on('loadFromPage', () =>
        tsvPageNotifier.addToBOM(() => sendState())
    )

    messenger.on('emptyCarts', () => retailer_list.map(name => emptyCart(name)))

    messenger.on('fillCarts', () => retailer_list.map(name => fillCart(name)))

    messenger.on('quickAddToCart', obj => tsvPageNotifier.quickAddToCart(obj))

    messenger.on('bomBuilderAddToCart', ({tsv, id}) => {
        const {lines} = oneClickBom.parseTSV(tsv)
        const retailers = bom_manager._to_retailers(lines)
        for (const retailer in retailers) {
            const parts = retailers[retailer]
            bom_manager.interfaces[retailer].adding_lines = true
            const timeout_id = browser.setTimeout(() => {
                bom_manager.interfaces[retailer].adding_lines = false
                sendState()
            }, 180000)
            bom_manager.interfaces[retailer].addLines(parts, result => {
                browser.clearTimeout(timeout_id)
                bom_manager.interfaces[retailer].adding_lines = false
                sendState()
                bom_manager.interfaces[retailer].openCartTab()
                console.log('bomBuilderResult', {parts, retailer, result})
                messenger.send('bomBuilderResult', {parts, retailer, result, id})
            })
        }
    })

    return sendState()
}
