# The contents of this file are subject to the Common Public Attribution
# License Version 1.0 (the “License”); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
# License Version 1.1 but Sections 14 and 15 have been added to cover use of
# software over a computer network and provide for limited attribution for the
# Original Developer. In addition, Exhibit A has been modified to be consistent
# with Exhibit B.
#
# Software distributed under the License is distributed on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations under
# the License.
#
# The Original Code is 1clickBOM.
#
# The Original Developer is the Initial Developer. The Original Developer of
# the Original Code is Kaspar Emanuel.

window.messenger = {
    send:(msgName, value, callback) ->
        if callback?
            fn = (@msgName, @callback) ->
                    @listener = (request) =>
                        if request.out? && request.out[0] == @msgName
                            @callback(request.out[1])
                            chrome.runtime.onMessage.removeListener(@listener)
                    chrome.runtime.onMessage.addListener(@listener)
            new fn(msgName, callback)
        chrome.runtime.sendMessage {in:[msgName,value]}
    on:(msgName, callback) ->
        fn = (@msgName, @callback) ->
            chrome.runtime.onMessage.addListener (request) =>
                if request.in? && request.in[0] == @msgName
                    @callback request.in[1], (value) =>
                        chrome.runtime.sendMessage({out:[@msgName,value]})
        new fn(msgName, callback)
}
