{background}  = require './background'
{bgMessenger} = require './bg_messenger'
{popup}       = require './browser'
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
                  #the check for AddonManager is there because errors came up
                  #in the log, not sure why AddonManager is sometimes not
                  #defined but better to not throw an error either way
                  contentScript:"
                      if (AddonManager != null) {
                          AddonManager.getAddonByID('1clickBOM@monostable',
                              function(aAddon) {
                                window.gViewController.commands
                                .cmd_showItemDetails.doCommand(aAddon, true);
                              });
                      }"
                )
            )

    background(bgMessenger(popup))
