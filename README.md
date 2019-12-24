<p align=center>
<img src="https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/demo.gif" />
</p>

<p align=center>
<a href="https://chrome.google.com/webstore/detail/1clickbom/mflpmlediakefinapghmabapjeippfdi">
<img src="https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/chrome.png" />
</a>
<a href="https://addons.mozilla.org/firefox/downloads/latest/634060/addon-634060-latest.xpi">
<img src="https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/firefox.png" />
</a>
</p>

## Summary ##

1-click BOM is a browser extension that fills your shopping carts for you on
sites like Digikey and Mouser. Its main purpose is to work with the electronic
project sharing site [kitspace.org](https://kitspace.org). But you can also use it
from a spreadsheet or load an online `.tsv` file from any other site.

## Table of Contents ##

* [Summary](#summary)
* [News](#news)
* [Which distributors?](#which-distributors)
* [Usage](#usage)
* [Issues](#issues)
* [Roadmap](#roadmap)
* [Development](#development)
* [License](#license)

## News ##
- [Check out our electronics sharing site: Kitspace!](https://kitspace.org)

- [Added function to auto-complete BOM](#completion)

- [Named columns are now supported](#usage)

- [1clickBOM is available for Firefox][20]

- [I gave a talk about 1clickBOM at FOSDEM in 2015][12]

## Which distributors? ##

Currently supported distributors are:

* Digikey
* Mouser
* Farnell/Element14
* Newark
* RS

Check the [roadmap](#roadmap) for more details on planned features.

## Usage ##

### Making a 1-click-BOM ###

#### Eagle

![][eagle_bom_export.png]

1. In the schematic window, select "File -> Export -> BOM". Select "List Type" values and "Output Format" CSV (see image) and press save.
1. Open the `.csv` in a spreadsheet program (LibreOffice, Excel). Select a semi-colon seperator when importing.
1. Adjust the description column to be more informative, e.g. "10uf 0603 X7R" for a capcitor or "1k 0805" for a resistor or the MPN for ICs and transistors. The description will be used for auto-completing.
1. Select everything in your spreadsheet program, copy and paste into the extension.
1. Press "complete" in the extension, wait till it's done and then press copy.
1. Open a new spreadsheet and paste into it. Save it as tab-seperated values, with a `.tsv` extension and UTF-8 encoding.
1. Check over all the part numbers and make sure they are correct. Put them into your shopping cart using the extension to confirm they have the right minimum order quantity etc.

#### KiCAD

![][kicad_bom_export.png]

1. Download the Python files from the [output_scripts/kicad][output_scripts/kicad] directory. Put them all together into a directory where you want to keep them.
2. In Eeschema, the schematic tool, select `Tools -> Generate Bill of Materials` then `Add Plugin` and then `Generate` Select:
    - 1-click-bom_description.py to try and extract a description for [auto-complete](#completion)
    - 1-click-bom_fields.py if you have fields in your symbols that 1-click BOM will understand (see [below](#field-matching)).
3. Open the resulting file in a spreadsheet program or text editor. Reduce the descriptions down to the bare minimum if you want to use auto-completing. Copy and paste it into the extension.
4. Try auto-completing in the extension if you wish, check all the values afterwards.
5. To sync any changes back into your schematic you can use [KiField](https://pypi.python.org/pypi/kifield).


#### All CAD Programs

You can copy and paste into the extension from a text editor or spread sheet
program (LibreOffice, Excel). You must have a column for references, one for the
quantity and at least one of: decription, part number or a distributor column.
You can have multiple part number columns for specifying
multiple possible manufacturer part numbers per schematic reference.

When saving files from your external editor or spreadsheet save them as
tab-seperated values with a `.tsv` extension with UTF-8 encoding.

Here is a small example which is well suited for [auto-completing](#completion):

| References | Qty | Description   | Part Number |
|------------|-----|---------------|-------------|
| C1         | 1   | 1uF 0603 X5R  |             |
| C2         | 1   | 10uF 0603 X5R |             |
| D1         | 1   |               | 1N4148WS    |
| Q1         | 1   |               | IRF7309PBF  |
| R1         | 1   | 10k 0603      |             |
| R2,R4      | 2   | 100k 0603     |             |
| R3         | 1   | 300k 0603     |             |
| SW1        | 1   |               | 4-1437565-1 |

You can find this and other examples in TSV format in the [examples directory][2].

### Field Matching

The examples are mostly in the format that the extension will output. Reading
is less strict.  Below are tables of title aliases 1-click-BOM recognizes. If
you have any more suggestions please [get in touch](#issues).  (Capitalisation
is ignored, characters within brackets, like`(s)`, denote they are optional.)

| References   | Quantity    | Description    | MPN                         |
|--------------|-------------|----------------|-----------------------------|
| ref(s)       | qty(s)      | comment(s)     | part(-)number(s)            |
| reference(s) | quantity(s) | description(s) | partnumber(s)               |
| line-note(s) |             | cmnt(s)        | part number(s)              |
| line note(s) |             | descr(s)       | m(/)f part(s)               |
| part(s)      |             |                | manuf(.) part(s)            |
|              |             |                | mpn(s)                      |
|              |             |                | m(/)f part number(s)        |
|              |             |                | manuf(.) part number(s)     |
|              |             |                | manufacturer part(s)        |
|              |             |                | manufacturer part number(s) |

| Digikey    | Mouser | RS              | Newark | Farnell   |
|------------|--------|-----------------|--------|-----------|
| digi(-)key | mouser | rs              | newark | farnell   |
|            |        | rs(-)online     |        | fec       |
|            |        | rs(-)delivers   |        | premier   |
|            |        | radio( )spares  |        | element14 |
|            |        | rs( )components |        |           |

### Loading an online BOM ###

If you visit a page on [kitspace.org](https://kitspace.org) or one that ends in
`.tsv` and has data in the right format available 1clickBOM will show a blue
badge and button with an arrow. Clicking the blue button will load the data
into the extension.

![Load from page][3]


### Let's go shopping! ###

Once the data is added you can use 1clickBOM to add the items to your carts
using the buttons on the popup. You can also quickly view and empty your carts.

### Completion ###

1-click BOM can try and complete an incomplete BOM for you by selecting resistors and capacitors from the [CPL](https://octopart.com/common-parts-library) and searching Octopart and Findchips.
A complete BOM is where every part has a manufacturer part number and a part number for _every_ distributor.
Simply press the button labeled 'Complete' and 1clickBOM will use other fields to search for the fields that are left blank.
You should always check over the parts it has selected for you.

Auto-completion works best if you have limited text in the description. Try and reduce the description column down to the bare-minimum or add an MPN field. "1uF 0603 X5R" is a good description while "C Capacitor 1uF 1 micro Farad SM0603 0603 SMD" isn't.

## Issues ##

If you need any help or think you found a bug please get in touch via
[GitHub][10], [email][11] or visit the [Kitspace chat
room][kitspace chat].

## Roadmap ##

* 1.6
    * Ability to add components to BOM from distributor site
    * Make requests cancelable
    * Improve user interface

* 1.7
    * Add distributor preference ranking
    * Add function to reduce BOM (and add to cart?) according to distributor preference

* 1.8
    * Additional distributor support
        * AVNet
        * Adafruit
        * Allied
        * Arrow
        * Conrad
        * CPC
        * Rapid
        * Seeed
        * Sparkfun
        * TME

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
- Firefox version 52 or higher
- [Ninja Build](https://ninja-build.org/)
- sed
- npm

The rest of the dependencies can be retrieved via `npm install`.

### Build and Test Instructions ###

#### Build

- Get dependencies above and make sure executables are on your path
- `npm install --global` (or `npm install && export PATH=$PATH:$(pwd)/node_modules/.bin`)
- `./configure`
- `ninja chrome`

#### Load

- For Chrome enable developer mode in `chrome://extensions` and load the unpacked extension from `build/chrome`
- For Firefox go to `about:debugging#addons` select "Load Temporary Add-on" and load the `build/chrome/manifest.json`

#### Test

Tests are written in [QUnit 1.11][17] and can only be run in Chrome/Chromium.
Open a console on background page and execute `Test()` or test a specific
module, e.g.  Farnell, with `Test('Farnell')`

Most of the tests are functional tests that require interaction with the
various distributor sites and they make a lot of network requests to test across
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

[kitspace chat]:https://riot.im/app/#/room/#kitspace:matrix.org
[output_scripts/kicad]:https://github.com/monostable/1clickBOM/blob/master/output_scripts/kicad
[eagle_bom_export.png]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/eagle_bom_export.png
[kicad_bom_export.png]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/kicad_bom_export.png
[youtube.png]:https://github.com/monostable/1clickBOM/blob/master/readme_images/youtube.png
[2]:https://github.com/monostable/1clickBOM/blob/master/examples/
[3]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/load_from_page.png
[5]:https://qunitjs.com/
[6]:https://github.com/monostable/1clickBOM/blob/master/LICENSE
[7]:https://github.com/monostable/1clickBOM
[8]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/chrome.png
[10]:https://github.com/monostable/1clickBOM/issues
[11]:mailto:info@1clickBOM.com
[12]:http://video.fosdem.org/2015/devroom-electronic_design_automation/one_click_bom.mp4
[15]:https://raw.githubusercontent.com/monostable/1clickBOM/master/readme_images/demo.gif
[16]:https://palant.de/2012/01/13/extension-auto-installer
[17]:https://web.archive.org/web/20130128010139/http://api.qunitjs.com/
[18]:https://developer.mozilla.org/en-US/Add-ons/SDK
[19]:http://1clickBOM.com
[20]:https://addons.mozilla.org/en-US/firefox/addon/1clickbom/
