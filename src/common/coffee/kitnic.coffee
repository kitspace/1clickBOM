{messenger} = require('./messenger')
window.postMessage({from:'extension', message:'register'}, '*')
messenger.send('getBackgroundState')

messenger.on 'updateKitnic', (interfaces) ->
    adding = {}
    for name, retailer of interfaces
        adding[name] = retailer.adding_lines
    window.postMessage({from:'extension', message:'updateAddingState', value:adding}, '*')

window.addEventListener 'message', (event) ->
    if event.data.from == 'page'
        messenger.send(event.data.message, event.data.value)
, false
