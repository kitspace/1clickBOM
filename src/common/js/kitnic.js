const { messenger } = require('./messenger')
window.postMessage({from:'extension', message:'register'}, '*')
messenger.send('getBackgroundState')

messenger.on('updateKitnic', function(interfaces) {
    const adding = {}
    for (const name in interfaces) {
        const retailer = interfaces[name]
        adding[name] = retailer.adding_lines
    }
    return window.postMessage({from:'extension', message:'updateAddingState', value:adding}, '*')
}
)

window.addEventListener('message', function(event) {
    if (event.data.from === 'page') {
        return messenger.send(event.data.message, event.data.value)
    }
}
, false)
