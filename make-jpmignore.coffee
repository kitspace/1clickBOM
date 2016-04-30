#adds exception for jpmignore for files actually used
precinct = require('precinct')
path = require('path')
fs = require('fs')

jpmIgnore = fs.readFileSync('src/firefox/.jpmignore')

dir = path.dirname(process.argv[2])

getDeps = (filePath) ->
    list = precinct.paperwork(filePath)
    deps = []
    for dep in list
        if RegExp('^./').test(dep)
            file = "#{dir}/#{dep.slice(2)}.js"
            deps.push(file)
            deps = deps.concat(getDeps(file))
    return deps

deps = getDeps(process.argv[2])

deps.push(process.argv[2])

deps = deps.reduce (prev, f) ->
    if f not in prev
        prev.push(f)
    return prev
, []

for line in deps
    jpmIgnore += line.replace('build/firefox/', '!') + '\n'

fs.writeFileSync('build/firefox/.jpmignore', jpmIgnore)
