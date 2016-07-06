"""
    @package
"""

from __future__ import print_function

# Import the KiCad python helper module and the csv formatter
import kicad_netlist_reader
import csv
import sys
import os

def myEqu(self, other):
    """myEqu is a more advanced equivalence function for components which is
    used by component grouping. Normal operation is to group components based
    on their value and footprint.

    In this example of a custom equivalency operator we compare the
    value, the part name and the footprint.

    """
    result = True
    if self.getValue() != other.getValue():
        result = False
    elif self.getPartName() != other.getPartName():
        result = False
    elif self.getFootprint() != other.getFootprint():
        result = False

    return result

# Override the component equivalence operator - it is important to do this
# before loading the netlist, otherwise all components will have the original
# equivalency operator.
kicad_netlist_reader.comp.__eq__ = myEqu

if len(sys.argv) != 3:
    print("Usage ", __file__, "<generic_netlist.xml> <output.csv>", file=sys.stderr)
    sys.exit(1)


# Generate an instance of a generic netlist, and load the netlist tree from
# the command line option. If the file doesn't exist, execution will stop
net = kicad_netlist_reader.netlist(sys.argv[1])

# Open a file to write to, if the file cannot be opened output to stdout
# instead
path = os.path.dirname(sys.argv[2]) + os.sep + "1-click-bom.tsv"
try:
    f = open(path, "w")
except IOError:
    e = "Can't open output file for writing: " + path
    print(__file__, ":", e, sys.stderr)
    f = sys.stdout

# subset the components to those wanted in the BOM, controlled
# by <configure> block in kicad_netlist_reader.py
components = net.getInterestingComponents()

compfields = net.gatherComponentFieldUnion(components)
partfields = net.gatherLibPartFieldUnion()

# remove Reference, Value, Datasheet, and Footprint, they will come from 'columns' below
partfields -= set( ['Reference', 'Value', 'Datasheet', 'Footprint'] )

columnset = compfields | partfields     # union

# prepend an initial 'hard coded' list and put the enchillada into list 'columns'
columns = ['References', 'Qty'] + sorted(list(columnset))

# Create a new csv writer object to use as the output formatter
out = csv.writer(f, lineterminator="\n", delimiter="\t", quotechar="\"", quoting=csv.QUOTE_MINIMAL)

# override csv.writer's writerow() to support encoding conversion (initial encoding is utf8):
def writerow( acsvwriter, columns ):
    utf8row = []
    for col in columns:
        utf8row.append( str(col) )  # currently, no change
    acsvwriter.writerow( utf8row )

writerow( out, columns )                   # reuse same columns



# Get all of the components in groups of matching parts + values
# (see kicad_netlist_reader.py)
grouped = net.groupComponents(components)


# Output component information organized by group, aka as collated:
item = 0
for group in grouped:
    row = []
    refs = ""
    c = group[0]

    # Add the reference of every component in the group and keep a reference
    # to the component so that the other data can be filled in once per group
    refs = c.getRef()
    for component in group[1:]:
        refs += ", " + component.getRef()

    # Fill in the component groups common data
    # columns = ['Reference(s)', 'Qty'] + sorted(list(columnset))
    item += 1
    row.append( refs );
    row.append( len(group) )

    # from column 2 upwards, use the fieldnames to grab the data
    for field in columns[2:]:
        row.append( net.getGroupField(group, field) );

    writerow( out, row  )

f.close()
