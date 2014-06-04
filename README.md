# 1clickBOM #
#### _Paste to your electronic component shopping carts._ ####
1clickBOM is a browser extension with which you can automatically fill your
electronic component shopping carts at online retailers such as Digikey,
Mouser and Farnell; when you feed it correctly formatted TSV (tab seperated 
values). This allows you to simply paste data from a spreadsheet or share 
a TSV file with others.

## Which browsers? Which retailers? ##

For the time being the plugin is non-functional until we hit v0.1

Check the [roadmap][1] for planned support.

## Usage ##

### TSV Format ###
The format will remain compatible with the clip-board format of all major
spreadsheet programs. The tab character is used as a delimiter and values
need not be quoted. One line per component type should be ordered as follows:

    comment | quantity | vendor | part-number

Where ` | ` represents a tab character. The comment would usually be the
component references in your schematic and will be added as a note to your
shopping cart item where possible. See the [example tsv][2].

Eventually 1clickBOM will support multiple vendors per item which can be tacked
on to the end. For the time being the extra vendors will simply be ignored and
only the first vendor and part-number per line will be used.

    comment | quantity | vendor | part-number | vendor2 | part-number2 | vendor3 | ...
    
## Roadmap ##

* 0.1
    * Chrome support
    * Digikey, Mouser, Farnell , Newark, RS-Online and Allied
    * Allow clearing individual carts
    * Paste TSV or visit online .tsv file
    * Auto-merge multiple entries of the same component

* 0.2
    * Firefox support

* 0.3
    * Display cart summaries
    * Warn about filling already filled carts
    * Allow adding components to BOM from the component page
    * Export BOM

* 1.0
    * Function to minimize order cost + shipping
    * Allow for multiple vendors per item
    * Allow additional unused fields in TSV, named columns?
    * Autofind same items from different vendors

* 2.0 
    * Include PCB order

* 3.0 
    * 3D-chip-printer support

* 4.0
    * Communicate through quantum entanglement

## Development ##

### Build and Test Requirements ###

1clickBOM is written in [Coffeescript][4] which transpiles to Javascript. 
Currently development is done on Chromium and will later be ported to Firefox. 

### Build and Test Instructions ###

To transpile the coffeescript to javascript run `cake build` the chrome 
directory. Run `cake` with no arguments for help. The code can then be loaded
as an unpacked extension in the developer mode in Chrome/Chromium settings.

Unit and integration tests are written using the [QUnit framework][5]. Tests 
can be run by opening a javascript console on the background page and executing
the `Test()` function.
 
## License ##

1clickBOM is licensed under the AGPLv3. See the [COPYING][6] file for details.

[1]:#roadmap
[2]:chrome/data/example.tsv
[3]:chrome/html/test.html
[4]:http://coffeescript.org
[5]:https://qunitjs.com/
[6]:COPYING

