
[![Youtube Demo][22]](https://youtu.be/611TW315pZM)

[![Available on Chrome][8]][14] [![Add to Firefox][9]][13]

## Summary ##

1-click BOM is a browser extension that fills your shopping carts for you on
sites like Digikey and Mouser, you simply paste from a spreadsheet or visit an
online `.tsv` file. This way you can keep one bill of materials (BOM) that lets
you and people you share the BOM with quickly purchase items from multiple
retailers.

## Table of Contents ##

* [Summary](#summary)
* [News](#news)
* [Which retailers?](#which-retailers)
* [Usage](#usage)
* [Issues](#issues)
* [Roadmap](#roadmap)
* [Development](#development)
* [License](#license)

## News ##

- [Added function to auto-complete BOM](#completion)

- [Named columns are now supported](#usage)

- [1clickBOM is available for Firefox][20]

- [I gave a talk about 1clickBOM at FOSDEM in 2015][12]

## Which retailers? ##

Currently supported retailers are:

* Digikey
* Mouser
* Farnell/Element14
* Newark
* RS

Check the [roadmap](#roadmap) for more details on planned features.

## Usage ##

### Making a 1-click-BOM ###

You can copy and paste into the extension from a text editor or spread sheet
program (LibreOffice, Excel). You must have a column for line-note, one for the
quantity and at least one retailer. Optional columns are 'Description' and
'Part Number'. You can have multiple 'Part Number' columns for specifying
multiple possible manufacturer part numbers per schematic reference.

When saving files from your external editor/spreadsheet save them as
tab-seperated values with a `.tsv` extension.

Here is a small example which is well suited for [auto-completing](#completion):

| References | Qty | Description   | PartNumber                  | 
|------------|-----|---------------|-----------------------------| 
| C1         | 1   | 1uF 0603 X5R  |                             | 
| C2         | 1   | 10uF 0603 X5R |                             | 
| D1         | 1   |               | 1N4148WS                    | 
| Q1         | 1   |               | IRF7309PBF                  | 
| R1         | 1   | 10k 0603      |                             | 
| R2,R4      | 2   | 100k 0603     |                             | 
| R3         | 1   | 300k 0603     |                             | 
| SW1        | 1   |               | TE Connectivity 4-1437565-1 | 

You can find this and other examples in TSV format in the [examples directory][2].

The examples are mostly in the format that 1-click BOM will output but it is
less strict about reading. Below are tables of title aliases 1-click-BOM
recognizes. If you have any more suggestions please [get in touch](#issues).
(Capitalisation is ignored, characters within brackets, like`(s)`, denote they
are optional.)

| References   | Description    | Quantity | Part Number                 |
|--------------|----------------|----------|-----------------------------|
| ref(s)       | comment(s)     | qty(s)   | part-number(s)              |
| reference(s) | description(s) | quantity | partnumber(s)               |
| line-note(s) | cmnt(s)        |          | part number(s)              |
| line note(s) | descr(s)       |          | m(/)f part(s)               |
|              |                |          | manuf(.) part(s)            |
|              |                |          | mpn(s)                      |
|              |                |          | m(/)f part number(s)        |
|              |                |          | manuf(.) part number(s)     |
|              |                |          | manufacturer part(s)        |
|              |                |          | manufacturer part number(s) |
|              |                |          | prt(s)                      |
|              |                |          | part(s)                     |

| Farnell   | Digikey    | Mouser | RS            | Newark | 
|-----------|------------|--------|---------------|--------| 
| farnell   | digi(-)key | mouser | rs            | newark | 
| fec       |            |        | rsonline      |        | 
| premier   |            |        | rs-online     |        | 
| element14 |            |        | rs(-)delivers |        | 
|           |            |        | radio( )spares|        | 
|           |            |        | rs( )components |        | 

### Loading an online BOM ###

If you visit a page that ends in `.tsv` and has data in the right format
available 1clickBOM will show a blue badge and button with an arrow. Clicking
the blue button will load the data into 1clickBOM.

![Load from page][3]


### Let's go shopping! ###

Once the data is added you can use 1clickBOM to add the items to your carts
using the buttons on the popup. You can also quickly view and empty your carts.

### Completion ###

New in version 0.5 is a function to search Octopart.com and Findchips.com to try
and complete a BOM for you. A complete BOM is one that has a part number for
_every_ retailer. Simply press the button labeled 'Complete' and 1clickBOM will
use other fields to search for the fields that are left blank.

### Legacy BOM format ###

The format used prior to version `0.3` simply had the items in the following order:

    line-note | quantity | retailer | part-number

This format is still supported but deprecated and will be phased out by version
`1.0`.

## Issues ##

If you need any help or think you found a bug please get in touch via
[GitHub][10] or [email][11].

## Roadmap ##

* 0.7
    * Kitnic.it site interaction
    * Set a timeout on all UI requests so that extension cannot get stuck

* 1.0
    * Remove legacy BOM format support

* 1.1
    * Make requests cancelable
    * Improve user interface

* 1.2
    * Add retailer preference ranking
    * Add function to reduce BOM (and add to cart?) according to retailer preference

* 1.3
    * Additional retailer support
        * AVNet
        * Adafruit
        * Allied
        * Arrow
        * Conrad
        * CPC
        * Rapid
        * Seeed
        * Sparkfun

* 2.0
    * Support for direct loading from Google docs pages
    * BOM details and editing page
    * Display cart summaries
    * Function to minimize order cost + shipping
    * Allow adding components to BOM from the component page

* 3.0
    * 3D-chip-printer support

* 4.0
    * Communicate through quantum entanglement

## Development ##

### Build and Test Requirements ###

The code is available on [GitHub][7]. To get started you will need:

- Chrome or Chromium
- Firefox (optionally with [Extension Autoinstaller][16])
- [Ninja Build](https://ninja-build.org/)
- sed
- npm

The rest of the dependencies can be retrieved via `npm install`.

### Build and Test Instructions ###

#### Build

- Get dependencies above and make sure executables are on your path
- `npm install --global` (or `npm install && export PATH=$PATH:$(pwd)/node_modules/.bin`)
- `./configure.coffee`
- `ninja`

#### Load

- For Chrome enable developer mode in `chrome://extensions` and load the unpacked extension from `build/chrome`
- For Firefox run `./firefox.sh run` (or setup [Autoinstaller][16] and run `./firefox.sh post`)

#### Test

Tests are written in [QUnit 1.11][17] and can only be run in Chrome/Chromium.
Open a console on background page and execute `Test()` or test a specific
module, e.g.  Farnell, with `Test('Farnell')`

Most of the tests are functional tests that require interaction with the
various retailer sites and they make a lot of network requests to test across
all the different possible locations. Sometimes they will fail because they are
not an accurate representation of actual extension use. If a test fails or
doesn't complete, run it again before investigating. Try and re-create the
issue manually before trying to fix it.

## License ##

1clickBOM is free and open source software. It is licensed under a CPAL license
which means you are free to use the code in your own applications (even
proprietary ones) as long as you display appropriate attribution and share your
code-improvements to 1clickBOM itself under the CPAL as well. This also applies
to software you are solely making available to users over a network i.e.
software as a service. See the [LICENSE][6] file for details.

[2]:https://github.com/monostable/1clickBOM/blob/master/examples/
[3]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/load_from_page.png
[4]:http://coffeescript.org
[5]:https://qunitjs.com/
[6]:https://github.com/monostable/1clickBOM/blob/master/LICENSE
[7]:https://github.com/monostable/1clickBOM
[8]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/chrome.png
[9]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/firefox.png
[10]:https://github.com/monostable/1clickBOM/issues
[11]:mailto:info@1clickBOM.com
[12]:http://video.fosdem.org/2015/devroom-electronic_design_automation/one_click_bom.mp4
[13]:https://addons.mozilla.org/firefox/downloads/latest/634060/addon-634060-latest.xpi
[14]:https://chrome.google.com/webstore/detail/1clickbom/mflpmlediakefinapghmabapjeippfdi
[15]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/demo.gif
[16]:https://palant.de/2012/01/13/extension-auto-installer
[17]:https://web.archive.org/web/20130128010139/http://api.qunitjs.com/
[18]:https://developer.mozilla.org/en-US/Add-ons/SDK
[19]:http://1clickBOM.com
[20]:https://addons.mozilla.org/en-US/firefox/addon/1clickbom/
[22]:https://github.com/monostable/1clickBOM/blob/feat-auto-complete/readme_images/youtube.png
