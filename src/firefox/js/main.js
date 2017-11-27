const {background} = require('./background')
const {bgMessenger} = require('./bg_messenger')
const {browser, popup, message_exchange} = require('./browser')
const http = require('./http')
const firefoxTabs = require('sdk/tabs')
const notifications = require('sdk/notifications')

exports.main = function main(options, callbacks) {
    if (options.loadReason === 'install') {
        browser.tabsQuery({url: '*://kitspace.org/boards/*'}, tabs => {
            tabs.forEach(browser.tabsReload)
        })
        http.getLocation()
    }

    return background(bgMessenger(popup, message_exchange))
}
