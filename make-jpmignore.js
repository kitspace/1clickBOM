//adds exception for jpmignore for files actually used
'use strict'
const precinct = require('precinct')
const path = require('path')
const fs = require('fs')

let jpmIgnore = fs.readFileSync('src/firefox/.jpmignore');

let dir = path.dirname(process.argv[2]);

let getDeps = function(filePath) {
    let list = precinct.paperwork(filePath);
    let deps = [];
    for (let i = 0; i < list.length; i++) {
        let dep = list[i];
        if (RegExp('^./').test(dep)) {
            let file = `${dir}/${dep.slice(2)}.js`;
            deps.push(file);
            deps = deps.concat(getDeps(file));
        }
    }
    return deps;
};

let deps = getDeps(process.argv[2]);

deps.push(process.argv[2]);

deps = deps.reduce(function(prev, f) {
    if (!__in__(f, prev)) {
        prev.push(f);
    }
    return prev;
}
, []);

for (let i = 0; i < deps.length; i++) {
    let line = deps[i];
    jpmIgnore += line.replace('build/firefox/', '!') + '\n';
}

fs.writeFileSync('build/firefox/.jpmignore', jpmIgnore);

function __in__(needle, haystack) {
  return haystack.indexOf(needle) >= 0;
}
