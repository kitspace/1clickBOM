# coding: utf-8

import pycountry
def lookup(code):
    return pycountry.countries.get(alpha2=code)
import json
help(json.loads)
help(json.load)
help(json.loads)
list = json.load("../chrome/data/countries.json")
list = json.load(open("../chrome/data/countries.json"))
list
for c in list:
    print lookup(c)
lookup("UK")
lookup("GB")
for c in list:
    print c, " : ", lookup(c)
def lookup(code):
    return pycountry.countries.get(alpha2=code)
lookup("AE")
def lookup(code):
    return pycountry.countries.get(alpha2=code).name
lookup("AE")
for c in list:
    try:
        name = lookup(c)
    except:
        name = ""
    print c, " : ", name ","
for c in list:
    try:
        name = lookup(c)
    except:
        name = ""
    print c, " : ", name, ","
fg
for c in list:
    try:
        name = lookup(c)
    except:
        name = ""
    print '"', c, '" : ', '"'name, '",'
for c in list:
    try:
        name = lookup(c)
    except:
        name = ""
    print '"', c, '" : "', name, '",'
for c in list:
    try:
        name = lookup(c)
    except:
        name = ""
    print '"', c, '":"', name, '",'
for c in list:
    try:
        name = lookup(c)
    except:
        name = ""
    print '"'+ c + '":"' +  name + '",'
help(save)