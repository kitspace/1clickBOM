# 1-click BOM #
####_Automatically populate your electronic component shopping carts._####
1-click BOM is a browser extension which fills your electronic component shopping carts, at online retailers such as Digikey, Mouser and Farnell, when you feed it correctly formatted tab-seperated-values (TSV). This allows you to simply paste data from your bill of materials (BOM) spreadsheet or share a TSV file so others can make the same order locally.

## Which browsers? Which retailers?##
Currently supported browsers are:

* Chrome

Supported retailers are:

* Digikey

Check the [roadmap](#roadmap) for planned support.

## Usage ##

### TSV Format ###
The format will remain compatible with the clip-board TSV format of all major spreadsheet programs. The tab character is used as a delimiter and values need not be quoted. One line per component type should be ordered as follows:

comment | quantity | vendor | part-number

Here is an [example BOM]((https://raw.github.com/kasbah/nomech_mini/nomech_mini-BOM.tsv) from one of my projects.

Eventually 1-click BOM will support multiple vendors per item which can be tacked on to the end like so:

comment | quantity | vendor | part-number | vendor2 | part-number2 | vendor3 | ...


## Roadmap ##

* 0.0.1
    * Chrome support
    * Digikey, Mouser, Farnell, Element14, Allied and RS-Online
    * Allow clearing individual carts 
    * Paste TSV or visit online .tsv file 
	* Auto-merge multiple entries of the same component

* 0.1.0
    * Firefox support

* 0.2.0
    * Display cart summaries
    * Warn about filling already filled carts
    * Checkout button
    * Unify handling of Farnell and Element14
    * Handling of logins

* 0.3.0
    * Online service for hosting TSV BOMs

* 1.0.0
    * Allow for multiple vendor defenitions
    * Function to minimize order cost + shipping
	* Allow outputting cost-optimized TSV BOM with multiple sources

* 2.0.0 
    * Include PCB order? 

 
## License ##

1-click BOM code is licensed under the AGPLv3. The name 1-click BOM, 1clickBOM.com and the BOM chip logos are trademarks of Kaspar Emanuel

