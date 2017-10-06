// The contents of this file are subject to the Common Public Attribution
// License Version 1.0 (the “License”); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
// License Version 1.1 but Sections 14 and 15 have been added to cover use of
// software over a computer network and provide for limited attribution for the
// Original Developer. In addition, Exhibit A has been modified to be consistent
// with Exhibit B.
//
// Software distributed under the License is distributed on an
// "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
// the License for the specific language governing rights and limitations under
// the License.
//
// The Original Code is 1clickBOM.
//
// The Original Developer is the Initial Developer. The Original Developer of
// the Original Code is Kaspar Emanuel.

//this is the messenger object used by the background in firefox

const bgMessenger = (popup, message_exchange) => ({
    on(msgName, callback) {
        popup.port.on(msgName, callback)
        return message_exchange.adders.push(
            ((msgName, callback, worker) =>
                worker.port.on(msgName, callback)).bind(null, msgName, callback)
        )
    },
    send(msgName, input) {
        popup.port.emit(msgName, input)
        return message_exchange.receivers.map(worker =>
            worker.port.emit(msgName, input)
        )
    }
})

exports.bgMessenger = bgMessenger
