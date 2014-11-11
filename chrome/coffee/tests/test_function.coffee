@Test = (module)->
    url = chrome.extension.getURL("html/test.html")
    url += "?module=" + module if module?
    window.open(url)

@UserSim = ()->
    url = chrome.extension.getURL("html/test_user_simulation.html")
    window.open(url)

@LongTest = ()->
    url = chrome.extension.getURL("html/test_long.html")
    window.open(url)
