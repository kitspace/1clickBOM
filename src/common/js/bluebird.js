const setTimeout = require('./browser').browser.setTimeout
const clearTimeout = require('./browser').browser.clearTimeout
/* @preserve
 * The MIT License (MIT)
 *
 * Copyright (c) 2013-2015 Petka Antonov
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */
/**
 * bluebird build version 3.3.4
 * Features enabled: core
 * Features disabled: race, call_get, generators, map, nodeify, promisify, props, reduce, settle, some, using, timers, filter, any, each
 */
!(function(e) {
    if ('object' == typeof exports && 'undefined' != typeof module)
        module.exports = e()
    else if ('function' == typeof define && define.amd) define([], e)
    else {
        let f
        'undefined' != typeof window
            ? (f = window)
            : 'undefined' != typeof global
            ? (f = global)
            : 'undefined' != typeof self && (f = self),
            (f.Promise = e())
    }
})(function() {
    let define, module, exports
    return (function e(t, n, r) {
        function s(o, u) {
            if (!n[o]) {
                if (!t[o]) {
                    const a = typeof _dereq_ == 'function' && _dereq_
                    if (!u && a) return a(o, !0)
                    if (i) return i(o, !0)
                    const f = new Error("Cannot find module '" + o + "'")
                    throw ((f.code = 'MODULE_NOT_FOUND'), f)
                }
                const l = (n[o] = {exports: {}})
                t[o][0].call(
                    l.exports,
                    function(e) {
                        const n = t[o][1][e]
                        return s(n ? n : e)
                    },
                    l,
                    l.exports,
                    e,
                    t,
                    n,
                    r
                )
            }
            return n[o].exports
        }
        var i = typeof _dereq_ == 'function' && _dereq_
        for (let o = 0; o < r.length; o++) s(r[o])
        return s
    })(
        {
            1: [
                function(_dereq_, module, exports) {
                    'use strict'
                    let firstLineError
                    try {
                        throw new Error()
                    } catch (e) {
                        firstLineError = e
                    }
                    const schedule = _dereq_('./schedule')
                    const Queue = _dereq_('./queue')
                    const util = _dereq_('./util')

                    function Async() {
                        this._isTickUsed = false
                        this._lateQueue = new Queue(16)
                        this._normalQueue = new Queue(16)
                        this._haveDrainedQueues = false
                        this._trampolineEnabled = true
                        const self = this
                        this.drainQueues = function() {
                            self._drainQueues()
                        }
                        this._schedule = schedule
                    }

                    Async.prototype.enableTrampoline = function() {
                        this._trampolineEnabled = true
                    }

                    Async.prototype.disableTrampolineIfNecessary = function() {
                        if (util.hasDevTools) {
                            this._trampolineEnabled = false
                        }
                    }

                    Async.prototype.haveItemsQueued = function() {
                        return this._isTickUsed || this._haveDrainedQueues
                    }

                    Async.prototype.fatalError = function(e, isNode) {
                        if (isNode) {
                            process.stderr.write(
                                'Fatal ' +
                                    (e instanceof Error ? e.stack : e) +
                                    '\n'
                            )
                            process.exit(2)
                        } else {
                            this.throwLater(e)
                        }
                    }

                    Async.prototype.throwLater = function(fn, arg) {
                        if (arguments.length === 1) {
                            arg = fn
                            fn = function() {
                                throw arg
                            }
                        }
                        if (typeof setTimeout !== 'undefined') {
                            setTimeout(function() {
                                fn(arg)
                            }, 0)
                        } else
                            try {
                                this._schedule(function() {
                                    fn(arg)
                                })
                            } catch (e) {
                                throw new Error(
                                    'No async scheduler available\u000a\u000a    See http://goo.gl/MqrFmX\u000a'
                                )
                            }
                    }

                    function AsyncInvokeLater(fn, receiver, arg) {
                        this._lateQueue.push(fn, receiver, arg)
                        this._queueTick()
                    }

                    function AsyncInvoke(fn, receiver, arg) {
                        this._normalQueue.push(fn, receiver, arg)
                        this._queueTick()
                    }

                    function AsyncSettlePromises(promise) {
                        this._normalQueue._pushOne(promise)
                        this._queueTick()
                    }

                    if (!util.hasDevTools) {
                        Async.prototype.invokeLater = AsyncInvokeLater
                        Async.prototype.invoke = AsyncInvoke
                        Async.prototype.settlePromises = AsyncSettlePromises
                    } else {
                        Async.prototype.invokeLater = function(
                            fn,
                            receiver,
                            arg
                        ) {
                            if (this._trampolineEnabled) {
                                AsyncInvokeLater.call(this, fn, receiver, arg)
                            } else {
                                this._schedule(function() {
                                    setTimeout(function() {
                                        fn.call(receiver, arg)
                                    }, 100)
                                })
                            }
                        }

                        Async.prototype.invoke = function(fn, receiver, arg) {
                            if (this._trampolineEnabled) {
                                AsyncInvoke.call(this, fn, receiver, arg)
                            } else {
                                this._schedule(function() {
                                    fn.call(receiver, arg)
                                })
                            }
                        }

                        Async.prototype.settlePromises = function(promise) {
                            if (this._trampolineEnabled) {
                                AsyncSettlePromises.call(this, promise)
                            } else {
                                this._schedule(function() {
                                    promise._settlePromises()
                                })
                            }
                        }
                    }

                    Async.prototype.invokeFirst = function(fn, receiver, arg) {
                        this._normalQueue.unshift(fn, receiver, arg)
                        this._queueTick()
                    }

                    Async.prototype._drainQueue = function(queue) {
                        while (queue.length() > 0) {
                            const fn = queue.shift()
                            if (typeof fn !== 'function') {
                                fn._settlePromises()
                                continue
                            }
                            const receiver = queue.shift()
                            const arg = queue.shift()
                            fn.call(receiver, arg)
                        }
                    }

                    Async.prototype._drainQueues = function() {
                        this._drainQueue(this._normalQueue)
                        this._reset()
                        this._haveDrainedQueues = true
                        this._drainQueue(this._lateQueue)
                    }

                    Async.prototype._queueTick = function() {
                        if (!this._isTickUsed) {
                            this._isTickUsed = true
                            this._schedule(this.drainQueues)
                        }
                    }

                    Async.prototype._reset = function() {
                        this._isTickUsed = false
                    }

                    module.exports = Async
                    module.exports.firstLineError = firstLineError
                },
                {'./queue': 17, './schedule': 18, './util': 21}
            ],
            2: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function(
                        Promise,
                        INTERNAL,
                        tryConvertToPromise,
                        debug
                    ) {
                        let calledBind = false
                        const rejectThis = function(_, e) {
                            this._reject(e)
                        }

                        const targetRejected = function(e, context) {
                            context.promiseRejectionQueued = true
                            context.bindingPromise._then(
                                rejectThis,
                                rejectThis,
                                null,
                                this,
                                e
                            )
                        }

                        const bindingResolved = function(thisArg, context) {
                            if ((this._bitField & 50397184) === 0) {
                                this._resolveCallback(context.target)
                            }
                        }

                        const bindingRejected = function(e, context) {
                            if (!context.promiseRejectionQueued) this._reject(e)
                        }

                        Promise.prototype.bind = function(thisArg) {
                            if (!calledBind) {
                                calledBind = true
                                Promise.prototype._propagateFrom = debug.propagateFromFunction()
                                Promise.prototype._boundValue = debug.boundValueFunction()
                            }
                            const maybePromise = tryConvertToPromise(thisArg)
                            const ret = new Promise(INTERNAL)
                            ret._propagateFrom(this, 1)
                            const target = this._target()
                            ret._setBoundTo(maybePromise)
                            if (maybePromise instanceof Promise) {
                                const context = {
                                    promiseRejectionQueued: false,
                                    promise: ret,
                                    target: target,
                                    bindingPromise: maybePromise
                                }
                                target._then(
                                    INTERNAL,
                                    targetRejected,
                                    undefined,
                                    ret,
                                    context
                                )
                                maybePromise._then(
                                    bindingResolved,
                                    bindingRejected,
                                    undefined,
                                    ret,
                                    context
                                )
                                ret._setOnCancel(maybePromise)
                            } else {
                                ret._resolveCallback(target)
                            }
                            return ret
                        }

                        Promise.prototype._setBoundTo = function(obj) {
                            if (obj !== undefined) {
                                this._bitField = this._bitField | 2097152
                                this._boundTo = obj
                            } else {
                                this._bitField = this._bitField & ~2097152
                            }
                        }

                        Promise.prototype._isBound = function() {
                            return (this._bitField & 2097152) === 2097152
                        }

                        Promise.bind = function(thisArg, value) {
                            return Promise.resolve(value).bind(thisArg)
                        }
                    }
                },
                {}
            ],
            3: [
                function(_dereq_, module, exports) {
                    'use strict'
                    let old
                    if (typeof Promise !== 'undefined') old = Promise
                    function noConflict() {
                        try {
                            if (Promise === bluebird) Promise = old
                        } catch (e) {}
                        return bluebird
                    }
                    var bluebird = _dereq_('./promise')()
                    bluebird.noConflict = noConflict
                    module.exports = bluebird
                },
                {'./promise': 15}
            ],
            4: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function(
                        Promise,
                        PromiseArray,
                        apiRejection,
                        debug
                    ) {
                        const util = _dereq_('./util')
                        const tryCatch = util.tryCatch
                        const errorObj = util.errorObj
                        const async = Promise._async

                        Promise.prototype[
                            'break'
                        ] = Promise.prototype.cancel = function() {
                            if (!debug.cancellation())
                                return this._warn('cancellation is disabled')

                            let promise = this
                            let child = promise
                            while (promise.isCancellable()) {
                                if (!promise._cancelBy(child)) {
                                    if (child._isFollowing()) {
                                        child._followee().cancel()
                                    } else {
                                        child._cancelBranched()
                                    }
                                    break
                                }

                                const parent = promise._cancellationParent
                                if (parent == null || !parent.isCancellable()) {
                                    if (promise._isFollowing()) {
                                        promise._followee().cancel()
                                    } else {
                                        promise._cancelBranched()
                                    }
                                    break
                                } else {
                                    if (promise._isFollowing())
                                        promise._followee().cancel()
                                    child = promise
                                    promise = parent
                                }
                            }
                        }

                        Promise.prototype._branchHasCancelled = function() {
                            this._branchesRemainingToCancel--
                        }

                        Promise.prototype._enoughBranchesHaveCancelled = function() {
                            return (
                                this._branchesRemainingToCancel === undefined ||
                                this._branchesRemainingToCancel <= 0
                            )
                        }

                        Promise.prototype._cancelBy = function(canceller) {
                            if (canceller === this) {
                                this._branchesRemainingToCancel = 0
                                this._invokeOnCancel()
                                return true
                            } else {
                                this._branchHasCancelled()
                                if (this._enoughBranchesHaveCancelled()) {
                                    this._invokeOnCancel()
                                    return true
                                }
                            }
                            return false
                        }

                        Promise.prototype._cancelBranched = function() {
                            if (this._enoughBranchesHaveCancelled()) {
                                this._cancel()
                            }
                        }

                        Promise.prototype._cancel = function() {
                            if (!this.isCancellable()) return

                            this._setCancelled()
                            async.invoke(this._cancelPromises, this, undefined)
                        }

                        Promise.prototype._cancelPromises = function() {
                            if (this._length() > 0) this._settlePromises()
                        }

                        Promise.prototype._unsetOnCancel = function() {
                            this._onCancelField = undefined
                        }

                        Promise.prototype.isCancellable = function() {
                            return this.isPending() && !this.isCancelled()
                        }

                        Promise.prototype._doInvokeOnCancel = function(
                            onCancelCallback,
                            internalOnly
                        ) {
                            if (util.isArray(onCancelCallback)) {
                                for (
                                    let i = 0;
                                    i < onCancelCallback.length;
                                    ++i
                                ) {
                                    this._doInvokeOnCancel(
                                        onCancelCallback[i],
                                        internalOnly
                                    )
                                }
                            } else if (onCancelCallback !== undefined) {
                                if (typeof onCancelCallback === 'function') {
                                    if (!internalOnly) {
                                        const e = tryCatch(
                                            onCancelCallback
                                        ).call(this._boundValue())
                                        if (e === errorObj) {
                                            this._attachExtraTrace(e.e)
                                            async.throwLater(e.e)
                                        }
                                    }
                                } else {
                                    onCancelCallback._resultCancelled(this)
                                }
                            }
                        }

                        Promise.prototype._invokeOnCancel = function() {
                            const onCancelCallback = this._onCancel()
                            this._unsetOnCancel()
                            async.invoke(
                                this._doInvokeOnCancel,
                                this,
                                onCancelCallback
                            )
                        }

                        Promise.prototype._invokeInternalOnCancel = function() {
                            if (this.isCancellable()) {
                                this._doInvokeOnCancel(this._onCancel(), true)
                                this._unsetOnCancel()
                            }
                        }

                        Promise.prototype._resultCancelled = function() {
                            this.cancel()
                        }
                    }
                },
                {'./util': 21}
            ],
            5: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function(NEXT_FILTER) {
                        const util = _dereq_('./util')
                        const getKeys = _dereq_('./es5').keys
                        const tryCatch = util.tryCatch
                        const errorObj = util.errorObj

                        function catchFilter(instances, cb, promise) {
                            return function(e) {
                                const boundTo = promise._boundValue()
                                predicateLoop: for (
                                    let i = 0;
                                    i < instances.length;
                                    ++i
                                ) {
                                    const item = instances[i]

                                    if (
                                        item === Error ||
                                        (item != null &&
                                            item.prototype instanceof Error)
                                    ) {
                                        if (e instanceof item) {
                                            return tryCatch(cb).call(boundTo, e)
                                        }
                                    } else if (typeof item === 'function') {
                                        const matchesPredicate = tryCatch(
                                            item
                                        ).call(boundTo, e)
                                        if (matchesPredicate === errorObj) {
                                            return matchesPredicate
                                        } else if (matchesPredicate) {
                                            return tryCatch(cb).call(boundTo, e)
                                        }
                                    } else if (util.isObject(e)) {
                                        const keys = getKeys(item)
                                        for (let j = 0; j < keys.length; ++j) {
                                            const key = keys[j]
                                            if (item[key] != e[key]) {
                                                continue predicateLoop
                                            }
                                        }
                                        return tryCatch(cb).call(boundTo, e)
                                    }
                                }
                                return NEXT_FILTER
                            }
                        }

                        return catchFilter
                    }
                },
                {'./es5': 10, './util': 21}
            ],
            6: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function(Promise) {
                        let longStackTraces = false
                        const contextStack = []

                        Promise.prototype._promiseCreated = function() {}
                        Promise.prototype._pushContext = function() {}
                        Promise.prototype._popContext = function() {
                            return null
                        }
                        Promise._peekContext = Promise.prototype._peekContext = function() {}

                        function Context() {
                            this._trace = new Context.CapturedTrace(
                                peekContext()
                            )
                        }
                        Context.prototype._pushContext = function() {
                            if (this._trace !== undefined) {
                                this._trace._promiseCreated = null
                                contextStack.push(this._trace)
                            }
                        }

                        Context.prototype._popContext = function() {
                            if (this._trace !== undefined) {
                                const trace = contextStack.pop()
                                const ret = trace._promiseCreated
                                trace._promiseCreated = null
                                return ret
                            }
                            return null
                        }

                        function createContext() {
                            if (longStackTraces) return new Context()
                        }

                        function peekContext() {
                            const lastIndex = contextStack.length - 1
                            if (lastIndex >= 0) {
                                return contextStack[lastIndex]
                            }
                            return undefined
                        }
                        Context.CapturedTrace = null
                        Context.create = createContext
                        Context.deactivateLongStackTraces = function() {}
                        Context.activateLongStackTraces = function() {
                            const Promise_pushContext =
                                Promise.prototype._pushContext
                            const Promise_popContext =
                                Promise.prototype._popContext
                            const Promise_PeekContext = Promise._peekContext
                            const Promise_peekContext =
                                Promise.prototype._peekContext
                            const Promise_promiseCreated =
                                Promise.prototype._promiseCreated
                            Context.deactivateLongStackTraces = function() {
                                Promise.prototype._pushContext = Promise_pushContext
                                Promise.prototype._popContext = Promise_popContext
                                Promise._peekContext = Promise_PeekContext
                                Promise.prototype._peekContext = Promise_peekContext
                                Promise.prototype._promiseCreated = Promise_promiseCreated
                                longStackTraces = false
                            }
                            longStackTraces = true
                            Promise.prototype._pushContext =
                                Context.prototype._pushContext
                            Promise.prototype._popContext =
                                Context.prototype._popContext
                            Promise._peekContext = Promise.prototype._peekContext = peekContext
                            Promise.prototype._promiseCreated = function() {
                                const ctx = this._peekContext()
                                if (ctx && ctx._promiseCreated == null)
                                    ctx._promiseCreated = this
                            }
                        }
                        return Context
                    }
                },
                {}
            ],
            7: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function(Promise, Context) {
                        const getDomain = Promise._getDomain
                        const async = Promise._async
                        const Warning = _dereq_('./errors').Warning
                        const util = _dereq_('./util')
                        const canAttachTrace = util.canAttachTrace
                        let unhandledRejectionHandled
                        let possiblyUnhandledRejection
                        const bluebirdFramePattern = /[\\\/]bluebird[\\\/]js[\\\/](release|debug|instrumented)/
                        let stackFramePattern = null
                        let formatStack = null
                        let indentStackFrames = false
                        let printWarning
                        const debugging = !!(
                            util.env('BLUEBIRD_DEBUG') != 0 &&
                            (true ||
                                util.env('BLUEBIRD_DEBUG') ||
                                util.env('NODE_ENV') === 'development')
                        )

                        const warnings = !!(
                            util.env('BLUEBIRD_WARNINGS') != 0 &&
                            (debugging || util.env('BLUEBIRD_WARNINGS'))
                        )

                        const longStackTraces = !!(
                            util.env('BLUEBIRD_LONG_STACK_TRACES') != 0 &&
                            (debugging ||
                                util.env('BLUEBIRD_LONG_STACK_TRACES'))
                        )

                        let wForgottenReturn =
                            util.env('BLUEBIRD_W_FORGOTTEN_RETURN') != 0 &&
                            (warnings ||
                                !!util.env('BLUEBIRD_W_FORGOTTEN_RETURN'))

                        Promise.prototype.suppressUnhandledRejections = function() {
                            const target = this._target()
                            target._bitField =
                                (target._bitField & ~1048576) | 524288
                        }

                        Promise.prototype._ensurePossibleRejectionHandled = function() {
                            if ((this._bitField & 524288) !== 0) return
                            this._setRejectionIsUnhandled()
                            async.invokeLater(
                                this._notifyUnhandledRejection,
                                this,
                                undefined
                            )
                        }

                        Promise.prototype._notifyUnhandledRejectionIsHandled = function() {
                            fireRejectionEvent(
                                'rejectionHandled',
                                unhandledRejectionHandled,
                                undefined,
                                this
                            )
                        }

                        Promise.prototype._setReturnedNonUndefined = function() {
                            this._bitField = this._bitField | 268435456
                        }

                        Promise.prototype._returnedNonUndefined = function() {
                            return (this._bitField & 268435456) !== 0
                        }

                        Promise.prototype._notifyUnhandledRejection = function() {
                            if (this._isRejectionUnhandled()) {
                                const reason = this._settledValue()
                                this._setUnhandledRejectionIsNotified()
                                fireRejectionEvent(
                                    'unhandledRejection',
                                    possiblyUnhandledRejection,
                                    reason,
                                    this
                                )
                            }
                        }

                        Promise.prototype._setUnhandledRejectionIsNotified = function() {
                            this._bitField = this._bitField | 262144
                        }

                        Promise.prototype._unsetUnhandledRejectionIsNotified = function() {
                            this._bitField = this._bitField & ~262144
                        }

                        Promise.prototype._isUnhandledRejectionNotified = function() {
                            return (this._bitField & 262144) > 0
                        }

                        Promise.prototype._setRejectionIsUnhandled = function() {
                            this._bitField = this._bitField | 1048576
                        }

                        Promise.prototype._unsetRejectionIsUnhandled = function() {
                            this._bitField = this._bitField & ~1048576
                            if (this._isUnhandledRejectionNotified()) {
                                this._unsetUnhandledRejectionIsNotified()
                                this._notifyUnhandledRejectionIsHandled()
                            }
                        }

                        Promise.prototype._isRejectionUnhandled = function() {
                            return (this._bitField & 1048576) > 0
                        }

                        Promise.prototype._warn = function(
                            message,
                            shouldUseOwnTrace,
                            promise
                        ) {
                            return warn(
                                message,
                                shouldUseOwnTrace,
                                promise || this
                            )
                        }

                        Promise.onPossiblyUnhandledRejection = function(fn) {
                            const domain = getDomain()
                            possiblyUnhandledRejection =
                                typeof fn === 'function'
                                    ? domain === null
                                        ? fn
                                        : domain.bind(fn)
                                    : undefined
                        }

                        Promise.onUnhandledRejectionHandled = function(fn) {
                            const domain = getDomain()
                            unhandledRejectionHandled =
                                typeof fn === 'function'
                                    ? domain === null
                                        ? fn
                                        : domain.bind(fn)
                                    : undefined
                        }

                        let disableLongStackTraces = function() {}
                        Promise.longStackTraces = function() {
                            if (
                                async.haveItemsQueued() &&
                                !config.longStackTraces
                            ) {
                                throw new Error(
                                    'cannot enable long stack traces after promises have been created\u000a\u000a    See http://goo.gl/MqrFmX\u000a'
                                )
                            }
                            if (
                                !config.longStackTraces &&
                                longStackTracesIsSupported()
                            ) {
                                const Promise_captureStackTrace =
                                    Promise.prototype._captureStackTrace
                                const Promise_attachExtraTrace =
                                    Promise.prototype._attachExtraTrace
                                config.longStackTraces = true
                                disableLongStackTraces = function() {
                                    if (
                                        async.haveItemsQueued() &&
                                        !config.longStackTraces
                                    ) {
                                        throw new Error(
                                            'cannot enable long stack traces after promises have been created\u000a\u000a    See http://goo.gl/MqrFmX\u000a'
                                        )
                                    }
                                    Promise.prototype._captureStackTrace = Promise_captureStackTrace
                                    Promise.prototype._attachExtraTrace = Promise_attachExtraTrace
                                    Context.deactivateLongStackTraces()
                                    async.enableTrampoline()
                                    config.longStackTraces = false
                                }
                                Promise.prototype._captureStackTrace = longStackTracesCaptureStackTrace
                                Promise.prototype._attachExtraTrace = longStackTracesAttachExtraTrace
                                Context.activateLongStackTraces()
                                async.disableTrampolineIfNecessary()
                            }
                        }

                        Promise.hasLongStackTraces = function() {
                            return (
                                config.longStackTraces &&
                                longStackTracesIsSupported()
                            )
                        }

                        const fireDomEvent = (function() {
                            try {
                                const event = document.createEvent(
                                    'CustomEvent'
                                )
                                event.initCustomEvent(
                                    'testingtheevent',
                                    false,
                                    true,
                                    {}
                                )
                                util.global.dispatchEvent(event)
                                return function(name, event) {
                                    const domEvent = document.createEvent(
                                        'CustomEvent'
                                    )
                                    domEvent.initCustomEvent(
                                        name.toLowerCase(),
                                        false,
                                        true,
                                        event
                                    )
                                    return !util.global.dispatchEvent(domEvent)
                                }
                            } catch (e) {}
                            return function() {
                                return false
                            }
                        })()

                        const fireGlobalEvent = (function() {
                            if (util.isNode) {
                                return function() {
                                    return process.emit.apply(
                                        process,
                                        arguments
                                    )
                                }
                            } else {
                                if (!util.global) {
                                    return function() {
                                        return false
                                    }
                                }
                                return function(name) {
                                    const methodName = 'on' + name.toLowerCase()
                                    const method = util.global[methodName]
                                    if (!method) return false
                                    method.apply(
                                        util.global,
                                        [].slice.call(arguments, 1)
                                    )
                                    return true
                                }
                            }
                        })()

                        function generatePromiseLifecycleEventObject(
                            name,
                            promise
                        ) {
                            return {promise: promise}
                        }

                        const eventToObjectGenerator = {
                            promiseCreated: generatePromiseLifecycleEventObject,
                            promiseFulfilled: generatePromiseLifecycleEventObject,
                            promiseRejected: generatePromiseLifecycleEventObject,
                            promiseResolved: generatePromiseLifecycleEventObject,
                            promiseCancelled: generatePromiseLifecycleEventObject,
                            promiseChained: function(name, promise, child) {
                                return {promise: promise, child: child}
                            },
                            warning: function(name, warning) {
                                return {warning: warning}
                            },
                            unhandledRejection: function(
                                name,
                                reason,
                                promise
                            ) {
                                return {reason: reason, promise: promise}
                            },
                            rejectionHandled: generatePromiseLifecycleEventObject
                        }

                        const activeFireEvent = function(name) {
                            let globalEventFired = false
                            try {
                                globalEventFired = fireGlobalEvent.apply(
                                    null,
                                    arguments
                                )
                            } catch (e) {
                                async.throwLater(e)
                                globalEventFired = true
                            }

                            let domEventFired = false
                            try {
                                domEventFired = fireDomEvent(
                                    name,
                                    eventToObjectGenerator[name].apply(
                                        null,
                                        arguments
                                    )
                                )
                            } catch (e) {
                                async.throwLater(e)
                                domEventFired = true
                            }

                            return domEventFired || globalEventFired
                        }

                        Promise.config = function(opts) {
                            opts = Object(opts)
                            if ('longStackTraces' in opts) {
                                if (opts.longStackTraces) {
                                    Promise.longStackTraces()
                                } else if (
                                    !opts.longStackTraces &&
                                    Promise.hasLongStackTraces()
                                ) {
                                    disableLongStackTraces()
                                }
                            }
                            if ('warnings' in opts) {
                                const warningsOption = opts.warnings
                                config.warnings = !!warningsOption
                                wForgottenReturn = config.warnings

                                if (util.isObject(warningsOption)) {
                                    if ('wForgottenReturn' in warningsOption) {
                                        wForgottenReturn = !!warningsOption.wForgottenReturn
                                    }
                                }
                            }
                            if (
                                'cancellation' in opts &&
                                opts.cancellation &&
                                !config.cancellation
                            ) {
                                if (async.haveItemsQueued()) {
                                    throw new Error(
                                        'cannot enable cancellation after promises are in use'
                                    )
                                }
                                Promise.prototype._clearCancellationData = cancellationClearCancellationData
                                Promise.prototype._propagateFrom = cancellationPropagateFrom
                                Promise.prototype._onCancel = cancellationOnCancel
                                Promise.prototype._setOnCancel = cancellationSetOnCancel
                                Promise.prototype._attachCancellationCallback = cancellationAttachCancellationCallback
                                Promise.prototype._execute = cancellationExecute
                                propagateFromFunction = cancellationPropagateFrom
                                config.cancellation = true
                            }
                            if ('monitoring' in opts) {
                                if (opts.monitoring && !config.monitoring) {
                                    config.monitoring = true
                                    Promise.prototype._fireEvent = activeFireEvent
                                } else if (
                                    !opts.monitoring &&
                                    config.monitoring
                                ) {
                                    config.monitoring = false
                                    Promise.prototype._fireEvent = defaultFireEvent
                                }
                            }
                        }

                        function defaultFireEvent() {
                            return false
                        }

                        Promise.prototype._fireEvent = defaultFireEvent
                        Promise.prototype._execute = function(
                            executor,
                            resolve,
                            reject
                        ) {
                            try {
                                executor(resolve, reject)
                            } catch (e) {
                                return e
                            }
                        }
                        Promise.prototype._onCancel = function() {}
                        Promise.prototype._setOnCancel = function(handler) {}
                        Promise.prototype._attachCancellationCallback = function(
                            onCancel
                        ) {}
                        Promise.prototype._captureStackTrace = function() {}
                        Promise.prototype._attachExtraTrace = function() {}
                        Promise.prototype._clearCancellationData = function() {}
                        Promise.prototype._propagateFrom = function(
                            parent,
                            flags
                        ) {}

                        function cancellationExecute(
                            executor,
                            resolve,
                            reject
                        ) {
                            const promise = this
                            try {
                                executor(resolve, reject, function(onCancel) {
                                    if (typeof onCancel !== 'function') {
                                        throw new TypeError(
                                            'onCancel must be a function, got: ' +
                                                util.toString(onCancel)
                                        )
                                    }
                                    promise._attachCancellationCallback(
                                        onCancel
                                    )
                                })
                            } catch (e) {
                                return e
                            }
                        }

                        function cancellationAttachCancellationCallback(
                            onCancel
                        ) {
                            if (!this.isCancellable()) return this

                            const previousOnCancel = this._onCancel()
                            if (previousOnCancel !== undefined) {
                                if (util.isArray(previousOnCancel)) {
                                    previousOnCancel.push(onCancel)
                                } else {
                                    this._setOnCancel([
                                        previousOnCancel,
                                        onCancel
                                    ])
                                }
                            } else {
                                this._setOnCancel(onCancel)
                            }
                        }

                        function cancellationOnCancel() {
                            return this._onCancelField
                        }

                        function cancellationSetOnCancel(onCancel) {
                            this._onCancelField = onCancel
                        }

                        function cancellationClearCancellationData() {
                            this._cancellationParent = undefined
                            this._onCancelField = undefined
                        }

                        function cancellationPropagateFrom(parent, flags) {
                            if ((flags & 1) !== 0) {
                                this._cancellationParent = parent
                                let branchesRemainingToCancel =
                                    parent._branchesRemainingToCancel
                                if (branchesRemainingToCancel === undefined) {
                                    branchesRemainingToCancel = 0
                                }
                                parent._branchesRemainingToCancel =
                                    branchesRemainingToCancel + 1
                            }
                            if ((flags & 2) !== 0 && parent._isBound()) {
                                this._setBoundTo(parent._boundTo)
                            }
                        }

                        function bindingPropagateFrom(parent, flags) {
                            if ((flags & 2) !== 0 && parent._isBound()) {
                                this._setBoundTo(parent._boundTo)
                            }
                        }
                        var propagateFromFunction = bindingPropagateFrom

                        function boundValueFunction() {
                            const ret = this._boundTo
                            if (ret !== undefined) {
                                if (ret instanceof Promise) {
                                    if (ret.isFulfilled()) {
                                        return ret.value()
                                    } else {
                                        return undefined
                                    }
                                }
                            }
                            return ret
                        }

                        function longStackTracesCaptureStackTrace() {
                            this._trace = new CapturedTrace(this._peekContext())
                        }

                        function longStackTracesAttachExtraTrace(
                            error,
                            ignoreSelf
                        ) {
                            if (canAttachTrace(error)) {
                                let trace = this._trace
                                if (trace !== undefined) {
                                    if (ignoreSelf) trace = trace._parent
                                }
                                if (trace !== undefined) {
                                    trace.attachExtraTrace(error)
                                } else if (!error.__stackCleaned__) {
                                    const parsed = parseStackAndMessage(error)
                                    util.notEnumerableProp(
                                        error,
                                        'stack',
                                        parsed.message +
                                            '\n' +
                                            parsed.stack.join('\n')
                                    )
                                    util.notEnumerableProp(
                                        error,
                                        '__stackCleaned__',
                                        true
                                    )
                                }
                            }
                        }

                        function checkForgottenReturns(
                            returnValue,
                            promiseCreated,
                            name,
                            promise,
                            parent
                        ) {
                            if (
                                returnValue === undefined &&
                                promiseCreated !== null &&
                                wForgottenReturn
                            ) {
                                if (
                                    parent !== undefined &&
                                    parent._returnedNonUndefined()
                                )
                                    return
                                const bitField = promise._bitField
                                if ((bitField & 65535) === 0) return

                                if (name) name = name + ' '
                                const msg =
                                    'a promise was created in a ' +
                                    name +
                                    'handler but was not returned from it'
                                promise._warn(msg, true, promiseCreated)
                            }
                        }

                        function deprecated(name, replacement) {
                            let message =
                                name +
                                ' is deprecated and will be removed in a future version.'
                            if (replacement)
                                message += ' Use ' + replacement + ' instead.'
                            return warn(message)
                        }

                        function warn(message, shouldUseOwnTrace, promise) {
                            if (!config.warnings) return
                            const warning = new Warning(message)
                            let ctx
                            if (shouldUseOwnTrace) {
                                promise._attachExtraTrace(warning)
                            } else if (
                                config.longStackTraces &&
                                (ctx = Promise._peekContext())
                            ) {
                                ctx.attachExtraTrace(warning)
                            } else {
                                const parsed = parseStackAndMessage(warning)
                                warning.stack =
                                    parsed.message +
                                    '\n' +
                                    parsed.stack.join('\n')
                            }

                            if (!activeFireEvent('warning', warning)) {
                                formatAndLogError(warning, '', true)
                            }
                        }

                        function reconstructStack(message, stacks) {
                            for (var i = 0; i < stacks.length - 1; ++i) {
                                stacks[i].push('From previous event:')
                                stacks[i] = stacks[i].join('\n')
                            }
                            if (i < stacks.length) {
                                stacks[i] = stacks[i].join('\n')
                            }
                            return message + '\n' + stacks.join('\n')
                        }

                        function removeDuplicateOrEmptyJumps(stacks) {
                            for (let i = 0; i < stacks.length; ++i) {
                                if (
                                    stacks[i].length === 0 ||
                                    (i + 1 < stacks.length &&
                                        stacks[i][0] === stacks[i + 1][0])
                                ) {
                                    stacks.splice(i, 1)
                                    i--
                                }
                            }
                        }

                        function removeCommonRoots(stacks) {
                            let current = stacks[0]
                            for (let i = 1; i < stacks.length; ++i) {
                                const prev = stacks[i]
                                let currentLastIndex = current.length - 1
                                const currentLastLine =
                                    current[currentLastIndex]
                                let commonRootMeetPoint = -1

                                for (var j = prev.length - 1; j >= 0; --j) {
                                    if (prev[j] === currentLastLine) {
                                        commonRootMeetPoint = j
                                        break
                                    }
                                }

                                for (var j = commonRootMeetPoint; j >= 0; --j) {
                                    const line = prev[j]
                                    if (current[currentLastIndex] === line) {
                                        current.pop()
                                        currentLastIndex--
                                    } else {
                                        break
                                    }
                                }
                                current = prev
                            }
                        }

                        function cleanStack(stack) {
                            const ret = []
                            for (let i = 0; i < stack.length; ++i) {
                                let line = stack[i]
                                const isTraceLine =
                                    '    (No stack trace)' === line ||
                                    stackFramePattern.test(line)
                                const isInternalFrame =
                                    isTraceLine && shouldIgnore(line)
                                if (isTraceLine && !isInternalFrame) {
                                    if (
                                        indentStackFrames &&
                                        line.charAt(0) !== ' '
                                    ) {
                                        line = '    ' + line
                                    }
                                    ret.push(line)
                                }
                            }
                            return ret
                        }

                        function stackFramesAsArray(error) {
                            let stack = error.stack
                                .replace(/\s+$/g, '')
                                .split('\n')
                            for (var i = 0; i < stack.length; ++i) {
                                const line = stack[i]
                                if (
                                    '    (No stack trace)' === line ||
                                    stackFramePattern.test(line)
                                ) {
                                    break
                                }
                            }
                            if (i > 0) {
                                stack = stack.slice(i)
                            }
                            return stack
                        }

                        function parseStackAndMessage(error) {
                            let stack = error.stack
                            const message = error.toString()
                            stack =
                                typeof stack === 'string' && stack.length > 0
                                    ? stackFramesAsArray(error)
                                    : ['    (No stack trace)']
                            return {
                                message: message,
                                stack: cleanStack(stack)
                            }
                        }

                        function formatAndLogError(error, title, isSoft) {
                            if (typeof console !== 'undefined') {
                                let message
                                if (util.isObject(error)) {
                                    const stack = error.stack
                                    message = title + formatStack(stack, error)
                                } else {
                                    message = title + String(error)
                                }
                                if (typeof printWarning === 'function') {
                                    printWarning(message, isSoft)
                                } else if (
                                    typeof console.log === 'function' ||
                                    typeof console.log === 'object'
                                ) {
                                    console.log(message)
                                }
                            }
                        }

                        function fireRejectionEvent(
                            name,
                            localHandler,
                            reason,
                            promise
                        ) {
                            let localEventFired = false
                            try {
                                if (typeof localHandler === 'function') {
                                    localEventFired = true
                                    if (name === 'rejectionHandled') {
                                        localHandler(promise)
                                    } else {
                                        localHandler(reason, promise)
                                    }
                                }
                            } catch (e) {
                                async.throwLater(e)
                            }

                            if (name === 'unhandledRejection') {
                                if (
                                    !activeFireEvent(name, reason, promise) &&
                                    !localEventFired
                                ) {
                                    formatAndLogError(
                                        reason,
                                        'Unhandled rejection '
                                    )
                                }
                            } else {
                                activeFireEvent(name, promise)
                            }
                        }

                        function formatNonError(obj) {
                            let str
                            if (typeof obj === 'function') {
                                str =
                                    '[function ' +
                                    (obj.name || 'anonymous') +
                                    ']'
                            } else {
                                str =
                                    obj && typeof obj.toString === 'function'
                                        ? obj.toString()
                                        : util.toString(obj)
                                const ruselessToString = /\[object [a-zA-Z0-9$_]+\]/
                                if (ruselessToString.test(str)) {
                                    try {
                                        const newStr = JSON.stringify(obj)
                                        str = newStr
                                    } catch (e) {}
                                }
                                if (str.length === 0) {
                                    str = '(empty array)'
                                }
                            }
                            return '(<' + snip(str) + '>, no stack trace)'
                        }

                        function snip(str) {
                            const maxChars = 41
                            if (str.length < maxChars) {
                                return str
                            }
                            return str.substr(0, maxChars - 3) + '...'
                        }

                        function longStackTracesIsSupported() {
                            return typeof captureStackTrace === 'function'
                        }

                        var shouldIgnore = function() {
                            return false
                        }
                        const parseLineInfoRegex = /[\/<\(]([^:\/]+):(\d+):(?:\d+)\)?\s*$/
                        function parseLineInfo(line) {
                            const matches = line.match(parseLineInfoRegex)
                            if (matches) {
                                return {
                                    fileName: matches[1],
                                    line: parseInt(matches[2], 10)
                                }
                            }
                        }

                        function setBounds(firstLineError, lastLineError) {
                            if (!longStackTracesIsSupported()) return
                            const firstStackLines = firstLineError.stack.split(
                                '\n'
                            )
                            const lastStackLines = lastLineError.stack.split(
                                '\n'
                            )
                            let firstIndex = -1
                            let lastIndex = -1
                            let firstFileName
                            let lastFileName
                            for (var i = 0; i < firstStackLines.length; ++i) {
                                var result = parseLineInfo(firstStackLines[i])
                                if (result) {
                                    firstFileName = result.fileName
                                    firstIndex = result.line
                                    break
                                }
                            }
                            for (var i = 0; i < lastStackLines.length; ++i) {
                                var result = parseLineInfo(lastStackLines[i])
                                if (result) {
                                    lastFileName = result.fileName
                                    lastIndex = result.line
                                    break
                                }
                            }
                            if (
                                firstIndex < 0 ||
                                lastIndex < 0 ||
                                !firstFileName ||
                                !lastFileName ||
                                firstFileName !== lastFileName ||
                                firstIndex >= lastIndex
                            ) {
                                return
                            }

                            shouldIgnore = function(line) {
                                if (bluebirdFramePattern.test(line)) return true
                                const info = parseLineInfo(line)
                                if (info) {
                                    if (
                                        info.fileName === firstFileName &&
                                        firstIndex <= info.line &&
                                        info.line <= lastIndex
                                    ) {
                                        return true
                                    }
                                }
                                return false
                            }
                        }

                        function CapturedTrace(parent) {
                            this._parent = parent
                            this._promisesCreated = 0
                            const length = (this._length =
                                1 + (parent === undefined ? 0 : parent._length))
                            captureStackTrace(this, CapturedTrace)
                            if (length > 32) this.uncycle()
                        }
                        util.inherits(CapturedTrace, Error)
                        Context.CapturedTrace = CapturedTrace

                        CapturedTrace.prototype.uncycle = function() {
                            let length = this._length
                            if (length < 2) return
                            const nodes = []
                            const stackToIndex = {}

                            for (
                                var i = 0, node = this;
                                node !== undefined;
                                ++i
                            ) {
                                nodes.push(node)
                                node = node._parent
                            }
                            length = this._length = i
                            for (var i = length - 1; i >= 0; --i) {
                                const stack = nodes[i].stack
                                if (stackToIndex[stack] === undefined) {
                                    stackToIndex[stack] = i
                                }
                            }
                            for (var i = 0; i < length; ++i) {
                                const currentStack = nodes[i].stack
                                const index = stackToIndex[currentStack]
                                if (index !== undefined && index !== i) {
                                    if (index > 0) {
                                        nodes[index - 1]._parent = undefined
                                        nodes[index - 1]._length = 1
                                    }
                                    nodes[i]._parent = undefined
                                    nodes[i]._length = 1
                                    const cycleEdgeNode =
                                        i > 0 ? nodes[i - 1] : this

                                    if (index < length - 1) {
                                        cycleEdgeNode._parent = nodes[index + 1]
                                        cycleEdgeNode._parent.uncycle()
                                        cycleEdgeNode._length =
                                            cycleEdgeNode._parent._length + 1
                                    } else {
                                        cycleEdgeNode._parent = undefined
                                        cycleEdgeNode._length = 1
                                    }
                                    let currentChildLength =
                                        cycleEdgeNode._length + 1
                                    for (let j = i - 2; j >= 0; --j) {
                                        nodes[j]._length = currentChildLength
                                        currentChildLength++
                                    }
                                    return
                                }
                            }
                        }

                        CapturedTrace.prototype.attachExtraTrace = function(
                            error
                        ) {
                            if (error.__stackCleaned__) return
                            this.uncycle()
                            const parsed = parseStackAndMessage(error)
                            const message = parsed.message
                            const stacks = [parsed.stack]

                            let trace = this
                            while (trace !== undefined) {
                                stacks.push(cleanStack(trace.stack.split('\n')))
                                trace = trace._parent
                            }
                            removeCommonRoots(stacks)
                            removeDuplicateOrEmptyJumps(stacks)
                            util.notEnumerableProp(
                                error,
                                'stack',
                                reconstructStack(message, stacks)
                            )
                            util.notEnumerableProp(
                                error,
                                '__stackCleaned__',
                                true
                            )
                        }

                        var captureStackTrace = (function stackDetection() {
                            const v8stackFramePattern = /^\s*at\s*/
                            const v8stackFormatter = function(stack, error) {
                                if (typeof stack === 'string') return stack

                                if (
                                    error.name !== undefined &&
                                    error.message !== undefined
                                ) {
                                    return error.toString()
                                }
                                return formatNonError(error)
                            }

                            if (
                                typeof Error.stackTraceLimit === 'number' &&
                                typeof Error.captureStackTrace === 'function'
                            ) {
                                Error.stackTraceLimit += 6
                                stackFramePattern = v8stackFramePattern
                                formatStack = v8stackFormatter
                                const captureStackTrace =
                                    Error.captureStackTrace

                                shouldIgnore = function(line) {
                                    return bluebirdFramePattern.test(line)
                                }
                                return function(receiver, ignoreUntil) {
                                    Error.stackTraceLimit += 6
                                    captureStackTrace(receiver, ignoreUntil)
                                    Error.stackTraceLimit -= 6
                                }
                            }
                            const err = new Error()

                            if (
                                typeof err.stack === 'string' &&
                                err.stack
                                    .split('\n')[0]
                                    .indexOf('stackDetection@') >= 0
                            ) {
                                stackFramePattern = /@/
                                formatStack = v8stackFormatter
                                indentStackFrames = true
                                return function captureStackTrace(o) {
                                    o.stack = new Error().stack
                                }
                            }

                            let hasStackAfterThrow
                            try {
                                throw new Error()
                            } catch (e) {
                                hasStackAfterThrow = 'stack' in e
                            }
                            if (
                                !('stack' in err) &&
                                hasStackAfterThrow &&
                                typeof Error.stackTraceLimit === 'number'
                            ) {
                                stackFramePattern = v8stackFramePattern
                                formatStack = v8stackFormatter
                                return function captureStackTrace(o) {
                                    Error.stackTraceLimit += 6
                                    try {
                                        throw new Error()
                                    } catch (e) {
                                        o.stack = e.stack
                                    }
                                    Error.stackTraceLimit -= 6
                                }
                            }

                            formatStack = function(stack, error) {
                                if (typeof stack === 'string') return stack

                                if (
                                    (typeof error === 'object' ||
                                        typeof error === 'function') &&
                                    error.name !== undefined &&
                                    error.message !== undefined
                                ) {
                                    return error.toString()
                                }
                                return formatNonError(error)
                            }

                            return null
                        })([])

                        if (
                            typeof console !== 'undefined' &&
                            typeof console.warn !== 'undefined'
                        ) {
                            printWarning = function(message) {
                                console.warn(message)
                            }
                            if (util.isNode && process.stderr.isTTY) {
                                printWarning = function(message, isSoft) {
                                    const color = isSoft
                                        ? '\u001b[33m'
                                        : '\u001b[31m'
                                    console.warn(
                                        color + message + '\u001b[0m\n'
                                    )
                                }
                            } else if (
                                !util.isNode &&
                                typeof new Error().stack === 'string'
                            ) {
                                printWarning = function(message, isSoft) {
                                    console.warn(
                                        '%c' + message,
                                        isSoft
                                            ? 'color: darkorange'
                                            : 'color: red'
                                    )
                                }
                            }
                        }

                        var config = {
                            warnings: warnings,
                            longStackTraces: false,
                            cancellation: false,
                            monitoring: false
                        }

                        if (longStackTraces) Promise.longStackTraces()

                        return {
                            longStackTraces: function() {
                                return config.longStackTraces
                            },
                            warnings: function() {
                                return config.warnings
                            },
                            cancellation: function() {
                                return config.cancellation
                            },
                            monitoring: function() {
                                return config.monitoring
                            },
                            propagateFromFunction: function() {
                                return propagateFromFunction
                            },
                            boundValueFunction: function() {
                                return boundValueFunction
                            },
                            checkForgottenReturns: checkForgottenReturns,
                            setBounds: setBounds,
                            warn: warn,
                            deprecated: deprecated,
                            CapturedTrace: CapturedTrace,
                            fireDomEvent: fireDomEvent,
                            fireGlobalEvent: fireGlobalEvent
                        }
                    }
                },
                {'./errors': 9, './util': 21}
            ],
            8: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function(Promise) {
                        function returner() {
                            return this.value
                        }
                        function thrower() {
                            throw this.reason
                        }

                        Promise.prototype[
                            'return'
                        ] = Promise.prototype.thenReturn = function(value) {
                            if (value instanceof Promise)
                                value.suppressUnhandledRejections()
                            return this._then(
                                returner,
                                undefined,
                                undefined,
                                {value: value},
                                undefined
                            )
                        }

                        Promise.prototype[
                            'throw'
                        ] = Promise.prototype.thenThrow = function(reason) {
                            return this._then(
                                thrower,
                                undefined,
                                undefined,
                                {reason: reason},
                                undefined
                            )
                        }

                        Promise.prototype.catchThrow = function(reason) {
                            if (arguments.length <= 1) {
                                return this._then(
                                    undefined,
                                    thrower,
                                    undefined,
                                    {reason: reason},
                                    undefined
                                )
                            } else {
                                const _reason = arguments[1]
                                const handler = function() {
                                    throw _reason
                                }
                                return this.caught(reason, handler)
                            }
                        }

                        Promise.prototype.catchReturn = function(value) {
                            if (arguments.length <= 1) {
                                if (value instanceof Promise)
                                    value.suppressUnhandledRejections()
                                return this._then(
                                    undefined,
                                    returner,
                                    undefined,
                                    {value: value},
                                    undefined
                                )
                            } else {
                                const _value = arguments[1]
                                if (_value instanceof Promise)
                                    _value.suppressUnhandledRejections()
                                const handler = function() {
                                    return _value
                                }
                                return this.caught(value, handler)
                            }
                        }
                    }
                },
                {}
            ],
            9: [
                function(_dereq_, module, exports) {
                    'use strict'
                    const es5 = _dereq_('./es5')
                    const Objectfreeze = es5.freeze
                    const util = _dereq_('./util')
                    const inherits = util.inherits
                    const notEnumerableProp = util.notEnumerableProp

                    function subError(nameProperty, defaultMessage) {
                        function SubError(message) {
                            if (!(this instanceof SubError))
                                return new SubError(message)
                            notEnumerableProp(
                                this,
                                'message',
                                typeof message === 'string'
                                    ? message
                                    : defaultMessage
                            )
                            notEnumerableProp(this, 'name', nameProperty)
                            if (Error.captureStackTrace) {
                                Error.captureStackTrace(this, this.constructor)
                            } else {
                                Error.call(this)
                            }
                        }
                        inherits(SubError, Error)
                        return SubError
                    }

                    let _TypeError, _RangeError
                    const Warning = subError('Warning', 'warning')
                    const CancellationError = subError(
                        'CancellationError',
                        'cancellation error'
                    )
                    const TimeoutError = subError(
                        'TimeoutError',
                        'timeout error'
                    )
                    const AggregateError = subError(
                        'AggregateError',
                        'aggregate error'
                    )
                    try {
                        _TypeError = TypeError
                        _RangeError = RangeError
                    } catch (e) {
                        _TypeError = subError('TypeError', 'type error')
                        _RangeError = subError('RangeError', 'range error')
                    }

                    const methods = (
                        'join pop push shift unshift slice filter forEach some ' +
                        'every map indexOf lastIndexOf reduce reduceRight sort reverse'
                    ).split(' ')

                    for (let i = 0; i < methods.length; ++i) {
                        if (typeof Array.prototype[methods[i]] === 'function') {
                            AggregateError.prototype[methods[i]] =
                                Array.prototype[methods[i]]
                        }
                    }

                    es5.defineProperty(AggregateError.prototype, 'length', {
                        value: 0,
                        configurable: false,
                        writable: true,
                        enumerable: true
                    })
                    AggregateError.prototype['isOperational'] = true
                    let level = 0
                    AggregateError.prototype.toString = function() {
                        let indent = Array(level * 4 + 1).join(' ')
                        let ret = '\n' + indent + 'AggregateError of:' + '\n'
                        level++
                        indent = Array(level * 4 + 1).join(' ')
                        for (let i = 0; i < this.length; ++i) {
                            let str =
                                this[i] === this
                                    ? '[Circular AggregateError]'
                                    : this[i] + ''
                            const lines = str.split('\n')
                            for (let j = 0; j < lines.length; ++j) {
                                lines[j] = indent + lines[j]
                            }
                            str = lines.join('\n')
                            ret += str + '\n'
                        }
                        level--
                        return ret
                    }

                    function OperationalError(message) {
                        if (!(this instanceof OperationalError))
                            return new OperationalError(message)
                        notEnumerableProp(this, 'name', 'OperationalError')
                        notEnumerableProp(this, 'message', message)
                        this.cause = message
                        this['isOperational'] = true

                        if (message instanceof Error) {
                            notEnumerableProp(this, 'message', message.message)
                            notEnumerableProp(this, 'stack', message.stack)
                        } else if (Error.captureStackTrace) {
                            Error.captureStackTrace(this, this.constructor)
                        }
                    }
                    inherits(OperationalError, Error)

                    let errorTypes = Error['__BluebirdErrorTypes__']
                    if (!errorTypes) {
                        errorTypes = Objectfreeze({
                            CancellationError: CancellationError,
                            TimeoutError: TimeoutError,
                            OperationalError: OperationalError,
                            RejectionError: OperationalError,
                            AggregateError: AggregateError
                        })
                        es5.defineProperty(Error, '__BluebirdErrorTypes__', {
                            value: errorTypes,
                            writable: false,
                            enumerable: false,
                            configurable: false
                        })
                    }

                    module.exports = {
                        Error: Error,
                        TypeError: _TypeError,
                        RangeError: _RangeError,
                        CancellationError: errorTypes.CancellationError,
                        OperationalError: errorTypes.OperationalError,
                        TimeoutError: errorTypes.TimeoutError,
                        AggregateError: errorTypes.AggregateError,
                        Warning: Warning
                    }
                },
                {'./es5': 10, './util': 21}
            ],
            10: [
                function(_dereq_, module, exports) {
                    const isES5 = (function() {
                        'use strict'
                        return this === undefined
                    })()

                    if (isES5) {
                        module.exports = {
                            freeze: Object.freeze,
                            defineProperty: Object.defineProperty,
                            getDescriptor: Object.getOwnPropertyDescriptor,
                            keys: Object.keys,
                            names: Object.getOwnPropertyNames,
                            getPrototypeOf: Object.getPrototypeOf,
                            isArray: Array.isArray,
                            isES5: isES5,
                            propertyIsWritable: function(obj, prop) {
                                const descriptor = Object.getOwnPropertyDescriptor(
                                    obj,
                                    prop
                                )
                                return !!(
                                    !descriptor ||
                                    descriptor.writable ||
                                    descriptor.set
                                )
                            }
                        }
                    } else {
                        const has = {}.hasOwnProperty
                        const str = {}.toString
                        const proto = {}.constructor.prototype

                        const ObjectKeys = function(o) {
                            const ret = []
                            for (const key in o) {
                                if (has.call(o, key)) {
                                    ret.push(key)
                                }
                            }
                            return ret
                        }

                        const ObjectGetDescriptor = function(o, key) {
                            return {value: o[key]}
                        }

                        const ObjectDefineProperty = function(o, key, desc) {
                            o[key] = desc.value
                            return o
                        }

                        const ObjectFreeze = function(obj) {
                            return obj
                        }

                        const ObjectGetPrototypeOf = function(obj) {
                            try {
                                return Object(obj).constructor.prototype
                            } catch (e) {
                                return proto
                            }
                        }

                        const ArrayIsArray = function(obj) {
                            try {
                                return str.call(obj) === '[object Array]'
                            } catch (e) {
                                return false
                            }
                        }

                        module.exports = {
                            isArray: ArrayIsArray,
                            keys: ObjectKeys,
                            names: ObjectKeys,
                            defineProperty: ObjectDefineProperty,
                            getDescriptor: ObjectGetDescriptor,
                            freeze: ObjectFreeze,
                            getPrototypeOf: ObjectGetPrototypeOf,
                            isES5: isES5,
                            propertyIsWritable: function() {
                                return true
                            }
                        }
                    }
                },
                {}
            ],
            11: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function(Promise, tryConvertToPromise) {
                        const util = _dereq_('./util')
                        const CancellationError = Promise.CancellationError
                        const errorObj = util.errorObj

                        function PassThroughHandlerContext(
                            promise,
                            type,
                            handler
                        ) {
                            this.promise = promise
                            this.type = type
                            this.handler = handler
                            this.called = false
                            this.cancelPromise = null
                        }

                        PassThroughHandlerContext.prototype.isFinallyHandler = function() {
                            return this.type === 0
                        }

                        function FinallyHandlerCancelReaction(finallyHandler) {
                            this.finallyHandler = finallyHandler
                        }

                        FinallyHandlerCancelReaction.prototype._resultCancelled = function() {
                            checkCancel(this.finallyHandler)
                        }

                        function checkCancel(ctx, reason) {
                            if (ctx.cancelPromise != null) {
                                if (arguments.length > 1) {
                                    ctx.cancelPromise._reject(reason)
                                } else {
                                    ctx.cancelPromise._cancel()
                                }
                                ctx.cancelPromise = null
                                return true
                            }
                            return false
                        }

                        function succeed() {
                            return finallyHandler.call(
                                this,
                                this.promise._target()._settledValue()
                            )
                        }
                        function fail(reason) {
                            if (checkCancel(this, reason)) return
                            errorObj.e = reason
                            return errorObj
                        }
                        function finallyHandler(reasonOrValue) {
                            const promise = this.promise
                            const handler = this.handler

                            if (!this.called) {
                                this.called = true
                                const ret = this.isFinallyHandler()
                                    ? handler.call(promise._boundValue())
                                    : handler.call(
                                          promise._boundValue(),
                                          reasonOrValue
                                      )
                                if (ret !== undefined) {
                                    promise._setReturnedNonUndefined()
                                    const maybePromise = tryConvertToPromise(
                                        ret,
                                        promise
                                    )
                                    if (maybePromise instanceof Promise) {
                                        if (this.cancelPromise != null) {
                                            if (maybePromise.isCancelled()) {
                                                const reason = new CancellationError(
                                                    'late cancellation observer'
                                                )
                                                promise._attachExtraTrace(
                                                    reason
                                                )
                                                errorObj.e = reason
                                                return errorObj
                                            } else if (
                                                maybePromise.isPending()
                                            ) {
                                                maybePromise._attachCancellationCallback(
                                                    new FinallyHandlerCancelReaction(
                                                        this
                                                    )
                                                )
                                            }
                                        }
                                        return maybePromise._then(
                                            succeed,
                                            fail,
                                            undefined,
                                            this,
                                            undefined
                                        )
                                    }
                                }
                            }

                            if (promise.isRejected()) {
                                checkCancel(this)
                                errorObj.e = reasonOrValue
                                return errorObj
                            } else {
                                checkCancel(this)
                                return reasonOrValue
                            }
                        }

                        Promise.prototype._passThrough = function(
                            handler,
                            type,
                            success,
                            fail
                        ) {
                            if (typeof handler !== 'function')
                                return this.then()
                            return this._then(
                                success,
                                fail,
                                undefined,
                                new PassThroughHandlerContext(
                                    this,
                                    type,
                                    handler
                                ),
                                undefined
                            )
                        }

                        Promise.prototype.lastly = Promise.prototype[
                            'finally'
                        ] = function(handler) {
                            return this._passThrough(
                                handler,
                                0,
                                finallyHandler,
                                finallyHandler
                            )
                        }

                        Promise.prototype.tap = function(handler) {
                            return this._passThrough(handler, 1, finallyHandler)
                        }

                        return PassThroughHandlerContext
                    }
                },
                {'./util': 21}
            ],
            12: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function(
                        Promise,
                        PromiseArray,
                        tryConvertToPromise,
                        INTERNAL
                    ) {
                        const util = _dereq_('./util')
                        const canEvaluate = util.canEvaluate
                        const tryCatch = util.tryCatch
                        const errorObj = util.errorObj
                        let reject

                        if (!true) {
                            if (canEvaluate) {
                                const thenCallback = function(i) {
                                    return new Function(
                                        'value',
                                        'holder',
                                        "                             \n\
            'use strict';                                                    \n\
            holder.pIndex = value;                                           \n\
            holder.checkFulfillment(this);                                   \n\
            ".replace(
                                            /Index/g,
                                            i
                                        )
                                    )
                                }

                                const promiseSetter = function(i) {
                                    return new Function(
                                        'promise',
                                        'holder',
                                        "                           \n\
            'use strict';                                                    \n\
            holder.pIndex = promise;                                         \n\
            ".replace(
                                            /Index/g,
                                            i
                                        )
                                    )
                                }

                                const generateHolderClass = function(total) {
                                    const props = new Array(total)
                                    for (let i = 0; i < props.length; ++i) {
                                        props[i] = 'this.p' + (i + 1)
                                    }
                                    const assignment =
                                        props.join(' = ') + ' = null;'
                                    const cancellationCode =
                                        'var promise;\n' +
                                        props
                                            .map(function(prop) {
                                                return (
                                                    '                                                         \n\
                promise = ' +
                                                    prop +
                                                    ';                                      \n\
                if (promise instanceof Promise) {                            \n\
                    promise.cancel();                                        \n\
                }                                                            \n\
            '
                                                )
                                            })
                                            .join('\n')
                                    const passedArguments = props.join(', ')
                                    const name = 'Holder$' + total

                                    let code =
                                        "return function(tryCatch, errorObj, Promise) {           \n\
            'use strict';                                                    \n\
            function [TheName](fn) {                                         \n\
                [TheProperties]                                              \n\
                this.fn = fn;                                                \n\
                this.now = 0;                                                \n\
            }                                                                \n\
            [TheName].prototype.checkFulfillment = function(promise) {       \n\
                var now = ++this.now;                                        \n\
                if (now === [TheTotal]) {                                    \n\
                    promise._pushContext();                                  \n\
                    var callback = this.fn;                                  \n\
                    var ret = tryCatch(callback)([ThePassedArguments]);      \n\
                    promise._popContext();                                   \n\
                    if (ret === errorObj) {                                  \n\
                        promise._rejectCallback(ret.e, false);               \n\
                    } else {                                                 \n\
                        promise._resolveCallback(ret);                       \n\
                    }                                                        \n\
                }                                                            \n\
            };                                                               \n\
                                                                             \n\
            [TheName].prototype._resultCancelled = function() {              \n\
                [CancellationCode]                                           \n\
            };                                                               \n\
                                                                             \n\
            return [TheName];                                                \n\
        }(tryCatch, errorObj, Promise);                                      \n\
        "

                                    code = code
                                        .replace(/\[TheName\]/g, name)
                                        .replace(/\[TheTotal\]/g, total)
                                        .replace(
                                            /\[ThePassedArguments\]/g,
                                            passedArguments
                                        )
                                        .replace(
                                            /\[TheProperties\]/g,
                                            assignment
                                        )
                                        .replace(
                                            /\[CancellationCode\]/g,
                                            cancellationCode
                                        )

                                    return new Function(
                                        'tryCatch',
                                        'errorObj',
                                        'Promise',
                                        code
                                    )(tryCatch, errorObj, Promise)
                                }

                                var holderClasses = []
                                var thenCallbacks = []
                                var promiseSetters = []

                                for (let i = 0; i < 8; ++i) {
                                    holderClasses.push(
                                        generateHolderClass(i + 1)
                                    )
                                    thenCallbacks.push(thenCallback(i + 1))
                                    promiseSetters.push(promiseSetter(i + 1))
                                }

                                reject = function(reason) {
                                    this._reject(reason)
                                }
                            }
                        }

                        Promise.join = function() {
                            const last = arguments.length - 1
                            let fn
                            if (
                                last > 0 &&
                                typeof arguments[last] === 'function'
                            ) {
                                fn = arguments[last]
                                if (!true) {
                                    if (last <= 8 && canEvaluate) {
                                        var ret = new Promise(INTERNAL)
                                        ret._captureStackTrace()
                                        const HolderClass =
                                            holderClasses[last - 1]
                                        const holder = new HolderClass(fn)
                                        const callbacks = thenCallbacks

                                        for (let i = 0; i < last; ++i) {
                                            let maybePromise = tryConvertToPromise(
                                                arguments[i],
                                                ret
                                            )
                                            if (
                                                maybePromise instanceof Promise
                                            ) {
                                                maybePromise = maybePromise._target()
                                                const bitField =
                                                    maybePromise._bitField
                                                if (
                                                    (bitField & 50397184) ===
                                                    0
                                                ) {
                                                    maybePromise._then(
                                                        callbacks[i],
                                                        reject,
                                                        undefined,
                                                        ret,
                                                        holder
                                                    )
                                                    promiseSetters[i](
                                                        maybePromise,
                                                        holder
                                                    )
                                                } else if (
                                                    (bitField & 33554432) !==
                                                    0
                                                ) {
                                                    callbacks[i].call(
                                                        ret,
                                                        maybePromise._value(),
                                                        holder
                                                    )
                                                } else if (
                                                    (bitField & 16777216) !==
                                                    0
                                                ) {
                                                    ret._reject(
                                                        maybePromise._reason()
                                                    )
                                                } else {
                                                    ret._cancel()
                                                }
                                            } else {
                                                callbacks[i].call(
                                                    ret,
                                                    maybePromise,
                                                    holder
                                                )
                                            }
                                        }
                                        if (!ret._isFateSealed()) {
                                            ret._setAsyncGuaranteed()
                                            ret._setOnCancel(holder)
                                        }
                                        return ret
                                    }
                                }
                            }
                            const args = [].slice.call(arguments)
                            if (fn) args.pop()
                            var ret = new PromiseArray(args).promise()
                            return fn !== undefined ? ret.spread(fn) : ret
                        }
                    }
                },
                {'./util': 21}
            ],
            13: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function(
                        Promise,
                        INTERNAL,
                        tryConvertToPromise,
                        apiRejection,
                        debug
                    ) {
                        const util = _dereq_('./util')
                        const tryCatch = util.tryCatch

                        Promise.method = function(fn) {
                            if (typeof fn !== 'function') {
                                throw new Promise.TypeError(
                                    'expecting a function but got ' +
                                        util.classString(fn)
                                )
                            }
                            return function() {
                                const ret = new Promise(INTERNAL)
                                ret._captureStackTrace()
                                ret._pushContext()
                                const value = tryCatch(fn).apply(
                                    this,
                                    arguments
                                )
                                const promiseCreated = ret._popContext()
                                debug.checkForgottenReturns(
                                    value,
                                    promiseCreated,
                                    'Promise.method',
                                    ret
                                )
                                ret._resolveFromSyncValue(value)
                                return ret
                            }
                        }

                        Promise.attempt = Promise['try'] = function(fn) {
                            if (typeof fn !== 'function') {
                                return apiRejection(
                                    'expecting a function but got ' +
                                        util.classString(fn)
                                )
                            }
                            const ret = new Promise(INTERNAL)
                            ret._captureStackTrace()
                            ret._pushContext()
                            let value
                            if (arguments.length > 1) {
                                debug.deprecated(
                                    'calling Promise.try with more than 1 argument'
                                )
                                const arg = arguments[1]
                                const ctx = arguments[2]
                                value = util.isArray(arg)
                                    ? tryCatch(fn).apply(ctx, arg)
                                    : tryCatch(fn).call(ctx, arg)
                            } else {
                                value = tryCatch(fn)()
                            }
                            const promiseCreated = ret._popContext()
                            debug.checkForgottenReturns(
                                value,
                                promiseCreated,
                                'Promise.try',
                                ret
                            )
                            ret._resolveFromSyncValue(value)
                            return ret
                        }

                        Promise.prototype._resolveFromSyncValue = function(
                            value
                        ) {
                            if (value === util.errorObj) {
                                this._rejectCallback(value.e, false)
                            } else {
                                this._resolveCallback(value, true)
                            }
                        }
                    }
                },
                {'./util': 21}
            ],
            14: [
                function(_dereq_, module, exports) {
                    'use strict'
                    const util = _dereq_('./util')
                    const maybeWrapAsError = util.maybeWrapAsError
                    const errors = _dereq_('./errors')
                    const OperationalError = errors.OperationalError
                    const es5 = _dereq_('./es5')

                    function isUntypedError(obj) {
                        return (
                            obj instanceof Error &&
                            es5.getPrototypeOf(obj) === Error.prototype
                        )
                    }

                    const rErrorKey = /^(?:name|message|stack|cause)$/
                    function wrapAsOperationalError(obj) {
                        let ret
                        if (isUntypedError(obj)) {
                            ret = new OperationalError(obj)
                            ret.name = obj.name
                            ret.message = obj.message
                            ret.stack = obj.stack
                            const keys = es5.keys(obj)
                            for (let i = 0; i < keys.length; ++i) {
                                const key = keys[i]
                                if (!rErrorKey.test(key)) {
                                    ret[key] = obj[key]
                                }
                            }
                            return ret
                        }
                        util.markAsOriginatingFromRejection(obj)
                        return obj
                    }

                    function nodebackForPromise(promise, multiArgs) {
                        return function(err, value) {
                            if (promise === null) return
                            if (err) {
                                const wrapped = wrapAsOperationalError(
                                    maybeWrapAsError(err)
                                )
                                promise._attachExtraTrace(wrapped)
                                promise._reject(wrapped)
                            } else if (!multiArgs) {
                                promise._fulfill(value)
                            } else {
                                const args = [].slice.call(arguments, 1)
                                promise._fulfill(args)
                            }
                            promise = null
                        }
                    }

                    module.exports = nodebackForPromise
                },
                {'./errors': 9, './es5': 10, './util': 21}
            ],
            15: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function() {
                        const makeSelfResolutionError = function() {
                            return new TypeError(
                                'circular promise resolution chain\u000a\u000a    See http://goo.gl/MqrFmX\u000a'
                            )
                        }
                        const reflectHandler = function() {
                            return new Promise.PromiseInspection(this._target())
                        }
                        const apiRejection = function(msg) {
                            return Promise.reject(new TypeError(msg))
                        }
                        function Proxyable() {}
                        const UNDEFINED_BINDING = {}
                        const util = _dereq_('./util')

                        let getDomain
                        if (util.isNode) {
                            getDomain = function() {
                                let ret = process.domain
                                if (ret === undefined) ret = null
                                return ret
                            }
                        } else {
                            getDomain = function() {
                                return null
                            }
                        }
                        util.notEnumerableProp(Promise, '_getDomain', getDomain)

                        const es5 = _dereq_('./es5')
                        const Async = _dereq_('./async')
                        const async = new Async()
                        es5.defineProperty(Promise, '_async', {value: async})
                        const errors = _dereq_('./errors')
                        var TypeError = (Promise.TypeError = errors.TypeError)
                        Promise.RangeError = errors.RangeError
                        const CancellationError = (Promise.CancellationError =
                            errors.CancellationError)
                        Promise.TimeoutError = errors.TimeoutError
                        Promise.OperationalError = errors.OperationalError
                        Promise.RejectionError = errors.OperationalError
                        Promise.AggregateError = errors.AggregateError
                        const INTERNAL = function() {}
                        const APPLY = {}
                        const NEXT_FILTER = {}
                        const tryConvertToPromise = _dereq_('./thenables')(
                            Promise,
                            INTERNAL
                        )
                        const PromiseArray = _dereq_('./promise_array')(
                            Promise,
                            INTERNAL,
                            tryConvertToPromise,
                            apiRejection,
                            Proxyable
                        )
                        const Context = _dereq_('./context')(Promise)
                        /*jshint unused:false*/
                        const createContext = Context.create
                        const debug = _dereq_('./debuggability')(
                            Promise,
                            Context
                        )
                        const CapturedTrace = debug.CapturedTrace
                        const PassThroughHandlerContext = _dereq_('./finally')(
                            Promise,
                            tryConvertToPromise
                        )
                        const catchFilter = _dereq_('./catch_filter')(
                            NEXT_FILTER
                        )
                        const nodebackForPromise = _dereq_('./nodeback')
                        const errorObj = util.errorObj
                        const tryCatch = util.tryCatch
                        function check(self, executor) {
                            if (typeof executor !== 'function') {
                                throw new TypeError(
                                    'expecting a function but got ' +
                                        util.classString(executor)
                                )
                            }
                            if (self.constructor !== Promise) {
                                throw new TypeError(
                                    'the promise constructor cannot be invoked directly\u000a\u000a    See http://goo.gl/MqrFmX\u000a'
                                )
                            }
                        }

                        function Promise(executor) {
                            this._bitField = 0
                            this._fulfillmentHandler0 = undefined
                            this._rejectionHandler0 = undefined
                            this._promise0 = undefined
                            this._receiver0 = undefined
                            if (executor !== INTERNAL) {
                                check(this, executor)
                                this._resolveFromExecutor(executor)
                            }
                            this._promiseCreated()
                            this._fireEvent('promiseCreated', this)
                        }

                        Promise.prototype.toString = function() {
                            return '[object Promise]'
                        }

                        Promise.prototype.caught = Promise.prototype[
                            'catch'
                        ] = function(fn) {
                            const len = arguments.length
                            if (len > 1) {
                                let catchInstances = new Array(len - 1),
                                    j = 0,
                                    i
                                for (i = 0; i < len - 1; ++i) {
                                    const item = arguments[i]
                                    if (util.isObject(item)) {
                                        catchInstances[j++] = item
                                    } else {
                                        return apiRejection(
                                            'expecting an object but got ' +
                                                util.classString(item)
                                        )
                                    }
                                }
                                catchInstances.length = j
                                fn = arguments[i]
                                return this.then(
                                    undefined,
                                    catchFilter(catchInstances, fn, this)
                                )
                            }
                            return this.then(undefined, fn)
                        }

                        Promise.prototype.reflect = function() {
                            return this._then(
                                reflectHandler,
                                reflectHandler,
                                undefined,
                                this,
                                undefined
                            )
                        }

                        Promise.prototype.then = function(
                            didFulfill,
                            didReject
                        ) {
                            if (
                                debug.warnings() &&
                                arguments.length > 0 &&
                                typeof didFulfill !== 'function' &&
                                typeof didReject !== 'function'
                            ) {
                                let msg =
                                    '.then() only accepts functions but was passed: ' +
                                    util.classString(didFulfill)
                                if (arguments.length > 1) {
                                    msg += ', ' + util.classString(didReject)
                                }
                                this._warn(msg)
                            }
                            return this._then(
                                didFulfill,
                                didReject,
                                undefined,
                                undefined,
                                undefined
                            )
                        }

                        Promise.prototype.done = function(
                            didFulfill,
                            didReject
                        ) {
                            const promise = this._then(
                                didFulfill,
                                didReject,
                                undefined,
                                undefined,
                                undefined
                            )
                            promise._setIsFinal()
                        }

                        Promise.prototype.spread = function(fn) {
                            if (typeof fn !== 'function') {
                                return apiRejection(
                                    'expecting a function but got ' +
                                        util.classString(fn)
                                )
                            }
                            return this.all()._then(
                                fn,
                                undefined,
                                undefined,
                                APPLY,
                                undefined
                            )
                        }

                        Promise.prototype.toJSON = function() {
                            const ret = {
                                isFulfilled: false,
                                isRejected: false,
                                fulfillmentValue: undefined,
                                rejectionReason: undefined
                            }
                            if (this.isFulfilled()) {
                                ret.fulfillmentValue = this.value()
                                ret.isFulfilled = true
                            } else if (this.isRejected()) {
                                ret.rejectionReason = this.reason()
                                ret.isRejected = true
                            }
                            return ret
                        }

                        Promise.prototype.all = function() {
                            if (arguments.length > 0) {
                                this._warn(
                                    '.all() was passed arguments but it does not take any'
                                )
                            }
                            return new PromiseArray(this).promise()
                        }

                        Promise.prototype.error = function(fn) {
                            return this.caught(util.originatesFromRejection, fn)
                        }

                        Promise.is = function(val) {
                            return val instanceof Promise
                        }

                        Promise.fromNode = Promise.fromCallback = function(fn) {
                            const ret = new Promise(INTERNAL)
                            ret._captureStackTrace()
                            const multiArgs =
                                arguments.length > 1
                                    ? !!Object(arguments[1]).multiArgs
                                    : false
                            const result = tryCatch(fn)(
                                nodebackForPromise(ret, multiArgs)
                            )
                            if (result === errorObj) {
                                ret._rejectCallback(result.e, true)
                            }
                            if (!ret._isFateSealed()) ret._setAsyncGuaranteed()
                            return ret
                        }

                        Promise.all = function(promises) {
                            return new PromiseArray(promises).promise()
                        }

                        Promise.cast = function(obj) {
                            let ret = tryConvertToPromise(obj)
                            if (!(ret instanceof Promise)) {
                                ret = new Promise(INTERNAL)
                                ret._captureStackTrace()
                                ret._setFulfilled()
                                ret._rejectionHandler0 = obj
                            }
                            return ret
                        }

                        Promise.resolve = Promise.fulfilled = Promise.cast

                        Promise.reject = Promise.rejected = function(reason) {
                            const ret = new Promise(INTERNAL)
                            ret._captureStackTrace()
                            ret._rejectCallback(reason, true)
                            return ret
                        }

                        Promise.setScheduler = function(fn) {
                            if (typeof fn !== 'function') {
                                throw new TypeError(
                                    'expecting a function but got ' +
                                        util.classString(fn)
                                )
                            }
                            const prev = async._schedule
                            async._schedule = fn
                            return prev
                        }

                        Promise.prototype._then = function(
                            didFulfill,
                            didReject,
                            _,
                            receiver,
                            internalData
                        ) {
                            const haveInternalData = internalData !== undefined
                            const promise = haveInternalData
                                ? internalData
                                : new Promise(INTERNAL)
                            const target = this._target()
                            const bitField = target._bitField

                            if (!haveInternalData) {
                                promise._propagateFrom(this, 3)
                                promise._captureStackTrace()
                                if (
                                    receiver === undefined &&
                                    (this._bitField & 2097152) !== 0
                                ) {
                                    if (!((bitField & 50397184) === 0)) {
                                        receiver = this._boundValue()
                                    } else {
                                        receiver =
                                            target === this
                                                ? undefined
                                                : this._boundTo
                                    }
                                }
                                this._fireEvent('promiseChained', this, promise)
                            }

                            const domain = getDomain()
                            if (!((bitField & 50397184) === 0)) {
                                let handler,
                                    value,
                                    settler = target._settlePromiseCtx
                                if ((bitField & 33554432) !== 0) {
                                    value = target._rejectionHandler0
                                    handler = didFulfill
                                } else if ((bitField & 16777216) !== 0) {
                                    value = target._fulfillmentHandler0
                                    handler = didReject
                                    target._unsetRejectionIsUnhandled()
                                } else {
                                    settler =
                                        target._settlePromiseLateCancellationObserver
                                    value = new CancellationError(
                                        'late cancellation observer'
                                    )
                                    target._attachExtraTrace(value)
                                    handler = didReject
                                }

                                async.invoke(settler, target, {
                                    handler:
                                        domain === null
                                            ? handler
                                            : typeof handler === 'function' &&
                                              domain.bind(handler),
                                    promise: promise,
                                    receiver: receiver,
                                    value: value
                                })
                            } else {
                                target._addCallbacks(
                                    didFulfill,
                                    didReject,
                                    promise,
                                    receiver,
                                    domain
                                )
                            }

                            return promise
                        }

                        Promise.prototype._length = function() {
                            return this._bitField & 65535
                        }

                        Promise.prototype._isFateSealed = function() {
                            return (this._bitField & 117506048) !== 0
                        }

                        Promise.prototype._isFollowing = function() {
                            return (this._bitField & 67108864) === 67108864
                        }

                        Promise.prototype._setLength = function(len) {
                            this._bitField =
                                (this._bitField & -65536) | (len & 65535)
                        }

                        Promise.prototype._setFulfilled = function() {
                            this._bitField = this._bitField | 33554432
                            this._fireEvent('promiseFulfilled', this)
                        }

                        Promise.prototype._setRejected = function() {
                            this._bitField = this._bitField | 16777216
                            this._fireEvent('promiseRejected', this)
                        }

                        Promise.prototype._setFollowing = function() {
                            this._bitField = this._bitField | 67108864
                            this._fireEvent('promiseResolved', this)
                        }

                        Promise.prototype._setIsFinal = function() {
                            this._bitField = this._bitField | 4194304
                        }

                        Promise.prototype._isFinal = function() {
                            return (this._bitField & 4194304) > 0
                        }

                        Promise.prototype._unsetCancelled = function() {
                            this._bitField = this._bitField & ~65536
                        }

                        Promise.prototype._setCancelled = function() {
                            this._bitField = this._bitField | 65536
                            this._fireEvent('promiseCancelled', this)
                        }

                        Promise.prototype._setAsyncGuaranteed = function() {
                            this._bitField = this._bitField | 134217728
                        }

                        Promise.prototype._receiverAt = function(index) {
                            const ret =
                                index === 0
                                    ? this._receiver0
                                    : this[index * 4 - 4 + 3]
                            if (ret === UNDEFINED_BINDING) {
                                return undefined
                            } else if (ret === undefined && this._isBound()) {
                                return this._boundValue()
                            }
                            return ret
                        }

                        Promise.prototype._promiseAt = function(index) {
                            return this[index * 4 - 4 + 2]
                        }

                        Promise.prototype._fulfillmentHandlerAt = function(
                            index
                        ) {
                            return this[index * 4 - 4 + 0]
                        }

                        Promise.prototype._rejectionHandlerAt = function(
                            index
                        ) {
                            return this[index * 4 - 4 + 1]
                        }

                        Promise.prototype._boundValue = function() {}

                        Promise.prototype._migrateCallback0 = function(
                            follower
                        ) {
                            const bitField = follower._bitField
                            const fulfill = follower._fulfillmentHandler0
                            const reject = follower._rejectionHandler0
                            const promise = follower._promise0
                            let receiver = follower._receiverAt(0)
                            if (receiver === undefined)
                                receiver = UNDEFINED_BINDING
                            this._addCallbacks(
                                fulfill,
                                reject,
                                promise,
                                receiver,
                                null
                            )
                        }

                        Promise.prototype._migrateCallbackAt = function(
                            follower,
                            index
                        ) {
                            const fulfill = follower._fulfillmentHandlerAt(
                                index
                            )
                            const reject = follower._rejectionHandlerAt(index)
                            const promise = follower._promiseAt(index)
                            let receiver = follower._receiverAt(index)
                            if (receiver === undefined)
                                receiver = UNDEFINED_BINDING
                            this._addCallbacks(
                                fulfill,
                                reject,
                                promise,
                                receiver,
                                null
                            )
                        }

                        Promise.prototype._addCallbacks = function(
                            fulfill,
                            reject,
                            promise,
                            receiver,
                            domain
                        ) {
                            let index = this._length()

                            if (index >= 65535 - 4) {
                                index = 0
                                this._setLength(0)
                            }

                            if (index === 0) {
                                this._promise0 = promise
                                this._receiver0 = receiver
                                if (typeof fulfill === 'function') {
                                    this._fulfillmentHandler0 =
                                        domain === null
                                            ? fulfill
                                            : domain.bind(fulfill)
                                }
                                if (typeof reject === 'function') {
                                    this._rejectionHandler0 =
                                        domain === null
                                            ? reject
                                            : domain.bind(reject)
                                }
                            } else {
                                const base = index * 4 - 4
                                this[base + 2] = promise
                                this[base + 3] = receiver
                                if (typeof fulfill === 'function') {
                                    this[base + 0] =
                                        domain === null
                                            ? fulfill
                                            : domain.bind(fulfill)
                                }
                                if (typeof reject === 'function') {
                                    this[base + 1] =
                                        domain === null
                                            ? reject
                                            : domain.bind(reject)
                                }
                            }
                            this._setLength(index + 1)
                            return index
                        }

                        Promise.prototype._proxy = function(proxyable, arg) {
                            this._addCallbacks(
                                undefined,
                                undefined,
                                arg,
                                proxyable,
                                null
                            )
                        }

                        Promise.prototype._resolveCallback = function(
                            value,
                            shouldBind
                        ) {
                            if ((this._bitField & 117506048) !== 0) return
                            if (value === this)
                                return this._rejectCallback(
                                    makeSelfResolutionError(),
                                    false
                                )
                            const maybePromise = tryConvertToPromise(
                                value,
                                this
                            )
                            if (!(maybePromise instanceof Promise))
                                return this._fulfill(value)

                            if (shouldBind) this._propagateFrom(maybePromise, 2)

                            const promise = maybePromise._target()

                            if (promise === this) {
                                this._reject(makeSelfResolutionError())
                                return
                            }

                            const bitField = promise._bitField
                            if ((bitField & 50397184) === 0) {
                                const len = this._length()
                                if (len > 0) promise._migrateCallback0(this)
                                for (let i = 1; i < len; ++i) {
                                    promise._migrateCallbackAt(this, i)
                                }
                                this._setFollowing()
                                this._setLength(0)
                                this._setFollowee(promise)
                            } else if ((bitField & 33554432) !== 0) {
                                this._fulfill(promise._value())
                            } else if ((bitField & 16777216) !== 0) {
                                this._reject(promise._reason())
                            } else {
                                const reason = new CancellationError(
                                    'late cancellation observer'
                                )
                                promise._attachExtraTrace(reason)
                                this._reject(reason)
                            }
                        }

                        Promise.prototype._rejectCallback = function(
                            reason,
                            synchronous,
                            ignoreNonErrorWarnings
                        ) {
                            const trace = util.ensureErrorObject(reason)
                            const hasStack = trace === reason
                            if (
                                !hasStack &&
                                !ignoreNonErrorWarnings &&
                                debug.warnings()
                            ) {
                                const message =
                                    'a promise was rejected with a non-error: ' +
                                    util.classString(reason)
                                this._warn(message, true)
                            }
                            this._attachExtraTrace(
                                trace,
                                synchronous ? hasStack : false
                            )
                            this._reject(reason)
                        }

                        Promise.prototype._resolveFromExecutor = function(
                            executor
                        ) {
                            const promise = this
                            this._captureStackTrace()
                            this._pushContext()
                            let synchronous = true
                            const r = this._execute(
                                executor,
                                function(value) {
                                    promise._resolveCallback(value)
                                },
                                function(reason) {
                                    promise._rejectCallback(reason, synchronous)
                                }
                            )
                            synchronous = false
                            this._popContext()

                            if (r !== undefined) {
                                promise._rejectCallback(r, true)
                            }
                        }

                        Promise.prototype._settlePromiseFromHandler = function(
                            handler,
                            receiver,
                            value,
                            promise
                        ) {
                            let bitField = promise._bitField
                            if ((bitField & 65536) !== 0) return
                            promise._pushContext()
                            let x
                            if (receiver === APPLY) {
                                if (
                                    !value ||
                                    typeof value.length !== 'number'
                                ) {
                                    x = errorObj
                                    x.e = new TypeError(
                                        'cannot .spread() a non-array: ' +
                                            util.classString(value)
                                    )
                                } else {
                                    x = tryCatch(handler).apply(
                                        this._boundValue(),
                                        value
                                    )
                                }
                            } else {
                                x = tryCatch(handler).call(receiver, value)
                            }
                            const promiseCreated = promise._popContext()
                            bitField = promise._bitField
                            if ((bitField & 65536) !== 0) return

                            if (x === NEXT_FILTER) {
                                promise._reject(value)
                            } else if (x === errorObj) {
                                promise._rejectCallback(x.e, false)
                            } else {
                                debug.checkForgottenReturns(
                                    x,
                                    promiseCreated,
                                    '',
                                    promise,
                                    this
                                )
                                promise._resolveCallback(x)
                            }
                        }

                        Promise.prototype._target = function() {
                            let ret = this
                            while (ret._isFollowing()) ret = ret._followee()
                            return ret
                        }

                        Promise.prototype._followee = function() {
                            return this._rejectionHandler0
                        }

                        Promise.prototype._setFollowee = function(promise) {
                            this._rejectionHandler0 = promise
                        }

                        Promise.prototype._settlePromise = function(
                            promise,
                            handler,
                            receiver,
                            value
                        ) {
                            const isPromise = promise instanceof Promise
                            const bitField = this._bitField
                            const asyncGuaranteed = (bitField & 134217728) !== 0
                            if ((bitField & 65536) !== 0) {
                                if (isPromise) promise._invokeInternalOnCancel()

                                if (
                                    receiver instanceof
                                        PassThroughHandlerContext &&
                                    receiver.isFinallyHandler()
                                ) {
                                    receiver.cancelPromise = promise
                                    if (
                                        tryCatch(handler).call(
                                            receiver,
                                            value
                                        ) === errorObj
                                    ) {
                                        promise._reject(errorObj.e)
                                    }
                                } else if (handler === reflectHandler) {
                                    promise._fulfill(
                                        reflectHandler.call(receiver)
                                    )
                                } else if (receiver instanceof Proxyable) {
                                    receiver._promiseCancelled(promise)
                                } else if (
                                    isPromise ||
                                    promise instanceof PromiseArray
                                ) {
                                    promise._cancel()
                                } else {
                                    receiver.cancel()
                                }
                            } else if (typeof handler === 'function') {
                                if (!isPromise) {
                                    handler.call(receiver, value, promise)
                                } else {
                                    if (asyncGuaranteed)
                                        promise._setAsyncGuaranteed()
                                    this._settlePromiseFromHandler(
                                        handler,
                                        receiver,
                                        value,
                                        promise
                                    )
                                }
                            } else if (receiver instanceof Proxyable) {
                                if (!receiver._isResolved()) {
                                    if ((bitField & 33554432) !== 0) {
                                        receiver._promiseFulfilled(
                                            value,
                                            promise
                                        )
                                    } else {
                                        receiver._promiseRejected(
                                            value,
                                            promise
                                        )
                                    }
                                }
                            } else if (isPromise) {
                                if (asyncGuaranteed)
                                    promise._setAsyncGuaranteed()
                                if ((bitField & 33554432) !== 0) {
                                    promise._fulfill(value)
                                } else {
                                    promise._reject(value)
                                }
                            }
                        }

                        Promise.prototype._settlePromiseLateCancellationObserver = function(
                            ctx
                        ) {
                            const handler = ctx.handler
                            const promise = ctx.promise
                            const receiver = ctx.receiver
                            const value = ctx.value
                            if (typeof handler === 'function') {
                                if (!(promise instanceof Promise)) {
                                    handler.call(receiver, value, promise)
                                } else {
                                    this._settlePromiseFromHandler(
                                        handler,
                                        receiver,
                                        value,
                                        promise
                                    )
                                }
                            } else if (promise instanceof Promise) {
                                promise._reject(value)
                            }
                        }

                        Promise.prototype._settlePromiseCtx = function(ctx) {
                            this._settlePromise(
                                ctx.promise,
                                ctx.handler,
                                ctx.receiver,
                                ctx.value
                            )
                        }

                        Promise.prototype._settlePromise0 = function(
                            handler,
                            value,
                            bitField
                        ) {
                            const promise = this._promise0
                            const receiver = this._receiverAt(0)
                            this._promise0 = undefined
                            this._receiver0 = undefined
                            this._settlePromise(
                                promise,
                                handler,
                                receiver,
                                value
                            )
                        }

                        Promise.prototype._clearCallbackDataAtIndex = function(
                            index
                        ) {
                            const base = index * 4 - 4
                            this[base + 2] = this[base + 3] = this[
                                base + 0
                            ] = this[base + 1] = undefined
                        }

                        Promise.prototype._fulfill = function(value) {
                            const bitField = this._bitField
                            if ((bitField & 117506048) >>> 16) return
                            if (value === this) {
                                const err = makeSelfResolutionError()
                                this._attachExtraTrace(err)
                                return this._reject(err)
                            }
                            this._setFulfilled()
                            this._rejectionHandler0 = value

                            if ((bitField & 65535) > 0) {
                                if ((bitField & 134217728) !== 0) {
                                    this._settlePromises()
                                } else {
                                    async.settlePromises(this)
                                }
                            }
                        }

                        Promise.prototype._reject = function(reason) {
                            const bitField = this._bitField
                            if ((bitField & 117506048) >>> 16) return
                            this._setRejected()
                            this._fulfillmentHandler0 = reason

                            if (this._isFinal()) {
                                return async.fatalError(reason, util.isNode)
                            }

                            if ((bitField & 65535) > 0) {
                                async.settlePromises(this)
                            } else {
                                this._ensurePossibleRejectionHandled()
                            }
                        }

                        Promise.prototype._fulfillPromises = function(
                            len,
                            value
                        ) {
                            for (let i = 1; i < len; i++) {
                                const handler = this._fulfillmentHandlerAt(i)
                                const promise = this._promiseAt(i)
                                const receiver = this._receiverAt(i)
                                this._clearCallbackDataAtIndex(i)
                                this._settlePromise(
                                    promise,
                                    handler,
                                    receiver,
                                    value
                                )
                            }
                        }

                        Promise.prototype._rejectPromises = function(
                            len,
                            reason
                        ) {
                            for (let i = 1; i < len; i++) {
                                const handler = this._rejectionHandlerAt(i)
                                const promise = this._promiseAt(i)
                                const receiver = this._receiverAt(i)
                                this._clearCallbackDataAtIndex(i)
                                this._settlePromise(
                                    promise,
                                    handler,
                                    receiver,
                                    reason
                                )
                            }
                        }

                        Promise.prototype._settlePromises = function() {
                            const bitField = this._bitField
                            const len = bitField & 65535

                            if (len > 0) {
                                if ((bitField & 16842752) !== 0) {
                                    const reason = this._fulfillmentHandler0
                                    this._settlePromise0(
                                        this._rejectionHandler0,
                                        reason,
                                        bitField
                                    )
                                    this._rejectPromises(len, reason)
                                } else {
                                    const value = this._rejectionHandler0
                                    this._settlePromise0(
                                        this._fulfillmentHandler0,
                                        value,
                                        bitField
                                    )
                                    this._fulfillPromises(len, value)
                                }
                                this._setLength(0)
                            }
                            this._clearCancellationData()
                        }

                        Promise.prototype._settledValue = function() {
                            const bitField = this._bitField
                            if ((bitField & 33554432) !== 0) {
                                return this._rejectionHandler0
                            } else if ((bitField & 16777216) !== 0) {
                                return this._fulfillmentHandler0
                            }
                        }

                        function deferResolve(v) {
                            this.promise._resolveCallback(v)
                        }
                        function deferReject(v) {
                            this.promise._rejectCallback(v, false)
                        }

                        Promise.defer = Promise.pending = function() {
                            debug.deprecated('Promise.defer', 'new Promise')
                            const promise = new Promise(INTERNAL)
                            return {
                                promise: promise,
                                resolve: deferResolve,
                                reject: deferReject
                            }
                        }

                        util.notEnumerableProp(
                            Promise,
                            '_makeSelfResolutionError',
                            makeSelfResolutionError
                        )

                        _dereq_('./method')(
                            Promise,
                            INTERNAL,
                            tryConvertToPromise,
                            apiRejection,
                            debug
                        )
                        _dereq_('./bind')(
                            Promise,
                            INTERNAL,
                            tryConvertToPromise,
                            debug
                        )
                        _dereq_('./cancel')(
                            Promise,
                            PromiseArray,
                            apiRejection,
                            debug
                        )
                        _dereq_('./direct_resolve')(Promise)
                        _dereq_('./synchronous_inspection')(Promise)
                        _dereq_('./join')(
                            Promise,
                            PromiseArray,
                            tryConvertToPromise,
                            INTERNAL,
                            debug
                        )
                        Promise.Promise = Promise

                        util.toFastProperties(Promise)
                        util.toFastProperties(Promise.prototype)
                        function fillTypes(value) {
                            const p = new Promise(INTERNAL)
                            p._fulfillmentHandler0 = value
                            p._rejectionHandler0 = value
                            p._promise0 = value
                            p._receiver0 = value
                        }
                        // Complete slack tracking, opt out of field-type tracking and
                        // stabilize map
                        fillTypes({a: 1})
                        fillTypes({b: 2})
                        fillTypes({c: 3})
                        fillTypes(1)
                        fillTypes(function() {})
                        fillTypes(undefined)
                        fillTypes(false)
                        fillTypes(new Promise(INTERNAL))
                        debug.setBounds(
                            Async.firstLineError,
                            util.lastLineError
                        )
                        return Promise
                    }
                },
                {
                    './async': 1,
                    './bind': 2,
                    './cancel': 4,
                    './catch_filter': 5,
                    './context': 6,
                    './debuggability': 7,
                    './direct_resolve': 8,
                    './errors': 9,
                    './es5': 10,
                    './finally': 11,
                    './join': 12,
                    './method': 13,
                    './nodeback': 14,
                    './promise_array': 16,
                    './synchronous_inspection': 19,
                    './thenables': 20,
                    './util': 21
                }
            ],
            16: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function(
                        Promise,
                        INTERNAL,
                        tryConvertToPromise,
                        apiRejection,
                        Proxyable
                    ) {
                        const util = _dereq_('./util')
                        const isArray = util.isArray

                        function toResolutionValue(val) {
                            switch (val) {
                                case -2:
                                    return []
                                case -3:
                                    return {}
                            }
                        }

                        function PromiseArray(values) {
                            const promise = (this._promise = new Promise(
                                INTERNAL
                            ))
                            if (values instanceof Promise) {
                                promise._propagateFrom(values, 3)
                            }
                            promise._setOnCancel(this)
                            this._values = values
                            this._length = 0
                            this._totalResolved = 0
                            this._init(undefined, -2)
                        }
                        util.inherits(PromiseArray, Proxyable)

                        PromiseArray.prototype.length = function() {
                            return this._length
                        }

                        PromiseArray.prototype.promise = function() {
                            return this._promise
                        }

                        PromiseArray.prototype._init = function init(
                            _,
                            resolveValueIfEmpty
                        ) {
                            let values = tryConvertToPromise(
                                this._values,
                                this._promise
                            )
                            if (values instanceof Promise) {
                                values = values._target()
                                const bitField = values._bitField
                                this._values = values

                                if ((bitField & 50397184) === 0) {
                                    this._promise._setAsyncGuaranteed()
                                    return values._then(
                                        init,
                                        this._reject,
                                        undefined,
                                        this,
                                        resolveValueIfEmpty
                                    )
                                } else if ((bitField & 33554432) !== 0) {
                                    values = values._value()
                                } else if ((bitField & 16777216) !== 0) {
                                    return this._reject(values._reason())
                                } else {
                                    return this._cancel()
                                }
                            }
                            values = util.asArray(values)
                            if (values === null) {
                                const err = apiRejection(
                                    'expecting an array or an iterable object but got ' +
                                        util.classString(values)
                                ).reason()
                                this._promise._rejectCallback(err, false)
                                return
                            }

                            if (values.length === 0) {
                                if (resolveValueIfEmpty === -5) {
                                    this._resolveEmptyArray()
                                } else {
                                    this._resolve(
                                        toResolutionValue(resolveValueIfEmpty)
                                    )
                                }
                                return
                            }
                            this._iterate(values)
                        }

                        PromiseArray.prototype._iterate = function(values) {
                            const len = this.getActualLength(values.length)
                            this._length = len
                            this._values = this.shouldCopyValues()
                                ? new Array(len)
                                : this._values
                            const result = this._promise
                            let isResolved = false
                            let bitField = null
                            for (let i = 0; i < len; ++i) {
                                let maybePromise = tryConvertToPromise(
                                    values[i],
                                    result
                                )

                                if (maybePromise instanceof Promise) {
                                    maybePromise = maybePromise._target()
                                    bitField = maybePromise._bitField
                                } else {
                                    bitField = null
                                }

                                if (isResolved) {
                                    if (bitField !== null) {
                                        maybePromise.suppressUnhandledRejections()
                                    }
                                } else if (bitField !== null) {
                                    if ((bitField & 50397184) === 0) {
                                        maybePromise._proxy(this, i)
                                        this._values[i] = maybePromise
                                    } else if ((bitField & 33554432) !== 0) {
                                        isResolved = this._promiseFulfilled(
                                            maybePromise._value(),
                                            i
                                        )
                                    } else if ((bitField & 16777216) !== 0) {
                                        isResolved = this._promiseRejected(
                                            maybePromise._reason(),
                                            i
                                        )
                                    } else {
                                        isResolved = this._promiseCancelled(i)
                                    }
                                } else {
                                    isResolved = this._promiseFulfilled(
                                        maybePromise,
                                        i
                                    )
                                }
                            }
                            if (!isResolved) result._setAsyncGuaranteed()
                        }

                        PromiseArray.prototype._isResolved = function() {
                            return this._values === null
                        }

                        PromiseArray.prototype._resolve = function(value) {
                            this._values = null
                            this._promise._fulfill(value)
                        }

                        PromiseArray.prototype._cancel = function() {
                            if (
                                this._isResolved() ||
                                !this._promise.isCancellable()
                            )
                                return
                            this._values = null
                            this._promise._cancel()
                        }

                        PromiseArray.prototype._reject = function(reason) {
                            this._values = null
                            this._promise._rejectCallback(reason, false)
                        }

                        PromiseArray.prototype._promiseFulfilled = function(
                            value,
                            index
                        ) {
                            this._values[index] = value
                            const totalResolved = ++this._totalResolved
                            if (totalResolved >= this._length) {
                                this._resolve(this._values)
                                return true
                            }
                            return false
                        }

                        PromiseArray.prototype._promiseCancelled = function() {
                            this._cancel()
                            return true
                        }

                        PromiseArray.prototype._promiseRejected = function(
                            reason
                        ) {
                            this._totalResolved++
                            this._reject(reason)
                            return true
                        }

                        PromiseArray.prototype._resultCancelled = function() {
                            if (this._isResolved()) return
                            const values = this._values
                            this._cancel()
                            if (values instanceof Promise) {
                                values.cancel()
                            } else {
                                for (let i = 0; i < values.length; ++i) {
                                    if (values[i] instanceof Promise) {
                                        values[i].cancel()
                                    }
                                }
                            }
                        }

                        PromiseArray.prototype.shouldCopyValues = function() {
                            return true
                        }

                        PromiseArray.prototype.getActualLength = function(len) {
                            return len
                        }

                        return PromiseArray
                    }
                },
                {'./util': 21}
            ],
            17: [
                function(_dereq_, module, exports) {
                    'use strict'
                    function arrayMove(src, srcIndex, dst, dstIndex, len) {
                        for (let j = 0; j < len; ++j) {
                            dst[j + dstIndex] = src[j + srcIndex]
                            src[j + srcIndex] = void 0
                        }
                    }

                    function Queue(capacity) {
                        this._capacity = capacity
                        this._length = 0
                        this._front = 0
                    }

                    Queue.prototype._willBeOverCapacity = function(size) {
                        return this._capacity < size
                    }

                    Queue.prototype._pushOne = function(arg) {
                        const length = this.length()
                        this._checkCapacity(length + 1)
                        const i = (this._front + length) & (this._capacity - 1)
                        this[i] = arg
                        this._length = length + 1
                    }

                    Queue.prototype._unshiftOne = function(value) {
                        const capacity = this._capacity
                        this._checkCapacity(this.length() + 1)
                        const front = this._front
                        const i =
                            (((front - 1) & (capacity - 1)) ^ capacity) -
                            capacity
                        this[i] = value
                        this._front = i
                        this._length = this.length() + 1
                    }

                    Queue.prototype.unshift = function(fn, receiver, arg) {
                        this._unshiftOne(arg)
                        this._unshiftOne(receiver)
                        this._unshiftOne(fn)
                    }

                    Queue.prototype.push = function(fn, receiver, arg) {
                        const length = this.length() + 3
                        if (this._willBeOverCapacity(length)) {
                            this._pushOne(fn)
                            this._pushOne(receiver)
                            this._pushOne(arg)
                            return
                        }
                        const j = this._front + length - 3
                        this._checkCapacity(length)
                        const wrapMask = this._capacity - 1
                        this[(j + 0) & wrapMask] = fn
                        this[(j + 1) & wrapMask] = receiver
                        this[(j + 2) & wrapMask] = arg
                        this._length = length
                    }

                    Queue.prototype.shift = function() {
                        const front = this._front,
                            ret = this[front]

                        this[front] = undefined
                        this._front = (front + 1) & (this._capacity - 1)
                        this._length--
                        return ret
                    }

                    Queue.prototype.length = function() {
                        return this._length
                    }

                    Queue.prototype._checkCapacity = function(size) {
                        if (this._capacity < size) {
                            this._resizeTo(this._capacity << 1)
                        }
                    }

                    Queue.prototype._resizeTo = function(capacity) {
                        const oldCapacity = this._capacity
                        this._capacity = capacity
                        const front = this._front
                        const length = this._length
                        const moveItemsCount =
                            (front + length) & (oldCapacity - 1)
                        arrayMove(this, 0, this, oldCapacity, moveItemsCount)
                    }

                    module.exports = Queue
                },
                {}
            ],
            18: [
                function(_dereq_, module, exports) {
                    'use strict'
                    const util = _dereq_('./util')
                    let schedule
                    const noAsyncScheduler = function() {
                        throw new Error(
                            'No async scheduler available\u000a\u000a    See http://goo.gl/MqrFmX\u000a'
                        )
                    }
                    if (
                        util.isNode &&
                        typeof MutationObserver === 'undefined'
                    ) {
                        const GlobalSetImmediate = global.setImmediate
                        const ProcessNextTick = process.nextTick
                        schedule = util.isRecentNode
                            ? function(fn) {
                                  GlobalSetImmediate.call(global, fn)
                              }
                            : function(fn) {
                                  ProcessNextTick.call(process, fn)
                              }
                    } else if (
                        typeof MutationObserver !== 'undefined' &&
                        !(
                            typeof window !== 'undefined' &&
                            window.navigator &&
                            window.navigator.standalone
                        )
                    ) {
                        schedule = (function() {
                            const div = document.createElement('div')
                            const opts = {attributes: true}
                            let toggleScheduled = false
                            const div2 = document.createElement('div')
                            const o2 = new MutationObserver(function() {
                                div.classList.toggle('foo')
                                toggleScheduled = false
                            })
                            o2.observe(div2, opts)

                            const scheduleToggle = function() {
                                if (toggleScheduled) return
                                toggleScheduled = true
                                div2.classList.toggle('foo')
                            }

                            return function schedule(fn) {
                                var o = new MutationObserver(function() {
                                    o.disconnect()
                                    fn()
                                })
                                o.observe(div, opts)
                                scheduleToggle()
                            }
                        })()
                    } else if (typeof setImmediate !== 'undefined') {
                        schedule = function(fn) {
                            setImmediate(fn)
                        }
                    } else if (typeof setTimeout !== 'undefined') {
                        schedule = function(fn) {
                            setTimeout(fn, 0)
                        }
                    } else {
                        schedule = noAsyncScheduler
                    }
                    module.exports = schedule
                },
                {'./util': 21}
            ],
            19: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function(Promise) {
                        function PromiseInspection(promise) {
                            if (promise !== undefined) {
                                promise = promise._target()
                                this._bitField = promise._bitField
                                this._settledValueField = promise._isFateSealed()
                                    ? promise._settledValue()
                                    : undefined
                            } else {
                                this._bitField = 0
                                this._settledValueField = undefined
                            }
                        }

                        PromiseInspection.prototype._settledValue = function() {
                            return this._settledValueField
                        }

                        const value = (PromiseInspection.prototype.value = function() {
                            if (!this.isFulfilled()) {
                                throw new TypeError(
                                    'cannot get fulfillment value of a non-fulfilled promise\u000a\u000a    See http://goo.gl/MqrFmX\u000a'
                                )
                            }
                            return this._settledValue()
                        })

                        const reason = (PromiseInspection.prototype.error = PromiseInspection.prototype.reason = function() {
                            if (!this.isRejected()) {
                                throw new TypeError(
                                    'cannot get rejection reason of a non-rejected promise\u000a\u000a    See http://goo.gl/MqrFmX\u000a'
                                )
                            }
                            return this._settledValue()
                        })

                        const isFulfilled = (PromiseInspection.prototype.isFulfilled = function() {
                            return (this._bitField & 33554432) !== 0
                        })

                        const isRejected = (PromiseInspection.prototype.isRejected = function() {
                            return (this._bitField & 16777216) !== 0
                        })

                        const isPending = (PromiseInspection.prototype.isPending = function() {
                            return (this._bitField & 50397184) === 0
                        })

                        const isResolved = (PromiseInspection.prototype.isResolved = function() {
                            return (this._bitField & 50331648) !== 0
                        })

                        PromiseInspection.prototype.isCancelled = Promise.prototype._isCancelled = function() {
                            return (this._bitField & 65536) === 65536
                        }

                        Promise.prototype.isCancelled = function() {
                            return this._target()._isCancelled()
                        }

                        Promise.prototype.isPending = function() {
                            return isPending.call(this._target())
                        }

                        Promise.prototype.isRejected = function() {
                            return isRejected.call(this._target())
                        }

                        Promise.prototype.isFulfilled = function() {
                            return isFulfilled.call(this._target())
                        }

                        Promise.prototype.isResolved = function() {
                            return isResolved.call(this._target())
                        }

                        Promise.prototype.value = function() {
                            return value.call(this._target())
                        }

                        Promise.prototype.reason = function() {
                            const target = this._target()
                            target._unsetRejectionIsUnhandled()
                            return reason.call(target)
                        }

                        Promise.prototype._value = function() {
                            return this._settledValue()
                        }

                        Promise.prototype._reason = function() {
                            this._unsetRejectionIsUnhandled()
                            return this._settledValue()
                        }

                        Promise.PromiseInspection = PromiseInspection
                    }
                },
                {}
            ],
            20: [
                function(_dereq_, module, exports) {
                    'use strict'
                    module.exports = function(Promise, INTERNAL) {
                        const util = _dereq_('./util')
                        const errorObj = util.errorObj
                        const isObject = util.isObject

                        function tryConvertToPromise(obj, context) {
                            if (isObject(obj)) {
                                if (obj instanceof Promise) return obj
                                const then = getThen(obj)
                                if (then === errorObj) {
                                    if (context) context._pushContext()
                                    var ret = Promise.reject(then.e)
                                    if (context) context._popContext()
                                    return ret
                                } else if (typeof then === 'function') {
                                    if (isAnyBluebirdPromise(obj)) {
                                        var ret = new Promise(INTERNAL)
                                        obj._then(
                                            ret._fulfill,
                                            ret._reject,
                                            undefined,
                                            ret,
                                            null
                                        )
                                        return ret
                                    }
                                    return doThenable(obj, then, context)
                                }
                            }
                            return obj
                        }

                        function doGetThen(obj) {
                            return obj.then
                        }

                        function getThen(obj) {
                            try {
                                return doGetThen(obj)
                            } catch (e) {
                                errorObj.e = e
                                return errorObj
                            }
                        }

                        const hasProp = {}.hasOwnProperty
                        function isAnyBluebirdPromise(obj) {
                            return hasProp.call(obj, '_promise0')
                        }

                        function doThenable(x, then, context) {
                            let promise = new Promise(INTERNAL)
                            const ret = promise
                            if (context) context._pushContext()
                            promise._captureStackTrace()
                            if (context) context._popContext()
                            let synchronous = true
                            const result = util
                                .tryCatch(then)
                                .call(x, resolve, reject)
                            synchronous = false

                            if (promise && result === errorObj) {
                                promise._rejectCallback(result.e, true, true)
                                promise = null
                            }

                            function resolve(value) {
                                if (!promise) return
                                promise._resolveCallback(value)
                                promise = null
                            }

                            function reject(reason) {
                                if (!promise) return
                                promise._rejectCallback(
                                    reason,
                                    synchronous,
                                    true
                                )
                                promise = null
                            }
                            return ret
                        }

                        return tryConvertToPromise
                    }
                },
                {'./util': 21}
            ],
            21: [
                function(_dereq_, module, exports) {
                    'use strict'
                    const es5 = _dereq_('./es5')
                    const canEvaluate = typeof navigator == 'undefined'

                    const errorObj = {e: {}}
                    let tryCatchTarget
                    const globalObject =
                        typeof self !== 'undefined'
                            ? self
                            : typeof window !== 'undefined'
                            ? window
                            : typeof global !== 'undefined'
                            ? global
                            : this !== undefined
                            ? this
                            : null

                    function tryCatcher() {
                        try {
                            const target = tryCatchTarget
                            tryCatchTarget = null
                            return target.apply(this, arguments)
                        } catch (e) {
                            errorObj.e = e
                            return errorObj
                        }
                    }
                    function tryCatch(fn) {
                        tryCatchTarget = fn
                        return tryCatcher
                    }

                    const inherits = function(Child, Parent) {
                        const hasProp = {}.hasOwnProperty

                        function T() {
                            this.constructor = Child
                            this.constructor$ = Parent
                            for (const propertyName in Parent.prototype) {
                                if (
                                    hasProp.call(
                                        Parent.prototype,
                                        propertyName
                                    ) &&
                                    propertyName.charAt(
                                        propertyName.length - 1
                                    ) !== '$'
                                ) {
                                    this[propertyName + '$'] =
                                        Parent.prototype[propertyName]
                                }
                            }
                        }
                        T.prototype = Parent.prototype
                        Child.prototype = new T()
                        return Child.prototype
                    }

                    function isPrimitive(val) {
                        return (
                            val == null ||
                            val === true ||
                            val === false ||
                            typeof val === 'string' ||
                            typeof val === 'number'
                        )
                    }

                    function isObject(value) {
                        return (
                            typeof value === 'function' ||
                            (typeof value === 'object' && value !== null)
                        )
                    }

                    function maybeWrapAsError(maybeError) {
                        if (!isPrimitive(maybeError)) return maybeError

                        return new Error(safeToString(maybeError))
                    }

                    function withAppended(target, appendee) {
                        const len = target.length
                        const ret = new Array(len + 1)
                        let i
                        for (i = 0; i < len; ++i) {
                            ret[i] = target[i]
                        }
                        ret[i] = appendee
                        return ret
                    }

                    function getDataPropertyOrDefault(obj, key, defaultValue) {
                        if (es5.isES5) {
                            const desc = Object.getOwnPropertyDescriptor(
                                obj,
                                key
                            )

                            if (desc != null) {
                                return desc.get == null && desc.set == null
                                    ? desc.value
                                    : defaultValue
                            }
                        } else {
                            return {}.hasOwnProperty.call(obj, key)
                                ? obj[key]
                                : undefined
                        }
                    }

                    function notEnumerableProp(obj, name, value) {
                        if (isPrimitive(obj)) return obj
                        const descriptor = {
                            value: value,
                            configurable: true,
                            enumerable: false,
                            writable: true
                        }
                        es5.defineProperty(obj, name, descriptor)
                        return obj
                    }

                    function thrower(r) {
                        throw r
                    }

                    const inheritedDataKeys = (function() {
                        const excludedPrototypes = [
                            Array.prototype,
                            Object.prototype,
                            Function.prototype
                        ]

                        const isExcludedProto = function(val) {
                            for (
                                let i = 0;
                                i < excludedPrototypes.length;
                                ++i
                            ) {
                                if (excludedPrototypes[i] === val) {
                                    return true
                                }
                            }
                            return false
                        }

                        if (es5.isES5) {
                            const getKeys = Object.getOwnPropertyNames
                            return function(obj) {
                                const ret = []
                                const visitedKeys = Object.create(null)
                                while (obj != null && !isExcludedProto(obj)) {
                                    var keys
                                    try {
                                        keys = getKeys(obj)
                                    } catch (e) {
                                        return ret
                                    }
                                    for (let i = 0; i < keys.length; ++i) {
                                        const key = keys[i]
                                        if (visitedKeys[key]) continue
                                        visitedKeys[key] = true
                                        const desc = Object.getOwnPropertyDescriptor(
                                            obj,
                                            key
                                        )
                                        if (
                                            desc != null &&
                                            desc.get == null &&
                                            desc.set == null
                                        ) {
                                            ret.push(key)
                                        }
                                    }
                                    obj = es5.getPrototypeOf(obj)
                                }
                                return ret
                            }
                        } else {
                            const hasProp = {}.hasOwnProperty
                            return function(obj) {
                                if (isExcludedProto(obj)) return []
                                const ret = []

                                /*jshint forin:false */
                                enumeration: for (const key in obj) {
                                    if (hasProp.call(obj, key)) {
                                        ret.push(key)
                                    } else {
                                        for (
                                            let i = 0;
                                            i < excludedPrototypes.length;
                                            ++i
                                        ) {
                                            if (
                                                hasProp.call(
                                                    excludedPrototypes[i],
                                                    key
                                                )
                                            ) {
                                                continue enumeration
                                            }
                                        }
                                        ret.push(key)
                                    }
                                }
                                return ret
                            }
                        }
                    })()

                    const thisAssignmentPattern = /this\s*\.\s*\S+\s*=/
                    function isClass(fn) {
                        try {
                            if (typeof fn === 'function') {
                                const keys = es5.names(fn.prototype)

                                const hasMethods = es5.isES5 && keys.length > 1
                                const hasMethodsOtherThanConstructor =
                                    keys.length > 0 &&
                                    !(
                                        keys.length === 1 &&
                                        keys[0] === 'constructor'
                                    )
                                const hasThisAssignmentAndStaticMethods =
                                    thisAssignmentPattern.test(fn + '') &&
                                    es5.names(fn).length > 0

                                if (
                                    hasMethods ||
                                    hasMethodsOtherThanConstructor ||
                                    hasThisAssignmentAndStaticMethods
                                ) {
                                    return true
                                }
                            }
                            return false
                        } catch (e) {
                            return false
                        }
                    }

                    function toFastProperties(obj) {
                        /*jshint -W027,-W055,-W031*/
                        function FakeConstructor() {}
                        FakeConstructor.prototype = obj
                        let l = 8
                        while (l--) new FakeConstructor()
                        return obj
                    }

                    const rident = /^[a-z$_][a-z$_0-9]*$/i
                    function isIdentifier(str) {
                        return rident.test(str)
                    }

                    function filledRange(count, prefix, suffix) {
                        const ret = new Array(count)
                        for (let i = 0; i < count; ++i) {
                            ret[i] = prefix + i + suffix
                        }
                        return ret
                    }

                    function safeToString(obj) {
                        try {
                            return obj + ''
                        } catch (e) {
                            return '[no string representation]'
                        }
                    }

                    function isError(obj) {
                        return (
                            obj !== null &&
                            typeof obj === 'object' &&
                            typeof obj.message === 'string' &&
                            typeof obj.name === 'string'
                        )
                    }

                    function markAsOriginatingFromRejection(e) {
                        try {
                            notEnumerableProp(e, 'isOperational', true)
                        } catch (ignore) {}
                    }

                    function originatesFromRejection(e) {
                        if (e == null) return false
                        return (
                            e instanceof
                                Error['__BluebirdErrorTypes__']
                                    .OperationalError ||
                            e['isOperational'] === true
                        )
                    }

                    function canAttachTrace(obj) {
                        return (
                            isError(obj) && es5.propertyIsWritable(obj, 'stack')
                        )
                    }

                    const ensureErrorObject = (function() {
                        if (!('stack' in new Error())) {
                            return function(value) {
                                if (canAttachTrace(value)) return value
                                try {
                                    throw new Error(safeToString(value))
                                } catch (err) {
                                    return err
                                }
                            }
                        } else {
                            return function(value) {
                                if (canAttachTrace(value)) return value
                                return new Error(safeToString(value))
                            }
                        }
                    })()

                    function classString(obj) {
                        return {}.toString.call(obj)
                    }

                    function copyDescriptors(from, to, filter) {
                        const keys = es5.names(from)
                        for (let i = 0; i < keys.length; ++i) {
                            const key = keys[i]
                            if (filter(key)) {
                                try {
                                    es5.defineProperty(
                                        to,
                                        key,
                                        es5.getDescriptor(from, key)
                                    )
                                } catch (ignore) {}
                            }
                        }
                    }

                    let asArray = function(v) {
                        if (es5.isArray(v)) {
                            return v
                        }
                        return null
                    }

                    if (typeof Symbol !== 'undefined' && Symbol.iterator) {
                        const ArrayFrom =
                            typeof Array.from === 'function'
                                ? function(v) {
                                      return Array.from(v)
                                  }
                                : function(v) {
                                      const ret = []
                                      const it = v[Symbol.iterator]()
                                      let itResult
                                      while (!(itResult = it.next()).done) {
                                          ret.push(itResult.value)
                                      }
                                      return ret
                                  }

                        asArray = function(v) {
                            if (es5.isArray(v)) {
                                return v
                            } else if (
                                v != null &&
                                typeof v[Symbol.iterator] === 'function'
                            ) {
                                return ArrayFrom(v)
                            }
                            return null
                        }
                    }

                    const isNode =
                        typeof process !== 'undefined' &&
                        classString(process).toLowerCase() ===
                            '[object process]'

                    function env(key, def) {
                        return isNode ? process.env[key] : def
                    }

                    const ret = {
                        isClass: isClass,
                        isIdentifier: isIdentifier,
                        inheritedDataKeys: inheritedDataKeys,
                        getDataPropertyOrDefault: getDataPropertyOrDefault,
                        thrower: thrower,
                        isArray: es5.isArray,
                        asArray: asArray,
                        notEnumerableProp: notEnumerableProp,
                        isPrimitive: isPrimitive,
                        isObject: isObject,
                        isError: isError,
                        canEvaluate: canEvaluate,
                        errorObj: errorObj,
                        tryCatch: tryCatch,
                        inherits: inherits,
                        withAppended: withAppended,
                        maybeWrapAsError: maybeWrapAsError,
                        toFastProperties: toFastProperties,
                        filledRange: filledRange,
                        toString: safeToString,
                        canAttachTrace: canAttachTrace,
                        ensureErrorObject: ensureErrorObject,
                        originatesFromRejection: originatesFromRejection,
                        markAsOriginatingFromRejection: markAsOriginatingFromRejection,
                        classString: classString,
                        copyDescriptors: copyDescriptors,
                        hasDevTools:
                            typeof chrome !== 'undefined' &&
                            chrome &&
                            typeof chrome.loadTimes === 'function',
                        isNode: isNode,
                        env: env,
                        global: globalObject
                    }
                    ret.isRecentNode =
                        ret.isNode &&
                        (function() {
                            const version = process.versions.node
                                .split('.')
                                .map(Number)
                            return (
                                (version[0] === 0 && version[1] > 10) ||
                                version[0] > 0
                            )
                        })()

                    if (ret.isNode) ret.toFastProperties(process)

                    try {
                        throw new Error()
                    } catch (e) {
                        ret.lastLineError = e
                    }
                    module.exports = ret
                },
                {'./es5': 10}
            ]
        },
        {},
        [3]
    )(3)
})
if (typeof window !== 'undefined' && window !== null) {
    window.P = window.Promise
} else if (typeof self !== 'undefined' && self !== null) {
    self.P = self.Promise
}
