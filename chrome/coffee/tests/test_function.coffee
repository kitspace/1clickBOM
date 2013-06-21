@Test = ()->
    url = chrome.extension.getURL("html/test.html")
    window.open(url)
