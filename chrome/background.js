/*! @source https://gist.github.com/1129031 */
/*global document, DOMParser*/

(function(DOMParser) {
	"use strict";

	var
	  DOMParser_proto = DOMParser.prototype
	, real_parseFromString = DOMParser_proto.parseFromString
	;

	// Firefox/Opera/IE throw errors on unsupported types
	try {
		// WebKit returns null on unsupported types
		if ((new DOMParser).parseFromString("", "text/html")) {
			// text/html parsing is natively supported
			return;
		}
	} catch (ex) {}

	DOMParser_proto.parseFromString = function(markup, type) {
		if (/^\s*text\/html\s*(?:;|$)/i.test(type)) {
			var
			  doc = document.implementation.createHTMLDocument("")
			;
	      		if (markup.toLowerCase().indexOf('<!doctype') > -1) {
        			doc.documentElement.innerHTML = markup;
      			}
      			else {
        			doc.body.innerHTML = markup;
      			}
			return doc;
		} else {
			return real_parseFromString.apply(this, arguments);
		}
	};
}(DOMParser));

function addToCart(item, quantity, reference)
{
    var xhr = new XMLHttpRequest();
    var url = "http://www.digikey.com/classic/Ordering/AddPart.aspx?qty=" + quantity + "&part=" + item + "&cref=" + reference;
    xhr.open("POST", url);
    xhr.send();
}

chrome.browserAction.onClicked.addListener(function(tab) {
    // No tabs or host permissions needed!
    console.log('Turning ' + tab.url + ' red!');
    chrome.tabs.executeScript(null, {
    code:"document.body.style.setProperty('background-color', '#ff0000', 'important')"}); 
});

function clearCart()
{
    var url = "https://www.digikey.com/classic/Ordering/OrderingHome.aspx";
    chrome.tabs.create({"url":url, "active":false}, function (tab) {
        code = "document.forms[1].elements['ctl00_mainContentPlaceHolder_btnCreateNewOrder'].click();";
        chrome.tabs.executeScript(tab.id, {"code":code}, function () {
            var check_done = setInterval(function () 
                { 
                    chrome.tabs.get(tab.id, function (tab) {
                        var done_url = "https://www.digikey.com/classic/ordering/addpart.aspx?site=us&curr=usd"
                        if (tab.url == done_url) {
                            clearInterval(check_done);
                            chrome.tabs.remove(tab.id);
                            chrome.tabs.query({"url":"*://www.digikey.com/classic/ordering/addpart.aspx*"}, function(tabs) {
                                tabs.forEach( function(tab) {
                                    console.log(tab.url);
                                    chrome.tabs.reload(tab.id);
                                });
                            });
                            chrome.tabs.query({"url":"*://www.digikey.com/classic/Ordering/AddPart.aspx*"}, function(tabs) {
                                tabs.forEach( function(tab) {
                                    console.log(tab.url);
                                    chrome.tabs.reload(tab.id);
                                });
                            });
                        }
                    });
                }, 100);
            setTimeout(function(){clearInterval(check_done);}, 10000);
        });
    });

}
    //window.open(url);
    //console.logchrome.tabs.query({"url":url})
    //var xhr = new XMLHttpRequest();
    //xhr.open("GET", url);
    //xhr.onreadystatechange = function() 
    //{
    //    if (xhr.readyState == 4) 
    //    {
    //        console.log(document);
    //        document.body.innerHTML = xhr.responseText;
    //        //parser = new DOMParser();
    //        //dom = parser.parseFromString(xhr.responseText, "text/html"); 
    //        //dom.forms[1].submit();
    //        console.log("done.");
    //    }
    //}
    //xhr.send();

function showCart()
{
    window.open("http://www.digikey.com/classic/Ordering/AddPart.aspx");
}

