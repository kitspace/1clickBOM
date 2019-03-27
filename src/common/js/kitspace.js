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

messenger.on('updateKitnic', interfaces => {
    const adding = {}
    for (const name in interfaces) {
        const retailer = interfaces[name]
        adding[name] = retailer.adding_lines
    }
    window.postMessage(
        {from: 'extension', message: 'updateAddingState', value: adding},
        '*'
    )
})

window.addEventListener(
    'message',
    event => {
        if (event.data.from === 'page') {
            return messenger.send(event.data.message, event.data.value)
        }
    },
    false
)
