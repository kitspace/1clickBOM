import json
import urllib
import pprint
pp = pprint.PrettyPrinter(indent=4)

url = "http://octopart.com/api/v3/parts/search"

# NOTE: Use your API key here (https://octopart.com/api/register)
url += "?apikey=CHANGE_ME

args = [
        ('q', ''),
        ('start', 0),
        ('limit', 100),
        ('filter[queries][]', 'offers.seller.name:Digi-Key')
        ]

url += '&' + urllib.urlencode(args)

data = urllib.urlopen(url).read()
search_response = json.loads(data)

# print number of hits
print search_response['hits']

# print results
for result in search_response['results']:
    part = result['item']
    for offer in part['offers']:
        if offer['seller']['name'] == "Digi-Key":
            print offer['sku']

