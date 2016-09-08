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

import { parseTSV, writeTSV } from '1-click-bom';

import http from './http';
import { browser } from './browser';
import { badge } from './badge';

export function tsvPageNotifier(sendState, bom_manager) {
    return {
        onDotTSV : false,
        re       : new RegExp('((\.tsv$)|(^https?://.*?\.?kitnic.it/boards/)|(https?://127.0.0.1:8080/boards/))','i'),
        lines    : [],
        invalid  : [],
        _set_not_dotTSV() {
            badge.setDefault('');
            this.onDotTSV = false;
            this.lines    = [];
            this.invalid  = [];
            return sendState();
        },
        checkPage(callback) {
            return browser.tabsGetActive(tab => {
                if (tab != null) {
                    let tab_url = tab.url.split('?')[0];
                    if (tab_url.match(this.re)) {
                        if (/^https?:\/\/.*?\.?kitnic.it\/boards\//.test(tab.url)) {
                            var url = tab_url + '/1-click-BOM.tsv';
                        } else if (/^https?:\/\/127.0.0.1:8080\/boards\//.test(tab.url)) {
                            var url = tab_url + '/1-click-BOM.tsv';
                        } else if (/^https?:\/\/github.com\//.test(tab.url)) {
                            var url = tab_url.replace(/blob/,'raw');
                        } else if (/^https?:\/\/bitbucket.org\//.test(tab.url)) {
                            var url = tab_url.split('?')[0].replace(/src/,'raw');
                        } else {
                            var url = tab_url;
                        }
                        http.get(url, {notify:false}, event => {
                            let {lines, invalid} = parseTSV(event.target.responseText);
                            if (lines.length > 0) {
                                badge.setDefault('\u2191', '#0000FF');
                                this.onDotTSV = true;
                                this.lines    = lines;
                                this.invalid  = invalid;
                                return sendState();
                            } else {
                                return this._set_not_dotTSV();
                            }
                        }
                        , () => {
                            return this._set_not_dotTSV();
                        }
                        );
                    } else {
                        this._set_not_dotTSV();
                    }
                    if (callback != null) {
                        return callback();
                    }
                } else if (callback != null) {
                    return callback();
                }
            }
            );
        },
        addToBOM(callback) {
            return this.checkPage(() => {
                if (this.onDotTSV) {
                    return bom_manager._add_to_bom(this.lines, this.invalid, callback);
                }
            }
            );
        },
        quickAddToCart(input) {
            if (typeof input === 'string') {
                var retailer = input;
                var multiplier = 1;
            } else {
                var { retailer } = input;
                var { multiplier } = input;
            }
            return this.checkPage(() => {
                if (this.onDotTSV) {
                    let parts = bom_manager._to_retailers(this.lines)[retailer];
                    parts = parts.map(function(line) {
                        line.quantity = Math.ceil(line.quantity * multiplier);
                        return line;
                    });
                    bom_manager.interfaces[retailer].adding_lines = true;
                    let timeout_id = browser.setTimeout((function(retailer) {
                        bom_manager.interfaces[retailer].adding_lines = false;
                        return sendState();
                    }).bind(null, retailer)
                    , 180000);
                    return bom_manager.interfaces[retailer].addLines(parts,
                        (function(timeout_id, retailer, result) {
                            browser.clearTimeout(timeout_id);
                            bom_manager.interfaces[retailer].adding_lines = false;
                            sendState();
                            bom_manager.interfaces[retailer].openCartTab();
                            return bom_manager.notifyFillCart(parts
                            , retailer, result);
                        }).bind(null, timeout_id, retailer)
                    );
                }
            }
            );
        }

    };
}
