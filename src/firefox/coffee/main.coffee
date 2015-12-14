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
                  contentScript:"
                      AddonManager.getAddonByID('1clickBOM@monostable',
                          function(aAddon) {
                            window.gViewController.commands
                            .cmd_showItemDetails.doCommand(aAddon, true);
                          });"
                )
            )
    else if options.loadReason == 'upgrade'
        ffObj =
            title:'New UI and auto-complete!'
            text:"Hope you like the new look. Be sure to try out 1clickBOM's
                new feature that searches Octopart and Findchips.com for you."
            iconURL : './images/logo48.png'
            onClick: () ->
                firefoxTabs.open('http://1clickBOM.com')
        notifications.notify(ffObj)

    background(bgMessenger(popup))
