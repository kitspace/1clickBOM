#
#
<link href="favicon.png" rel="shortcut icon" type="image/png"></link>
<center>
<iframe width="560" height="315" src="https://www.youtube.com/embed/611TW315pZM" frameborder="0" allowfullscreen></iframe>
</center>
#

<center><p><a id="chromelink" href="https://chrome.google.com/webstore/detail/1clickbom/mflpmlediakefinapghmabapjeippfdi"><img id="chromeimage" src="https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/chrome.png" alt="Available on Chrome" /></a><a href=https://addons.mozilla.org/firefox/downloads/latest/634060/addon-634060-latest.xpi><img alt="Add to Firefox" src="https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/firefox.png"></a></p></center>
<script type"text/javascript">

    //fix favicon on firefox (due to github.io hosting)
    link=document.createElement("link");
    link.setAttribute("href", "favicon.png");
    link.setAttribute("rel", "shortcut icon");
    link.setAttribute("type", "image/png");
    document.head.appendChild(link);

    //add quick installation for chrome to link and track it
    var chromelink = document.getElementById("chromelink");
    if (/Chrome/.test(navigator.userAgent)) {
        chromelink.href = "#";
        chromelink.onclick = function () {
            chrome.webstore.install(undefined, function () {
                _paq.push(['trackEvent', 'Install', 'chrome-install']);
            });
        };
    }

</script>

