const {messenger} = require('./messenger')

setInterval(
    () => window.postMessage({from: 'extension', message: 'register'}, '*'),
    3000
)

messenger.send('getBackgroundState')

messenger.on('bomBuilderResult', value => {
    window.postMessage(
        {from: 'extension', message: 'bomBuilderResult', value},
        '*'
    )
})

messenger.on('updateKitspace', interfaces => {
    const adding = {}
    for (const name in interfaces) {
        const retailer = interfaces[name]
        adding[name] = retailer.adding_lines
    }
    const clearing = {}
    for (const name in interfaces) {
        const retailer = interfaces[name]
        clearing[name] = retailer.clearing_cart
    }
    window.postMessage(
        {from: 'extension', message: 'updateAddingState', value: adding},
        '*'
    )
    window.postMessage(
        {from: 'extension', message: 'updateClearingState', value: clearing},
        '*'
    )
})

window.addEventListener(
    'message',
    event => {
        if (event.data.from === 'page') {
            messenger.send(event.data.message, event.data.value)
        }
    },
    false
)
