function addToCart(item, quantity, reference)
{
    var xhr = new XMLHttpRequest();
    var url = "http://www.digikey.com/classic/Ordering/AddPart.aspx?qty=" + quantity + "&part=" + item + "&cref=" + reference;
    xhr.open("POST", url);
    xhr.send();
}

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
                                    chrome.tabs.reload(tab.id);
                                });
                            });
                            chrome.tabs.query({"url":"*://www.digikey.com/classic/Ordering/AddPart.aspx*"}, function(tabs) {
                                tabs.forEach( function(tab) {
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

function showCart()
{
    window.open("http://www.digikey.com/classic/Ordering/AddPart.aspx");
}

//clearCart = ()->
//  url = "https://www.digikey.com/classic/Ordering/OrderingHome.aspx"
//  chrome.tabs.create {"url":url}, (tab)->
//    code = "document.forms[1].elements['ctl00_mainContentPlaceHolder_btnCreateNewOrder'].click();"
//  check_done = setInterval ()->
//    chrome.tabs.get tab.id, (tab)->
//      done_url = "https://www.digikey.com/classic/ordering/addpart.aspx?site=us&curr=usd"
//      if tab.url == done_url
//        clearInterval check_done
//        chrome.tabs.remove tab.id
//        chrome.tabs.query {"url":"*://www.digikey.com/classic/ordering/addpart.aspx*}, (tab)->
//
