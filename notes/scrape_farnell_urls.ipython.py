# coding: utf-8

from bs4 import BeautifulSoup as BS
import requests
import re
r = requests.get("http://www.farnell.com/")
soup = BS(r.content)
soup = BS(r.content)
soup.find_all("a", {"class": re.compile(r"flag-back(.*)")})
for a in soup.find_all("a", {"class": re.compile(r"flag-back(.*)")}):
    print a.get("href")
for a in soup.find_all("a", {"class": re.compile(r"flag-back(.*)")}):
    print a.get("href").split("?")[0]
for a in soup.find_all("a", {"class": re.compile(r"flag-back(.*)")}):
    print a.get("href").split("?")[0]
links = []
for a in soup.find_all("a", {"class": re.compile(r"flag-back(.*)")}):
    link.append(a.get("href").split("?")[0])
for a in soup.find_all("a", {"class": re.compile(r"flag-back(.*)")}):
    links.append(a.get("href").split("?")[0])
links
http://uk.farnell.com/jsp/shoppingCart/quickPaste.jsp?_DARGS=/jsp/shoppingCart/fragments/quickPaste/quickPaste.jsp.quickpaste&%2Fpf%2Fcommerce%2Forder%2FQuickPaste.addPasteProducts=Add%20To%20Basket&%2Fpf%2Fcommerce%2Forder%2FQuickPaste.buyErrorURL=%2Fjsp%2FshoppingCart%2FquickPaste.jsp&%2Fpf%2Fcommerce%2Forder%2FQuickPaste.buySuccessURL=%2Fjsp%2FshoppingCart%2FshoppingCart.jsp&_D%3A%2Fpf%2Fcommerce%2Forder%2FQuickPaste.addPasteProducts=%20&_D%3A%2Fpf%2Fcommerce%2Forder%2FQuickPaste.buyErrorURL=%20&_D%3A%2Fpf%2Fcommerce%2Forder%2FQuickPaste.buySuccessURL=%20&_D%3AsubmitQuickPaste=%20&_D%3AtextBox=%20&_DARGS=%2Fjsp%2FshoppingCart%2Ffragments%2FquickPaste%2FquickPaste.jsp.quickpaste&_dyncharset=UTF-8&textBox=2009284%2C%201%2C%20DOLLA