{messenger} = require('./messenger')

console.log('hi')

send = (retailer) ->
    console.log('sending quickAddToCart', retailer)
    messenger.send('quickAddToCart', retailer)

window.postMessage({type:'FromExtension'}, '*')

window.addEventListener 'message', (event) ->
    if event.source != window
        return
    if event.data.type && (event.data.type == 'FromPage')
        send(event.data.retailer)
, false
