const { background } = require('./background')
const { bgMessenger } = require('./bg_messenger')
const { popup, message_exchange } = require('./browser')
const http = require('./http')
const firefoxTabs = require('sdk/tabs')
const notifications = require('sdk/notifications')

exports.main = function main(options, callbacks) {
    if (options.loadReason === 'install') {
        http.getLocation(() =>
            //open 1clickBOM preferences
            firefoxTabs.open({
              url: 'about:addons',
              onReady(tab) {
                return tab.attach({
                  contentScriptWhen: 'end',
                  contentScript:
                      "AddonManager.getAddonByID("
                          + "'1clickBOM@monostable',           "
                          + "function(aAddon) {                "
                          + "    window                        "
                          + "        .gViewController          "
                          + "        .commands                 "
                          + "        .cmd_showItemDetails      "
                          + "        .doCommand(aAddon, true)  "
                          + "})                                "
                })
            }
          })
        )
    }

    return background(bgMessenger(popup, message_exchange))
}
