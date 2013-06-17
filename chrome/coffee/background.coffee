class Retailer
    constructor: (name, @country) ->
        @name = name + " " + @country

    clearCart: (ref)->
        console.log ref.name + " cart cleared."


class @Digikey extends Retailer
    constructor: (country) ->
        super "Digikey", country

    clearCart: ->
        #for digikey we have to open a tab with with the new order url and actually "click" the button to clear the cart
        url = "https://www.digikey.com/classic/Ordering/OrderingHome.aspx"
        that = this
        chrome.tabs.create {"url":url}, (temp_tab)->
            code = "document.forms[1].elements['ctl00_mainContentPlaceHolder_btnCreateNewOrder'].click();"
            chrome.tabs.executeScript temp_tab.id, {"code":code}, ()->
                done_url = "https://www.digikey.com/classic/ordering/addpart.aspx?site=us&curr=usd"
                done = false
                #check every 100ms wether cart has been cleared, if yes, close the tab and reload any open cart tabs
                check_done = setInterval ()->
                    chrome.tabs.get temp_tab.id, (temp_tab_after_execute)->
                        if temp_tab_after_execute.url == done_url
                            clearInterval check_done
                            chrome.tabs.remove temp_tab_after_execute.id

                            chrome.tabs.query {"url":"*://www.digikey.com/classic/ordering/addpart.aspx*"}, (tabs)->
                                chrome.tabs.reload tab.id for tab in tabs

                            chrome.tabs.query {"url":"*://www.digikey.com/classic/Ordering/AddPart.aspx*"}, (tabs)->
                                chrome.tabs.reload tab.id for tab in tabs
                                
                            done = true
                            super that
                , 100

                #give up after 5s
                setTimeout ()->
                    if !done
                        console.error "Digikey cart clearing failed."
                        clearInterval check_done
                , 5000
