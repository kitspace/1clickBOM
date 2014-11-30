#!/bin/sh
# this sends the extension to the auto-installer extension
# https://addons.mozilla.org/en-US/firefox/addon/autoinstaller/
# the 500 no-content error is normal
cfx --pkgdir=firefox --output-file=tmp.xpi xpi; wget --no-verbose --post-file=tmp.xpi http://localhost:8888/
