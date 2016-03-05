#
# Python script to generate a 1-click-BOM.tsv
#

"""
    @package
    Generate a 1-click-BOM
"""
# Import the KiCad python helper module and the csv formatter
import kicad_netlist_reader
import csv
import sys

retailers = ['Digikey', 'Mouser', 'RS', 'Newark', 'Farnell']

retailer_aliases = {
    'Farnell'            : 'Farnell'
    , 'FEC'                : 'Farnell'
    , 'Premier'            : 'Farnell'
    , 'element14'          : 'Farnell'
    , 'Digi(-| )?key'      : 'Digikey'
    , 'Mouser'             : 'Mouser'
    , 'RS'                 : 'RS'
    , 'RS(-| )?Online'     : 'RS'
    , 'RS(-| )?Delivers'   : 'RS'
    , 'Radio(-| )?Spares'  : 'RS'
    , 'RS(-| )?Components' : 'RS'
    , 'Newark'             : 'Newark'
}


# Generate an instance of a generic netlist, and load the netlist tree from
# the command line option. If the file doesn't exist, execution will stop
net = kicad_netlist_reader.netlist(sys.argv[1])

# Open a file to write to, if the file cannot be opened output to stdout
# instead

path = sys.argv[2] + '-1-click-BOM.tsv'
try:
    f = open(path, 'w')
except IOError:
    e = "Can't open output file for writing: " + path
    print(__file__, ":", e, sys.stderr)
    f = sys.stdout

# Create a new csv writer object to use as the output formatter
out = csv.writer(f, lineterminator='\n', delimiter='\t', quotechar='\"', quoting=csv.QUOTE_ALL)

out.writerow(['References', 'Qty', 'Description'])

# Get all of the components in groups of matching parts + values
# (see ky_generic_netlist_reader.py)
grouped = net.groupComponents()


# Output all of the component information
for group in grouped:
    # Add the reference of every component in the group and keep a reference
    # to the component so that the other data can be filled in once per group
    c = group[0]

    refs = c.getRef()
    for component in group[1:]:
        refs += ", " + component.getRef()

    description = c.getPartName()
    if c.getValue() != "":
        description += " " + c.getValue()
    if c.getDescription() != "":
        description += " " + c.getDescription()

    # Fill in the component groups common data
    out.writerow([refs, len(group), description])
