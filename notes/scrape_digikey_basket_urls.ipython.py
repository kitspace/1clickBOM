# coding: utf-8

import mechanize
br = mechanize.Browser()
br.open("http://www.digikey.com/us/en/international/global.html")
br.links
for l in br.links():
    print l
br.links()
for l in br.links():
    print l.url
import re
help(re.match)
for l in br.links():
    print l.url
l = http://www.digikey.vn
l = "http://www.digikey.vn
l = "http://www.digikey.vn"
re.match()
help(re.match)
re.match("http://.*digikey.*(?<!\/)", l)
l
l.append('/')
l += '/'
l
re.match("http://.*digikey.*(?<!\/)", l)
re.match("http://.*digokey.*(?<!\/)", l)
re.match("http://.*digoikey.*(?<!\/)", l)
re.match("http://.*digikey.*(?<!\/)", l)
re.match("http://.*digikey.*[^\/]", l)
re.match("http://.*digikey.*[^\\]", l)
re.match("http://.*digikey.*[^\\\]", l)
re.match("http://.*digikey.*[^/]", l)
re.match("http://.*digikey.*(?<!/)", l)
re.match("http://(.*)\/", l)
l.pop()
l = "http://www.digikey.vn"
re.match("http://(.*)\/", l)
links = []
for l in br.links():
    links.append.(l)
for l in br.links():
    links.append(l)
links
links = []
for l in br.links():
    links.append(l.url)
links
for l in links:
    if re.match("(.*)/(.*)"):
        print l
for l in links:
    if re.match("(.*)/(.*)", l):
        print l
for l in links:
    if re.match("http://(.*)/(.*)", l):
        print l
for l in links:
    if re.match("http://(.*)/(.+)", l):
        print l
for l in links:
    if re.match("http://(.*)/(.+)", l):
        links.remove(l)
links
links2 = []
for l in links:
    if re.match("http://(.*)digikey\.(.*)", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)[/]", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)(/)", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)/?", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)/?[^*]", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)/?[!*]", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)/?[^.*]", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)/?[^(.*)]", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)/?^(.*)", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)/?(^(.*))", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)/?[^(.*)]", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)/?.*[^/]", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)/?[^/]", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)/?$", l):   
        print l
for l in links:
    if re.match("http://(.*)digikey\.(.*)/?$", l):   
        links2.append(l)
l
links2
for l in links2:
    if re.match("http://(\w*)\.digikey(\w*)", l):
        print l
for l in links2:
    if re.match("http://(\w*)\.digikey\.(\w*)/", l):
        print l
for l in links2:
    if re.match("http://(\w*)\.digikey\.(\w*)/.+", l):
        print l
for l in links2:
    if re.match("http://(\w*)\.digikey\.(\w*)/.+", l):
        links2.remove(l)
links2
for l in links2:
    if re.match("http://(\w*)\.digikey\.(\w*)/.+", l):
        print l
for l in links2:
    if re.match("http://(\w*)\.digikey\.(\w*)/.+", l):
        links2.remove(l)
links2
for l in links2[:]:
    if re.match("http://(\w*)\.digikey\.(\w*)/.+", l):
        links2.remove(l)
links2
links2
links2.pop(0)
links2
f = open("digikey_international")
help(open)
file.__doc__
file.__doc__()
file.__doc__
links2
mechanize
br.open(links2[0])
r = br.open(links2[0])
r.geturl()
r.read()
br.links()
for l in br.links():
    print l
