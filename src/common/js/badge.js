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

const { browser } = require('./browser')

const badge = {
    decaying_set  : false,
    priority      : 0,
    default_text  : '',
    default_color : '#0000FF',
    setDecaying(text, color = '#0000FF', priority = 1) {
        if (priority >= this.priority) {
            if (this.decaying_set && this.id > 0) {
                browser.clearTimeout(this.id)
            }
            this._set(text, color, priority)
            return this.id = browser.setTimeout(() => {
                this.decaying_set = false
                return this._set(this.default_text, this.default_color, 0)
            }
            , 5000)
        }
    },
    setDefault(text, color = '#0000FF', priority = 0) {
        if (priority >= this.priority) {
            this._set(text, color, priority)
        }
        this.default_color = color
        return this.default_text = text
    },
    _set(text, color, priority) {
        browser.setBadge({color, text})
        return this.priority = priority
    }
}

exports.badge = badge
