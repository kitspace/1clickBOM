# 1clickBOM #

[![Demo](https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/demo.gif)](https://chrome.google.com/webstore/detail/1clickbom/mflpmlediakefinapghmabapjeippfdi)

[![Available on Chrome][8]](https://chrome.google.com/webstore/detail/1clickbom/mflpmlediakefinapghmabapjeippfdi) ![Firefox coming soon][9]

1-click BOM is a browser extension that fills your shopping carts at sites like
Digikey and Mouser.  To add items to 1clickBOM you simply paste from a
spreadsheet or visit an online `.tsv` file.

## News ##

- v0.2.0 has been released with Firefox support
- [I gave a talk about 1clickBOM at FOSDEM this year](http://video.fosdem.org/2015/devroom-electronic_design_automation/one_click_bom.mp4)

## Which retailers? ##

Currently supported retailers are:

* Digikey
* Mouser
* Farnell/Element14
* Newark
* RS

Check the [roadmap][1] for more details on planned features.

## Usage ##

### Adding Items ###

You should arrange items in your spreadsheet in the following order.

    line-note | quantity | retailer | part-number

Line-note can be anything you like. I normally use schematic references.
Retailer is a name of one of the supported retailers and part-number is the
part-number specific to that retailer. See the [example tsv][2].

In your spreadsheet select the relevant columns, copy and then click the paste
button on the 1clickBOM popup.

![Load from page][3]

Alternatively, if you visit a page that ends in `.tsv` and has data in the
right format available 1clickBOM will show a blue badge and button with an
arrow. Press the blue button in the popup and the data will be added. You can
try this on the [example tsv page][2] once you have the extension installed.

### Then What? ###

Once the data is added you can use 1clickBOM to add the items to your carts
using the buttons on the popup. You can also quickly view and empty your carts.

## Issues ##

If you need any help or think you found a bug please get in touch via
[Github][10] or [email][11].

## Roadmap ##

* 1.0
    * Multiple retailers per item
    * Named columns
    * Preferred retailer setting
    * 1clickBOM site interaction
    * Warn about filling already filled carts

* 2.0
    * Allied, Arrow, AVNet, Conrad and Rapid
    * Function to minimize order cost + shipping
    * Autofind same items from different vendors
    * Display cart summaries
    * Allow adding components to BOM from the component page
    * Export BOM

* 3.0
    * 3D-chip-printer support

* 4.0
    * Communicate through quantum entanglement

## Development ##

### Build and Test Requirements ###

The code is available on [Github][7]. 1clickBOM is written in [Coffeescript][4]
which transpiles to Javascript.  Currently development is done on Chromium.

### Build and Test Instructions ###

To transpile the coffeescript to javascript run `cake build` the chrome
directory. Run `cake` with no arguments for help. The code can then be loaded
as an unpacked extension in the developer mode in Chrome/Chromium settings.

Unit and functional tests are written using the [QUnit framework][5]. Tests
can be run by opening a javascript console on the background page and executing
the `Test()` function.

## License ##

1clickBOM is free and open source software. It is licensed under a CPAL license
which means you can use the code in proprietary applications as long as you
display appropriate attribution and share your code-improvements to 1clickBOM
under the CPAL as well. See the [LICENSE][6] file for details.

[1]:#roadmap
[2]:https://github.com/monostable/1clickBOM/blob/master/examples/example.tsv
[3]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/load_from_page.png
[4]:http://coffeescript.org
[5]:https://qunitjs.com/
[6]:https://github.com/monostable/1clickBOM/blob/master/LICENSE
[7]:https://github.com/monostable/1clickBOM
[8]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/chrome.png
[9]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/firefox.png
[10]:https://github.com/monostable/1clickBOM/issues
[11]:mailto:info@1clickBOM.com