help(br.find_link)
import requests
r = requests.get(links2[0])
r
r.url
r.text()
r.text
r.json
r.json()
import soup
import beautifulsoup as soup
form HTMLParser import HTMLParser
from HTMLParser import HTMLParser
from bs3 import soup
import beautifulsoup3
import BeautifulSoup as soup
import BeautifulSoup as BS
soup = BS(r.content)
from BeautifulSoup import BeatifulSoup as soup
from BeautifulSoup import BeautifulSoup as BS
soup = BS(r.content)
help(soup.findChild)
soup.findChild("#navigation")
soup.findChild("div", {"id": "navigation})
soup.findChild("div", {"id": "navigation"})
nav = soup.findChild("div", {"id": "navigation"})
nav.find("a")
l = nav.find("a")
l.get()
l.getText()
l.text
l.get("href")
basket_links = []
for l in links2:
    r = request.get(l)
    soup = BS(r.content)
    nav = soup.findChild("div", {"id": "navigation"})
    a = nav.find("a")
    url = a.get("href")
    basket_links.append(url)
for l in links2:
    r = requests.get(l)
    soup = BS(r.content)
    nav = soup.findChild("div", {"id": "navigation"})
    a = nav.find("a")
    url = a.get("href")
    basket_links.append(url)
basket_links
basket_links = []
for l in links2:
    print "requesting: ", l;r = requests.get(l)
    soup = BS(r.content)
    nav = soup.findChild("div", {"id": "navigation"})
    a = nav.find("a")
    url = a.get("href"); print url
    basket_links.append((l,url))
r = requests.post('http://uk.farnell.com/pffind/SuggestionLookupServlet?lookaheadSearchTerms=1645325')
r = requests.get("http://www.digikey.by/")
soup = BS(r.content)
nav = soup.findChild("div", {"id": "navigation"})
nav
a = nav.find("a")
a
url = a.get("href")
url
nav = soup.findChild("div", {"id": "navigation"})
nav
for l in links2:
    print "requesting: ", l;r = requests.get(l)
    soup = BS(r.content)
    nav = soup.findChild("div", {"id": "navigation"})
    a = nav.find("a")
    url = a.get("href"); print url
    basket_links.append((l,url))
a
nav
nav.find("a", {"id":})
nav.find("a", {"id":""})
nav.find("a", {"id":"quickbuy_link"})
nav.find("a", {"id":"quickbuy-link"})
r = requests.get("http://www.digikey.be/")
soup = BS(r.content)
nav = soup.findChild("div", {"id": "navigation"})
nav.find("a", {"id":"quickbuy_link"})
nav.find("a", {"id":"quickbuy-link"})
nav.find("a", {"id":""})
nav.find("a", {"id":"quickbuy-link"}):
a = nav.find("a")
a
if a.has_key("id")
if a.has_key("id"):
    print a
if a.has_key("id"):
    print a.next
if a.has_key("id"):
    print a.next("a")
if a.has_key("id"):
    print a.nextSibling()
if a.has_key("id"):
    print a.nextSibling
if a.has_key("id"):
    print a.findNext("a")
if a.get("id") == "quickbuy-link":
    print a.findNext("a")
if a.get("id") == "quickbuy-link":
    a = a.findNext("a")
a
for l in links2:
    print "requesting: ", l;r = requests.get(l)
    soup = BS(r.content)
    nav = soup.findChild("div", {"id": "navigation"})
    a = nav.find("a"); if a.get("id") == "quickbuy-link":;a = findNext("a");
    url = a.get("href"); print url
    basket_links.append((l,url))
for l in links2:
    print "requesting: ", l;r = requests.get(l)
    soup = BS(r.content)
    nav = soup.findChild("div", {"id": "navigation"})
    a = nav.find("a"); a = findNext("a") if a.get("id") == "quickbuy-link";
    url = a.get("href"); print url
    basket_links.append((l,url))
for l in links2:
    print "requesting: ", l;r = requests.get(l)
    soup = BS(r.content)
    nav = soup.findChild("div", {"id": "navigation"})
    a = nav.find("a"); a = (a.findNext("a")) if (a.get("id") == "quickbuy-link");
    url = a.get("href"); print url
    basket_links.append((l,url))
get_ipython().magic(u'paste')
for l in links2:
        print "requesting: ", l;r = requests.get(l)
        soup = BS(r.content)
        nav = soup.findChild("div", {"id": "navigation"})
        a = nav.find("a") 
        print "a1: ", a
        if a.get("id") == "quickbuy-link":
                a = a.findNext("a")
            print "a2: ",
            url = a.get("href"); print url
            basket_links.append((l,url))
get_ipython().magic(u'paste')
get_ipython().magic(u'paste')
get_ipython().magic(u'paste ')
get_ipython().magic(u'paste ')
get_ipython().magic(u'paste ')
basket_links
get_ipython().magic(u'paste ')
get_ipython().system(u'ls -F --color ')
get_ipython().magic(u'paste ')
get_ipython().magic(u'paste ')
basket_links = []
get_ipython().magic(u'paste ')
basket_links
get_ipython().magic(u'save scrape_digikey_basket_urls.ipy 0-184')