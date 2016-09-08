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

import { messenger } from './messenger';
import oneClickBOM from '1-click-bom';
let {retailer_list, isComplete, hasSKUs} = oneClickBOM.lineData;

let element_Bom              = document.querySelector('#bom');
let element_Table            = document.querySelector('#bom_table');
let element_TotalItems       = document.querySelector('#total_items');
let element_TotalPartNumbers = document.querySelector('#total_partNumbers');
let element_TotalLines       = document.querySelector('#total_lines');
let button_Clear             = document.querySelector('button#clear');
let button_LoadFromPage      = document.querySelector('button#load_from_page');
let button_DeepComplete      = document.querySelector('button#deep_complete');
let button_Copy              = document.querySelector('button#copy');
let button_Paste             = document.querySelector('button#paste');
let button_FillCarts         = document.querySelector('button#fill_carts');
let button_EmptyCarts        = document.querySelector('button#empty_carts');


button_FillCarts.addEventListener('click', function() {
    this.disabled = true;
    return messenger.send('fillCarts');
}
);


button_EmptyCarts.addEventListener('click', function() {
    this.disabled = true;
    return messenger.send('emptyCarts');
}
);


button_Clear.addEventListener('click', () => messenger.send('clearBOM')
);


button_Paste.addEventListener('click', () => messenger.send('paste')
);


button_LoadFromPage.addEventListener('click', () => messenger.send('loadFromPage')
);


button_Copy.addEventListener('click', () => messenger.send('copy')
);


button_DeepComplete.addEventListener('click', () => messenger.send('deepAutoComplete')
);


let hideOrShow = function(bom, onDotTSV) {
    let hasBOM = Boolean(Object.keys(bom.lines).length);

    button_Clear.disabled         = !hasBOM;
    button_DeepComplete.disabled  = (!hasBOM) || isComplete(bom.lines);
    button_Copy.disabled          = !hasBOM;

    return button_LoadFromPage.hidden = !onDotTSV;
};


let startSpinning = function(link) {
    let td = link.parentNode;
    let counter = 0;
    let spinner = document.createElement('div');
    spinner.className = 'spinner';
    td.appendChild(spinner);

    link.interval_id = setInterval(function(){
        let frames     = 12;
        let frameWidth = 15;
        let offset     = counter * -frameWidth;
        spinner.style.backgroundPosition=
            offset + 'px' + ' ' + 0 + 'px';
        counter++;
        if (counter>=frames) {
            return counter = 0;
        }
    }
    , 50);

    link.hidden   = true;
    return link.spinning = true;
};


let stopSpinning = function(link) {
    if ((link.spinning != null) && link.spinning) {
        let td            = link.parentNode;
        let spinner       = td.querySelector('div.spinner');
        clearInterval(link.interval_id);
        td.removeChild(spinner);
        link.hidden   = false;
        return link.spinning = false;
    }
};

let removeChildren = element =>
    (() => {
        let result = [];
        while (element.hasChildNodes()) {
            result.push(element.removeChild(element.lastChild));
        }
        return result;
    })()
;


let render = function(state) {
    let { bom } = state;

    hideOrShow(bom, state.onDotTSV);

    removeChildren(element_TotalLines);
    element_TotalLines.appendChild(
        document.createTextNode(`${bom.lines.length}
                line${bom.lines.length !== 1 ? 's' : ''}`));

    let part_numbers = bom.lines.reduce((prev, line) => prev += line.partNumbers.length > 0
    , 0);

    removeChildren(element_TotalPartNumbers);
    element_TotalPartNumbers.appendChild(
        document.createTextNode(`${part_numbers} with MPN`));

    let quantity = 0;
    for (let j = 0; j < bom.lines.length; j++) {
        let line = bom.lines[j];
        quantity += line.quantity;
    }

    removeChildren(element_TotalItems);
    element_TotalItems.appendChild(document.createTextNode(`${quantity}
        item${quantity !== 1 ? 's' : ''}`));

    while (element_Table.hasChildNodes()) {
        element_Table.removeChild(element_Table.lastChild);
    }

    let any_adding   = false;
    let any_emptying = false;

    return (() => {
        let result = [];
        for (let k = 0; k < retailer_list.length; k++) {
            let retailer_name = retailer_list[k];
            let lines = [];
            if (retailer_name in bom.retailers) {
                lines = bom.retailers[retailer_name];
            }
            let retailer = state.interfaces[retailer_name];
            let no_of_lines = 0;
            for (let i1 = 0; i1 < lines.length; i1++) {
                let line = lines[i1];
                no_of_lines += line.quantity;
            }
            let tr = document.createElement('tr');
            element_Table.appendChild(tr);
            let td_0 = document.createElement('td');
            let icon = document.createElement('img');
            icon.src = retailer.icon_src;
            let viewCart = document.createElement('a');
            viewCart.appendChild(icon);
            viewCart.innerHTML += retailer.name;
            viewCart.value = retailer.name;
            td_0.value = retailer.name;
            td_0.addEventListener('click', function() {
                return messenger.send('openCart', this.value);
            }
            );
            td_0.appendChild(viewCart);
            td_0.id = 'icon';
            tr.appendChild(td_0);

            let td_1 = document.createElement('td');
            let t  = `${lines.length}`;
            let tspan = document.createElement('span');
            tspan.appendChild(document.createTextNode(t));

            if (lines.length !== bom.lines.length) {
                td_1.style.backgroundColor = 'pink';
            }

            let t2 = ` line${lines.length !== 1 ? 's' : ''}`;
            let t2span = document.createElement('span');
            t2span.appendChild(document.createTextNode(t2));

            td_1.appendChild(tspan);
            td_1.appendChild(t2span);
            tr.appendChild(td_1);

            let unicode_chars = ['\uf21e', '\uf21b',];
            let titles   = ['Add lines to ', 'Empty '];
            let messages = ['fillCart', 'emptyCart'];
            let lookup   = ['adding_lines', 'clearing_cart'];
            let iterable = [0, 1];
            for (let j1 = 0; j1 < iterable.length; j1++) {
                let i = iterable[j1];
                let td = document.createElement('td');
                td.className = 'button_icon_td';
                tr.appendChild(td);
                let span = document.createElement('span');
                span.className = 'button_icon';
                span.appendChild(document.createTextNode(unicode_chars[i]));
                if (messages[i] === 'fillCart' && lines.length === 0) {
                    span.style.color = 'grey';
                    span.style.cursor = 'default';
                    td.appendChild(span);
                } else {
                    let a = document.createElement('a');
                    a.value = retailer.name;
                    a.message = messages[i];
                    a.title = titles[i] + retailer.name + ' cart';
                    a.href = '#';
                    a.appendChild(span);
                    a.addEventListener('click', function() {
                        startSpinning(this);
                        return messenger.send(this.message, this.value);
                    }
                    );
                    td.appendChild(a);
                }
                if (retailer[lookup[i]]) {
                    startSpinning(span);
                }
                any_adding   |= retailer.adding_lines;
                any_emptying |= retailer.clearing_cart;
            }

            button_FillCarts.disabled  = any_adding || (!hasSKUs(bom.lines));
            result.push(button_EmptyCarts.disabled = any_emptying);
        }
        return result;
    })();
};


messenger.on('sendBackgroundState', state => render(state)
);


// For Firefox we forward the popup 'show' event from browser.coffee because
// this script seems get loaded once at startup not on popup. The 'show' message
// is never sent on Chrome.
messenger.on('show', ()=> messenger.send('getBackgroundState')
);


// For Chrome the whole script is instead re-executed each time the popup is
// opened.
messenger.send('getBackgroundState');
