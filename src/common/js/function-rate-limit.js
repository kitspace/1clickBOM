const setTimeout = require('./browser').browser.setTimeout

module.exports = rateLimit

function rateLimit(limitCount, limitInterval, fn) {
    var fifo = []

    // count starts at limit
    // each call of `fn` decrements the count
    // it is incremented after limitInterval
    var count = limitCount

    function call_next(args) {
        setTimeout(function() {
            if (fifo.length > 0) {
                call_next()
            } else {
                count = count + 1
            }
        }, limitInterval)

        var call_args = fifo.shift()

        // if there is no next item in the queue
        // and we were called with args, trigger function immediately
        if (!call_args && args) {
            fn.apply(args[0], args[1])
            return
        }

        fn.apply(call_args[0], call_args[1])
    }

    return function rate_limited_function() {
        var ctx = this
        var args = Array.prototype.slice.call(arguments)
        if (count <= 0) {
            fifo.push([ctx, args])
            return
        }

        count = count - 1
        call_next([ctx, args])
    }
}
