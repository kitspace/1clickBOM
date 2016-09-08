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

import { RetailerInterface } from './retailer_interface';
import http from './http';
import { browser } from './browser';

class Mouser extends RetailerInterface {
    constructor(country_code, settings) {
        super('Mouser', country_code, 'data/mouser.json', settings);
        //posting our sub-domain as the sites are all linked and switching
        //countries would not register properly otherwise
        let split = this.site.split('.');
        let s = split[0].slice(3);
        if (s === 'www') {
           s = split[split.length - 1];
       }
        if (s === 'uk') {
            s = 'gb';
        }
        http.post(`http://www2.mouser.com/api/Preferences/SetSubdomain?subdomainName=${s}`
            , ""
            , {notify:false}
            , (function() {}), (function() {}));
    }
    addLines(lines, callback) {
        if (lines.length === 0) {
            callback({success: true, fails: []});
            return;
        }
        let count = 0;
        let big_result = {success:true, fails:[]};
        return this._get_cart_viewstate(viewstate => {
            return this._clear_errors(viewstate, () => {
                return this._get_adding_viewstate(viewstate => {
                    return (() => {
                        let result = [];
                        for (let i = 0; i < lines.length; i += 99) {
                            let _ = lines[i];
                            let _99_lines = lines.slice(i, i+98 + 1);
                            count += 1;
                            result.push(this._add_lines(_99_lines, viewstate, result => {
                                if (big_result.success) { big_result.success = result.success; }
                                big_result.fails = big_result.fails.concat(result.fails);
                                count -= 1;
                                if (count <= 0) {
                                    callback(big_result, this, lines);
                                    return this.refreshCartTabs();
                                }
                            }
                            ));
                        }
                        return result;
                    })();
                }
                );
            }
            );
        }
        );
    }
    _add_lines(lines, viewstate, callback) {
        let params = this.addline_params + viewstate;
        params += '&ctl00$ContentMain$hNumberOfLines=99';
        params += '&ctl00$ContentMain$txtNumberOfLines=94';
        for (let i = 0; i < lines.length; i++) {
            let line = lines[i];
            params += `&ctl00$ContentMain$txtCustomerPartNumber${i+1}=${line.reference}\
                       &ctl00$ContentMain$txtPartNumber${i+1}=${line.part}\
                       &ctl00$ContentMain$txtQuantity${i+1}=}${line.quantity}`;
        }
        let url = `http${this.site}${this.addline}`;
        let result = {success: true, fails:[]};
        return http.post(url, params, {}, event => {
            //if there is an error, there will be some error-class lines with display set to ''
            let doc = browser.parseDOM(event.target.responseText);
            let errors = doc.getElementsByClassName('error');
            for (let j = 0; j < errors.length; j++) {
                let error = errors[j];
                if (error.style.display === '') {
                    // this padding5 error element just started appearing, doesn't indicate anything
                    if (!((error.firstChild != null) && (error.firstChild.nextSibling != null) && error.firstChild.nextSibling.className === 'padding5')) {
                        let part = error.getAttribute('data-partnumber');
                        if (part != null) {
                            for (let k = 0; k < lines.length; k++) {
                                let line = lines[k];
                                if (line.part === part.replace(/-/g, '')) {
                                    result.fails.push(line);
                                }
                            }
                            result.success = false;
                        }
                    }
                }
            }
            if (callback != null) {
                return callback(result);
            }
        }
        , function() {
            if (callback != null) {
                return callback({success:false, fails:lines});
            }
        }
        );
    }

    _clear_errors(viewstate, callback) {
        return http.post(`http${this.site}${this.cart}`, `__EVENTARGUMENT=&__EVENTTARGET=\
            &__SCROLLPOSITIONX=&__SCROLLPOSITIONY=&__VIEWSTATE=${viewstate}\
            &__VIEWSTATEENCRYPTED=&ctl00$ctl00$ContentMain$btn3=Errors`
        , {}, event => {
            let doc = browser.parseDOM(event.target.responseText);
            viewstate = encodeURIComponent(__guard__(doc.getElementById('__VIEWSTATE'), x => x.value));
            return http.post(`http${this.site}${this.cart}`, `__EVENTARGUMENT=&__EVENTTARGET=\
                &__SCROLLPOSITIONX=&__SCROLLPOSITIONY=&__VIEWSTATE=${viewstate}\
                &__VIEWSTATEENCRYPTED=&ctl00$ContentMain$btn7=Update Basket`
            , {}, event => {
               if (callback != null) {
                   return callback();
               }
           }
            );
        }
        );
    }

    clearCart(callback) {
        return this._get_cart_viewstate(viewstate => {
            return this._clear_cart(viewstate, callback);
        }
        );
    }
    _clear_cart(viewstate, callback){
        //don't ask, this is what works...
        let url = `http${this.site}${this.cart}`;
        let params =  `__EVENTARGUMENT=&__EVENTTARGET=&__SCROLLPOSITIONX=\
            &__SCROLLPOSITIONY=&__VIEWSTATE=${viewstate}\
            &__VIEWSTATEENCRYPTED=&ctl00$ContentMain$btn7=Update Basket`;
        return http.post(url, params, {}, event => {
            if (callback != null) {
                callback({success:true}, this);
            }
            return this.refreshCartTabs();
        }
        , () => {
            if (callback != null) {
                return callback({success:false}, this);
            }
        }
        );
    }
    _get_adding_viewstate(callback, arg){
        //we get the quick-add form, extend it to 99 lines (the max) and get
        //the viewstate from the response
        let url = `http${this.site}${this.addline}`;
        return http.get(url, {}, event => {
            let doc = browser.parseDOM(event.target.responseText);
            let params = this.addline_params;
            params += encodeURIComponent(doc.getElementById('__VIEWSTATE').value);
            params += '&ctl00$ContentMain$btnAddLines=Lines to Forms';
            params += '&ctl00$ContentMain$hNumberOfLines=5';
            params += '&ctl00$ContentMain$txtNumberOfLines=94';
            return http.post(url, params, {}, event => {
                doc = browser.parseDOM(event.target.responseText);
                let viewstate = encodeURIComponent(doc.getElementById('__VIEWSTATE').value);
                if (callback != null) {
                    return callback(viewstate, arg);
                }
            }
            );
        }
        );
    }
    _get_cart_viewstate(callback){
        let url = `http${this.site}${this.cart}`;
        return http.get(url, {}, event => {
            let doc = browser.parseDOM(event.target.responseText);
            let viewstate = encodeURIComponent(__guard__(doc.getElementById('__VIEWSTATE'), x => x.value));
            if (callback != null) {
                return callback(viewstate);
            }
        }
        );
    }
}

export { Mouser };

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}
