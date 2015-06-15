{ ActionButton } = require("sdk/ui/button/action")

{data      }  = require 'sdk/self'
{browser   }  = require './browser'
{background}  = require './background'
{bgMessenger} = require './bg_messenger'
{Cc, Ci}      = require 'chrome'

popup = require("sdk/panel").Panel({
    contentURL: data.url("html/popup.html")
    contentScriptFile: [data.url("popup.js")]
})

button = ActionButton({
    id:"bom_button",
    label:"1clickBOM",
    icon : {
        "16": "./images/button16.png",
        "32": "./images/button32.png"
    },
    onClick: (state) ->
        popup.show({position:button})
})

console.log("1clickBOM main loaded")

background(bgMessenger(popup))
