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

const { RetailerInterface } = require('./retailer_interface');
const { browser } = require('./browser');
const http = require('./http');

class Newark extends RetailerInterface {
    constructor(country_code, settings,callback) {
        super('Newark', country_code, 'data/newark.json', settings);
        this._set_store_id(() => {
            return callback(this);
        }
        );
    }

    clearCart(callback) {
        return this._get_item_ids(ids => {
            return this._clear_cart(ids, obj => {
                this.refreshCartTabs();
                this.refreshSiteTabs();
                if (callback != null) {
                    return callback(obj);
                }
            }
            );
        }
        );
    }

    _set_store_id(callback) {
        let url = `https${this.site}${this.cart}`;
        return http.get(url, {}, event => {
            let doc = browser.parseDOM(event.target.responseText);
            let id_elem = doc.getElementById('storeId');
            if (id_elem != null) {
                this.store_id = id_elem.value;
                return callback();
            }
        }
        , () => callback()
        );
    }


    _clear_cart(ids, callback) {
        let url = `https${this.site}/webapp/wcs/stores/servlet/ProcessBasket`;
        let params = `langId=-1&orderId=&catalogId=15003&BASE_URL=BasketPage&errorViewName=AjaxOrderItemDisplayView&storeId=${this.store_id}&URL=BasketDataAjaxResponse&isEmpty=false&LoginTimeout=&LoginTimeoutURL=&blankLinesResponse=10&orderItemDeleteAll=`;
        for (let i = 0; i < ids.length; i++) {
            let id = ids[i];
            params += `&orderItemDelete=${id}`;
        }
        return http.post(url, params, {}, event => {
            return callback({success:true}, this);
        }
        , () => {
            //we actually successfully clear the cart on 404s
            return callback({success:true}, this);
        }
        );
    }

    _get_item_ids(callback) {
        let url = `https${this.site}${this.cart}`;
        return http.get(url, {}, event => {
            let doc = browser.parseDOM(event.target.responseText);
            let order_details = doc.querySelector('#order_details');
            if (order_details != null) {
                let tbody = order_details.querySelector('tbody');
                var inputs = tbody.querySelectorAll('input');
            } else {
                var inputs = [];
            }
            let ids = [];
            for (let i = 0; i < inputs.length; i++) {
                let input = inputs[i];
                if (input.type === 'hidden' && /orderItem_/.test(input.id)) {
                    ids.push(input.value);
                }
            }
            return callback(ids);
        }
        );
    }

    addLines(lines, callback) {
        if (lines.length === 0) {
            callback({success: true, fails: []});
            return;
        }
        return this._add_lines(lines, result => {
            this.refreshCartTabs();
            this.refreshSiteTabs();
            return callback(result, this, lines);
        }
        );
    }

    _add_lines(lines, callback) {
        let url = `https${this.site}/AjaxPasteOrderChangeServiceItemAdd`;
        return http.get(url, {notify:false}, () => {
            return this._add_lines_ajax(lines, callback);
        }
        , () => {
            return this._add_lines_non_ajax(lines, callback);
        }
        );
    }

