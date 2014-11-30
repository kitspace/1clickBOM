{ ActionButton } = require("sdk/ui/button/action")

button = ActionButton({
    id:"bom_button",
    label:"1clickBOM",
    icon : {
        "16": "./images/button16.png",
        "32": "./images/logo32.png"
    },
    onClick: (state) ->
        console.log("button '"+ state.label + "'was clicked")
})
console.log("yooo")
