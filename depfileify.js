//turn a list of files into depfile in makefile format
'use strict'
const fs = require('fs');

let target = process.argv[2];
let filePath = process.argv[3];

let deps = fs.readFileSync(filePath, 'utf8');

let relativeDeps = [];
let iterable = deps.split('\n');
for (let i = 0; i < iterable.length; i++) {
    let dep = iterable[i];
    relativeDeps.push(dep.replace(__dirname + '/', ''));
}

let out = target + ': ' + relativeDeps.join(' ');

fs.writeFileSync(filePath, out);
