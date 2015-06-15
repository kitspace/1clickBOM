{browser, popup} = require './browser'
{background}     = require './background'
{bgMessenger}    = require './bg_messenger'

console.log("1clickBOM main loaded")

background(bgMessenger(popup))
