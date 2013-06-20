# 1-click BOM #
###_Automatically populate your electronic component shopping carts._###
1-click BOM is a browser extension which fills your electronic component shopping carts, at online retailers such as Digikey, Mouser and Farnell, when you feed it correctly formatted tab-seperated-values (TSV). This allows you to simply paste data from your bill of materials (BOM) spreadsheet or share a TSV file so others can make the same order locally.

## Support ##
Currently supported browsers are:

* Chrome

Supported retailers are:

* Digikey

## Usage ##

### TSV Format ###
The format will remain compatible with the clip-board TSV format of all major spreadsheet programs. The tab character is used as a delimiter and values need not be quoted. One line per component type should be ordered as follows:

comment | quantity | vendor | part-number

Here is an example BOM from [my nomech_mini project](https://github.com/kasbah/nomech_mini): 

	CON1	1	Farnell	1645325
	D17,D14,D13,D10,D9,D6,D5,D2,D1,D15,D11,D7,D3,D4,D8,D12,D16	17	Digikey	754-1173-2-ND
	X1	1	Farnell	1841946
	C11,C1,C12,C2,C6,C19	6	Farnell	1759143
	C13,C14,C20	3	Farnell	1759246
	R2,R3,R12,R15,R10,R4,R8,R6	8	Farnell	2074332
	C4	1	Farnell	2281021
	C9,C8	2	Farnell	2310644
	R1,R23,R20,R24,R18,R22,R17,R19,R34,R31,R35,R30,R29,R28,R36,R25,R37	17	Farnell	2073977
	L1,L2	2	Farnell	6347060
	C7,C10,C3,C5	4	Farnell	1759241
	C18,C15,C16,C17	4	Farnell	1759226
	R16,R11,R14,R5	4	Farnell	1576507
	R9,R21,R27,R33,R39,R7	6	Farnell	2078943
	R13	1	Farnell	2078962
	Q1,Q2,Q4,Q3	4	Farnell	2191746
	U1	1	Farnell	1748525
	R26,R32,R38,R40	4	Farnell	2074469

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

