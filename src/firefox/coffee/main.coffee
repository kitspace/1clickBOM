{background}  = require './background'
{bgMessenger} = require './bg_messenger'
{popup, message_exchange} = require './browser'
http          = require './http'
firefoxTabs   = require 'sdk/tabs'
notifications = require 'sdk/notifications'

exports.main = (options, callbacks) ->
    if options.loadReason == 'install'
        http.getLocation () ->
            #open 1clickBOM preferences
            firefoxTabs.open(
              url: 'about:addons',
              onReady: (tab) ->
                tab.attach(
                  contentScriptWhen: 'end',
                  contentScript:"
                      AddonManager.getAddonByID('1clickBOM@monostable',
                          function(aAddon) {
                            window.gViewController.commands
                            .cmd_showItemDetails.doCommand(aAddon, true);
                          });"
                )
            )

    background(bgMessenger(popup, message_exchange))
