class @Digikey extends Retailer
    constructor: (country_code) ->
        xhr = new XMLHttpRequest()
        xhr.open "GET", chrome.extension.getURL("/data/digikey_international.json"), false
        xhr.send()
        if xhr.status == 200
            data = JSON.parse xhr.responseText
        country = data.lookup[country_code]
        if !country
            error = new InvalidCountryError()
            error.message += " \"" + country_code + "\" given to Digikey."
            throw error
        @site = data.sites[country]
        @cart = data.carts[country]
        return super "Digikey", country


    clearCart: ->
        that = this
        if /classic/.test @cart
            #for the classic sites we have to open a tab with with the new order url and actually "click" the button to clear the cart, WTF
            clear_url = "https" + @site + "/classic/Ordering/OrderingHome.aspx"
            chrome.tabs.create {"url":clear_url, "active":false}, (temp_tab)->
                code = "document.forms[1].elements['ctl00_mainContentPlaceHolder_btnCreateNewOrder'].click();"
                chrome.tabs.executeScript temp_tab.id, {"code":code}, ()->
                    done = false
                    #check every 100ms wether cart has been cleared, if yes, close the tab and load an empty cart URL 
                    #into any tabs with the cart open (else if we reload it will refresh, for example, an add-to-cart request)
                    check_done = setInterval ()->
                        chrome.tabs.get temp_tab.id, (temp_tab_after_execute)->
                            url = temp_tab_after_execute.url.split("?")[0]
                            if url == "https" + that.site + that.cart
                                chrome.tabs.remove temp_tab_after_execute.id
                                clearInterval check_done

                                chrome.tabs.query {"url":"*" + that.site + "/classic/*rdering/*dd*art.aspx*"}, (tabs)->
                                    for tab in tabs
                                        chrome.tabs.update tab.id, {"url": "https" + that.site + that.cart}
                                        #TODO don't switch to https?

                                done = true
                                console.log that.name + " cart cleared."
                                #super that
                    , 100

                    #give up after 5s
                    setTimeout ()->
                        if !done
                            console.error that.name + " cart clearing failed."
                            clearInterval check_done
                    , 5000
        else if /ShoppingCartView/.test @cart
            #for the newer sites we send a POST request and load an empty cart URL into any tabs with the cart open 
            #(else if we reload it will refresh, for example, an add-to-cart request)
            xhr = new XMLHttpRequest
            xhr.open("POST", "https" + @site + @cart + "?explicitNewOrder=Y")
            xhr.onreadystatechange = () ->
                if xhr.readyState == 4
                    chrome.tabs.query {"url":"*" + that.site + that.cart + "*"}, (tabs)->
                        for tab in tabs
                            chrome.tabs.update tab.id, {"url": "https" + that.site + that.cart}
                            #TODO don't switch to https?
                    console.log that.name + " cart cleared."
            xhr.send()

    addItems: (items) ->
        that = this
        if /classic/.test @cart
            for item,i in items
                xhr = new XMLHttpRequest
                xhr.open "POST", "https" + @site + @cart + "?qty=" + item.quantity + "&part=" + item.part + "&cref=" + item.comment + i, true
                xhr.onreadystatechange = () ->
                    if xhr.readyState == 4
                        chrome.tabs.query {"url":"*" + that.site + "/classic/*rdering/*dd*art.aspx*"}, (tabs)->
                            for tab in tabs
                                chrome.tabs.update tab.id, {"url": "https" + that.site + that.cart}
                                #TODO don't switch to https?
                xhr.send()
        else if /ShoppingCartView/.test @cart
            #we mimick the quick add form and send requests of 20 parts
            #this has to be done synchronously, else we get 302 errors
            for _, i in items by 20
                group = items[i..i+19]
                xhr = new XMLHttpRequest
                url = "https" + @site + "/ordering/AddPart?"
                for item,j in group
                    url += "&comment_" + (j+1) + "=" + item.comment
                    url += "&quantity_" + (j+1) + "=" + item.quantity
                    url += "&reportPartNumber_" + (j+1) + "=" + item.part
                xhr.open "POST", url, false
                xhr.send()
             chrome.tabs.query {"url":"*" + that.site + that.cart + "*"}, (tabs)->
                 for tab in tabs
                     chrome.tabs.update tab.id, {"url": "https" + that.site + that.cart}
                     #TODO don't switch to https?

            #?backorder=*n&orderId=102237524&quantity=1&recordId=1747890&URL=ShoppingCartView&page=PartDetail&catalogId=&DKCPartNumber=754-1173-1-ND&wtQty=1&source=search&partNumber=754-1173-1-ND&storeId=12251&comment=CUSTOMA&enterprise=&reverse=*n&goodParts=754-1173-1-ND&langId=104&reportPartNumber=754-1173-1-ND&wtAction=OrderItemAdd&errorViewName=ShoppingCartView&orderItemId=1544990&allocate=*n&ddkey=http:PartDetail

     
     #getCart: ->
     #   that = this
     #   parser = new DOMParser
     #   xhr = new XMLHttpRequest
     #   xhr.open "GET", "https" + @site + @cart, false
     #   xhr.send()
     #   if xhr.status == 200
     #       doc = parser.parseFromString(xhr.responseText, "text/html")
     #   #table = doc.getElementById("ctl00_ctl00_mainContentPlaceHolder_mainContentPlaceHolder_ordOrderDetails").getElementsByTagName("tbody")[0]#.getElementsById("valSubtotal")[0]
     #   subtotal = doc.getElementById("valSubtotal").innerText
     #   subtotal = subtotal.replace(/\s*/g, '')
     #   subtotal = subtotal.replace(/€/g, '')
     #   subtotal = subtotal.replace(/\,/, '.')
     #   subtotal = parseFloat(subtotal)

     #   shipping = doc.getElementById("valShipping").innerText
     #   shipping = shipping.replace(/\s*/g, '')
     #   shipping = shipping.replace(/€/g, '')
     #   shipping = shipping.replace(/\,/, '.')
     #   shipping = parseFloat(shipping)

     #   total = doc.getElementById("valTotal").innerText
     #   total = total.replace(/\s*/g, '')
     #   if total == "unknown"
     #       total = NaN
     #   else
     #       total = total.replace(/€/g, '')
     #       total = total.replace(/\,/, '.')
     #       total = parseFloat(total)

     #   #table = table.getElementByTagName("tbody")[0]
     #   return {"subtotal":subtotal, "shipping":shipping, "total": total}
