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

const messenger = {
    msgNames: [],
    listening: false,
    on(msgName, callback) {
        this.msgNames.push({msgName, callback})
        if (!this.listening) {
            chrome.runtime.onMessage.addListener(
                (request, sender, sendResponse) => {
                    for (let i = 0; i < this.msgNames.length; i++) {
                        const {msgName, callback} = this.msgNames[i]
                        if (request.name === msgName) {
                            return callback(request.value, sendResponse)
                        }
                    }
                }
            )
            return (this.listening = true)
        }
    },
    send(msgName, input = null) {
        chrome.runtime.sendMessage({
            name: msgName,
            value: JSON.parse(JSON.stringify(input))
        })
        if (chrome.tabs != null) {
            return chrome.tabs.query(
                {
                    url: [
                        '*://kitspace.org/*',
                        '*://*.kitspace.org/*',
                        '*://kitspace.dev/*',
                        '*://*.kitspace.dev/*',
                        '*://kitspace.test/*',
                        '*://*.kitspace.test/*'
                    ]
                },
                tabs =>
                    tabs.map(tab =>
                        chrome.tabs.sendMessage(tab.id, {
                            name: msgName,
                            value: JSON.parse(JSON.stringify(input))
                        })
                    )
            )
        }
    }
}

exports.messenger = messenger