    _add_lines_non_ajax(lines, callback) {
        if (lines.length === 0) {
            if (callback != null) {
                callback({success:true, fails:[]});
            }
            return;
        }
        let url = `https${this.site}/webapp/wcs/stores/servlet/PasteOrderChangeServiceItemAdd`;
        let params = `storeId=${this.store_id}&catalogId=&langId=-1&omItemAdd=quickPaste&URL=AjaxOrderItemDisplayView%3FstoreId%3D10194%26catalogId%3D15003%26langId%3D-1%26quickPaste%3D*&errorViewName=QuickOrderView&calculationUsage=-1%2C-2%2C-3%2C-4%2C-5%2C-6%2C-7&isQuickPaste=true&quickPaste=`;
        //&addToBasket=Add+to+Cart'
        for (let i = 0; i < lines.length; i++) {
            let line = lines[i];
            params += encodeURIComponent(line.part) + ',';
            params += encodeURIComponent(line.quantity) + ',';
            params += encodeURIComponent(line.reference) + '\n';
        }
        return http.post(url, params, {}, event => {
            let doc = browser.parseDOM(event.target.responseText);
            let form_errors = doc.querySelector('#formErrors');
            let success = true;
            if (form_errors != null) {
                success = form_errors.className !== '';
            }
            if (!success) {
                //we find out which parts are the problem, call addLines again
                //on the rest and concatenate the fails to the new result
                //returning everything together to our callback
                let fail_names  = [];
                let fails       = [];
                let retry_lines = [];
                for (let j = 0; j < lines.length; j++) {
                    var line = lines[j];
                    let regex = new RegExp(line.part, 'g');
                    let result = regex.exec(form_errors.innerHTML);
                    if (result !== null) {
                        fail_names.push(result[0]);
                    }
                }
                for (let k = 0; k < lines.length; k++) {
                    var line = lines[k];
                    if (__in__(line.part, fail_names)) {
                        fails.push(line);
                    } else {
                        retry_lines.push(line);
                    }
                }
                return this._add_lines_non_ajax(retry_lines, function(result) {
                    if (callback != null) {
                        result.fails = result.fails.concat(fails);
                        result.success = false;
                        return callback(result);
                    }
                }
                );
            } else { //success
                if (callback != null) {
                    return callback({success: true, fails:[]});
                }
            }
        }
        , () => {
            if (callback != null) {
                return callback({success:false,fails:lines});
            }
        }
        );
    }


    _add_lines_ajax(lines, callback) {
        let result = {success: true, fails:[], warnings:[]};
        if (lines.length === 0) {
            if (callback != null) {
                callback({success:true, fails:[]});
            }
            return;
        }
        let url = `https${this.site}/AjaxPasteOrderChangeServiceItemAdd`;

        let params = `storeId=${this.store_id}&catalogId=&langId=-1&omItemAdd=quickPaste&URL=AjaxOrderItemDisplayView%3FstoreId%3D10194%26catalogId%3D15003%26langId%3D-1%26quickPaste%3D*&errorViewName=QuickOrderView&calculationUsage=-1%2C-2%2C-3%2C-4%2C-5%2C-6%2C-7&isQuickPaste=true&quickPaste=`;
        for (let i = 0; i < lines.length; i++) {
            let line = lines[i];
            params += encodeURIComponent(line.part) + ',';
            params += encodeURIComponent(line.quantity) + ',';
            if (line.reference.length > 30) {
                result.warnings.push(`Truncated line-note when adding
                    ${this.name} line to cart: ${line.reference}`);
            }
            params += encodeURIComponent(line.reference.substr(0,30)) + '\n';
        }
        return http.post(url, params, {}, event => {
            let stxt = event.target.responseText.split('\n');
            let stxt2 = stxt.slice(3 ,  (stxt.length - 4) + 1);
            let stxt3 = '';
            for (let j = 0; j < stxt2.length; j++) {
                let s = stxt2[j];
                stxt3 += s;
            }
            let json = JSON.parse(stxt3);
            if ((json.hasPartNumberErrors != null) || (json.hasCommentErrors != null)) {
                //we find out which parts are the problem, call addLines again
                //on the rest and concatenate the fails to the new result
                //returning everything together to our callback
                let fail_names  = [];
                let fails       = [];
                let retry_lines = [];
                for (let k in json) {
                    //the rest of the json lines are the part numbers
                    let v = json[k];
                    if (k !== 'hasPartNumberErrors' && k !== 'hasCommentErrors') {
                        fail_names.push(v[0]);
                    }
                }
                for (let i1 = 0; i1 < lines.length; i1++) {
                    let line = lines[i1];
                    if (__in__(line.part, fail_names)) {
                        fails.push(line);
                    } else {
                        retry_lines.push(line);
                    }
                }
                return this._add_lines_ajax(retry_lines, function(result) {
                    if (callback != null) {
                        result.fails = result.fails.concat(fails);
                        result.success = false;
                        return callback(result);
                    }
                }
                );
            } else { //success
                if (callback != null) {
                    return callback(result);
                }
            }
        }
        , () => {
            if (callback != null) {
                return callback({success:false,fails:lines,warnings:result.warnings});
            }
        }
        );
    }
}

exports.Newark = Newark;

function __in__(needle, haystack) {
  return haystack.indexOf(needle) >= 0;
}
