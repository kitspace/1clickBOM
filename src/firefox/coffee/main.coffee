{ ActionButton } = require("sdk/ui/button/action")

data = require("sdk/self").data
browser = require("browser").browser

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

browser.storageOnChanged (changes) ->
    if changes.country || changes.settings
        console.log("WRONG!")
    else if changes.bom
        console.log("WRIGHT!")

browser.storageSet({bom:{farnell:[1,2,3]}})

browser.storageGet ["bom"], (obj) ->
    console.log("obj", obj)

browser.storageRemove "bom"

browser.storageGet ["bom"], (obj) ->
    console.log("obj2", obj)

console.log("1clickBOM main loaded")
