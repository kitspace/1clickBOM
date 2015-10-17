fs = require 'fs'

countries = JSON.parse(fs.readFileSync('src/common/data/countries.json', 'utf8'))
packageJ  = JSON.parse(fs.readFileSync('src/firefox/package.json', 'utf8'))

options = []
for name, code of countries
    options.push({label: name, value: code})

packageJ.preferences[0].options = options

packageJ.version = process.argv[2]

fs.writeFileSync('build/firefox/package.json', JSON.stringify(packageJ))
