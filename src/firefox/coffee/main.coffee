{background}     = require './background'
{bgMessenger}    = require './bg_messenger'
{browser, popup} = require './browser'
locationChanged  = require './location_changed'
http             = require './http'
firefoxTabs      = require 'sdk/tabs'

exports.main = (options, callbacks) ->
    #attach the tab location changed notifier to all existing tabs
    browser.tabsQuery {url:'*'}, (tabs) ->
        for tab in tabs
            locationChanged.attach(tab)
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
    background(bgMessenger(popup))
