{background}     = require './background'
{bgMessenger}    = require './bg_messenger'
{popup} = require './browser'
http    = require './http'
self    = require 'sdk/self'
tabs    = require 'sdk/tabs'

exports.main = (options, callbacks) ->
    console.log('1clickBOM main loaded')
    if options.loadReason == 'install'
        http.getLocation () ->
            #open 1clickBOM preferences
            tabs.open(
              url: 'about:addons',
              onReady: (tab) ->
                tab.attach(
                  contentScriptWhen: 'end',
                  contentScript:"
                      AddonManager.getAddonByID('#{self.id}', function(aAddon) {\n
                        unsafeWindow.gViewController.commands
                            .cmd_showItemDetails.doCommand(aAddon, true);\n
                      });\n"
                )
            )

    background(bgMessenger(popup))
