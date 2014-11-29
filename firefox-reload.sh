#!/bin/sh
# this sends the extension to the auto-installer extension
# https://addons.mozilla.org/en-US/firefox/addon/autoinstaller/
# the 500 no-content error is normal
cfx --pkgdir=firefox xpi; wget --post-file=1clickbom.xpi http://localhost:8888/
