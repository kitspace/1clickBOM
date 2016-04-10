{messenger} = require('./messenger')

console.log('hi')

setTimeout () ->
    console.log('sending quickAddToCart')
    messenger.send('quickAddToCart', 'Digikey')
, 1000
