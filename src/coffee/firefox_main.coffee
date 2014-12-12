{ ActionButton } = require("sdk/ui/button/action")

data = require("sdk/self").data

popup = require("sdk/panel").Panel({
    contentURL: data.url("html/popup.html")
    contentScriptFile: [data.url("js/browser.js")
                       , data.url("js/util.js")
                       , data.url("js/popup.js")
                       ]
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

console.log("yooo")
