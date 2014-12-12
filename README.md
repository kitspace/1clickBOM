# 1clickBOM #

[![Demo](https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/demo.gif)](https://chrome.google.com/webstore/detail/1clickbom/mflpmlediakefinapghmabapjeippfdi)

[![Available on Chrome][8]](https://chrome.google.com/webstore/detail/1clickbom/mflpmlediakefinapghmabapjeippfdi) ![Firefox coming soon][9]

1clickBOM is purchasing tool that let's you keep _one_ bill of materials (BOM)
for items from _multiple_ retailers. It's a browser extension that fills your
online shopping carts for you. To add items to 1clickBOM you simply paste from
a spreadsheet or visit an online `.tsv` file.

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

![Load from page](https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/load_from_page.png)

Alternatively, if you visit a page that ends in `.tsv` and has data in the
right format available 1clickBOM will show a blue badge and button with an
arrow. Press the blue button in the popup and the data will be added. You can
try this on the [example tsv page][2] once you have the extension installed.

### Then What? ###

Once the data is added you can use 1clickBOM to add the items to your carts
using the buttons on the popup. You can also quickly view and empty your carts.

## Issues ##

If you need any help or think you found a bug please get in touch via
[Github][10] or [email:info@1clickBOM.com][11].

## Roadmap ##

* 0.2
    * Firefox support

* 0.3
    * Multiple retailers per item
    * Named columns
    * Preferred retailer rankings

* 0.4
    * Allied, Arrow, AVNet
    * Display cart summaries
    * Warn about filling already filled carts
    * Allow adding components to BOM from the component page
    * Export BOM

* 1.0
    * Function to minimize order cost + shipping
    * Autofind same items from different vendors

* 2.0
    * Include PCB order

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

1clickBOM free and open source software. It is licensed under a CPAL license
which means you can use the code in proprietary applications as long as you
display appropriate attribution and share your code-improvements to 1clickBOM
under the CPAL as well. See the [LICENSE][6] file for details.

[1]:#roadmap
[2]:https://github.com/monostable/1clickBOM/blob/master/chrome/data/example.tsv
[3]:https://github.com/monostable/1clickBOM/blob/master/chrome/html/test.html
[4]:http://coffeescript.org
[5]:https://qunitjs.com/
[6]:https://github.com/monostable/1clickBOM/blob/master/LICENSE
[7]:https://github.com/monostable/1clickBOM
[8]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/chrome.png
[9]:http://1clickBOM.com/firefox.png
[10]:https://github.com/monostable/1clickBOM/issues
[11]:mailto:info@1clickBOM.com
