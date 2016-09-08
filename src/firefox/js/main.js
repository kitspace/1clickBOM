import { background } from './background';
import { bgMessenger } from './bg_messenger';
import { popup, message_exchange } from './browser';
import http from './http';
import firefoxTabs from 'sdk/tabs';
import notifications from 'sdk/notifications';

export function main(options, callbacks) {
    if (options.loadReason === 'install') {
        http.getLocation(() =>
            //open 1clickBOM preferences
            firefoxTabs.open({
              url: 'about:addons',
              onReady(tab) {
                return tab.attach({
                  contentScriptWhen: 'end',
                  contentScript:"AddonManager.getAddonByID('1clickBOM@monostable', function(aAddon) { window.gViewController.commands .cmd_showItemDetails.doCommand(aAddon, true); });"
                });
            }
            })
        );
    }

    return background(bgMessenger(popup, message_exchange));
}
