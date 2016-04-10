{messenger} = require('./messenger')
window.postMessage({type:'FromExtension'}, '*')

window.addEventListener 'message', (event) ->
    if event.source != window
        return
    if event.data.type && (event.data.type == 'FromPage')
        messenger.send('quickAddToCart', event.data.retailer)
, false
