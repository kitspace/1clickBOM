'use strict'
const fs = require('fs');

let countries = JSON.parse(fs.readFileSync('src/common/data/countries.json', 'utf8'));
let firefoxPackageJ  = JSON.parse(fs.readFileSync('src/firefox/package.json', 'utf8'));
let packageJ  = JSON.parse(fs.readFileSync('./package.json', 'utf8'));

let options = [];
for (let name in countries) {
    let code = countries[name];
    options.push({label: name, value: code});
}

firefoxPackageJ.dependencies = packageJ.dependencies;

firefoxPackageJ.preferences[0].options = options;

firefoxPackageJ.version = process.argv[2];

fs.writeFileSync('build/firefox/package.json', JSON.stringify(firefoxPackageJ));
