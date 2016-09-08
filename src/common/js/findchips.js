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
let n;
let time_period_ms;
import Promise from './bluebird';
Promise.config({cancellation:true});

import rateLimit from './promise-rate-limit';

import http from './http';

let aliases = {
    'Digi-Key'           : 'Digikey',
    'RS Components'      : 'RS',
    'Mouser Electronics' : 'Mouser',
    'Farnell element14'  : 'Farnell',
    'Newark element14'   : 'Newark'
};

let _search = function(query, retailers_to_search = [], other_fields = []) {
    if (!query || query === '') {
        return Promise.resolve({retailers:{}, partNumbers:[]});
    }
    let url = `http://www.findchips.com/lite/${encodeURIComponent(query)}`;
    let p = http.promiseGet(url)
        .catch((function(url, event) {
            let { status } = event.currentTarget;
            if (status === 502) {
                return http.promiseGet(url);
            }
        }).bind(null, url)
    );
    return p.then(function(doc){
        let result = {retailers:{}, partNumbers:[]};
        let elements = doc.getElementsByClassName('distributor-title');
        for (let i = 0; i < elements.length; i++) {
            let h = elements[i];
            let title = h.firstElementChild.innerHTML.trim();
            let retailer = '';
            for (let k in aliases) {
                let v = aliases[k];
                let regex = RegExp(`^${k}`);
                if (regex.test(title)) {
                    retailer = v;
                    break;
                }
            }
            if (!__in__(retailer, retailers_to_search)) {
                continue;
            }
            let min_quantities = [];
            let additional_elements = h.parentElement.getElementsByClassName('additional-title');
            for (let j = 0; j < additional_elements.length; j++) {
                var span = additional_elements[j];
                if (span.innerHTML === 'Min Qty') {
                    min_quantities.push(span.nextElementSibling);
                }
            }
            var {span, n} = min_quantities.reduce(function(prev, span) {
                n = parseInt(span.innerHTML.trim());
                if (__guard__(prev, x => x.n) < n || isNaN(n)) {
                    return prev;
                } else {
                    return {span, n};
                }
            }
            , {});
            if (span == null) {
                for (let i1 = 0; i1 < additional_elements.length; i1++) {
                    span = additional_elements[i1];
                    if (span.innerHTML === 'Distri #:') {
                        var part = span.nextElementSibling.innerHTML.trim();
                        break;
                    }
                }
            } else {
                let tr = __guard__(__guard__(span.parentElement, x1 => x1.parentElement), x => x.parentElement);
                if (tr != null) {
                    let iterable = tr.getElementsByClassName('additional-title');
                    for (let j1 = 0; j1 < iterable.length; j1++) {
                        span = iterable[j1];
                        if (span.innerHTML === 'Distri #:' && (span.nextElementSibling != null)) {
                            var part = span.nextElementSibling.innerHTML.trim();
                            //sometimes there are some erroneous 'Distri #'
                            //after a space in the results
                            //like '77M8756 CE TMK107 B7224KA-T'
                            part = part.split(' ')[0];
                            break;
                        }
                    }
                }
            }
            if (part != null) {
                result.retailers[retailer] = part;
            }
        }
        return result;
    })
    .catch(reason => ({retailers:{}, partNumbers:[]}));
};

export let search = rateLimit(n=60, time_period_ms=20000, _search);

function __in__(needle, haystack) {
  return haystack.indexOf(needle) >= 0;
}
function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}