@Test = ()->
    url = chrome.extension.getURL("test.html")
    window.open(url)
