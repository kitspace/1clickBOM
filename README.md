# 1-click BOM #
####_Automatically populate your electronic component shopping carts._####
1-click BOM is a browser extension which fills your electronic component shopping carts, at online retailers such as Digikey, Mouser and Farnell, when you feed it correctly formatted tab-seperated-values (TSV). This allows you to simply paste data from your bill of materials (BOM) spreadsheet or share a TSV file so others can make the same order locally.

## Which browsers? Which retailers?##

For the time being the plugin is non-functional until we hit v0.0.1

Check the [roadmap](#roadmap) for planned support.

## Usage ##

### TSV Format ###
The format will remain compatible with the clip-board TSV format of all major spreadsheet programs. The tab character is used as a delimiter and values need not be quoted. One line per component type should be ordered as follows:

    comment | quantity | vendor | part-number

Where ``` | ``` represents a tab character. The comment would usually be the component references in your schematic and will be added as a note to your shopping cart item where possible.
See the [example tsv](chrome/data/example.tsv).

Eventually 1-click BOM will support multiple vendors per item which can be tacked on to the end. For the time being the extra vendors will simply be ignored and only the first vendor and part-number per line will be used.

    comment | quantity | vendor | part-number | vendor2 | part-number2 | vendor3 | ...


## Roadmap ##

* 0.0.1
    * Chrome support
    * Digikey, Mouser, Farnell/Element14, Newark, Allied and RS-Online
    * Allow clearing individual carts 
    * Paste TSV or visit online .tsv file 

* 0.1.0
    * Firefox support
    * Maybe IE support?

* 0.2.0
    * Display cart summaries
    * Warn about filling already filled carts
    * Checkout button
    * Handling of logins
    * Auto-merge multiple entries of the same component

* 1.0.0
    * Allow for multiple vendors per item
    * Allow additional unused fields in TSV, named columns?
    * Autofind same items from different vendors
    * Function to minimize order cost + shipping
    * Allow outputting cost-optimized TSV BOM with multiple sources

* 2.0.0 
    * Include PCB order? 

## Development ##

### Build and Test Requirements ###

1-click BOM is written in Coffeescript which compiles to Javascript. 

Currently development is done in Chrome and then ported to Firefox. Unit and integration tests are written using the QUnit framework see the [chrome/html/test.html](https://github.com/kasbah/1clickBOM/blob/master/chrome/html/test.html) file for details. 

* Coffeescript
* QUnit

### Build and Test Instructions ###
 
## License ##

1-click BOM code is licensed under the AGPLv3. The name 1-click BOM, 1clickBOM.com and the BOM-chip logos are trademarks of Kaspar Emanuel

