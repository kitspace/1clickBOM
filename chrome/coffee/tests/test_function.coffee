@Test = (module)->
    url = browser.getURL("html/test.html")
    url += "?module=" + module if module?
    window.open(url)

@UserSim = ()->
    url = browser.getURL("html/test_user_simulation.html")
    window.open(url)

@LongTest = ()->
    url = browser.getURL("html/test_long.html")
    window.open(url)
