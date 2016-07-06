#
# Python script to generate a 1-click-bom.tsv
#

"""
    @package
    Generate a 1-click BOM merging known fields into a description column for use with auto-completing.
"""
# Import the KiCad python helper module and the csv formatter
import kicad_netlist_reader
import csv
import sys
import os

# Generate an instance of a generic netlist, and load the netlist tree from
# the command line option. If the file doesn"t exist, execution will stop
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

# Create a new csv writer object to use as the output formatter
out = csv.writer(f, lineterminator="\n", delimiter="\t", quotechar="\"", quoting=csv.QUOTE_MINIMAL)

out.writerow(["References", "Qty", "Description", ])

# Get all of the components in groups of matching parts + values
# (see kicad_netlist_reader.py)
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
    if c.getFootprint() != "":
        description += " " + c.getFootprint().split(":")[-1]

    description = description.replace("_", " ").replace(":", " ")

    words = description.split(" ")

    #we reverse to remove the duplicates starting from the end
    words.reverse()
    for word in words:
        while words.count(word) > 1:
            words.remove(word)
        if word == "":
            words.remove(word)
    words.reverse()

    description = " ".join(words)

    # Fill in the component groups common data
    out.writerow([refs, len(group), description])

print("generated %s" % path)
