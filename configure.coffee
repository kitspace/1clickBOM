#!/usr/bin/env coffee
fs      = require('fs')
globule = require('globule')
path    = require('path')
cp      = require('child_process')
ninjaBuildGen = require('./ninja-build-gen')

browserify = 'browserify --debug --extension=".coffee" --transform coffeeify'
coffee     = 'coffee -m -c'

targets = {firefox:[], chrome:[]}

ninja = ninjaBuildGen('1.5.1', 'build/')
ninja.header("#generated from #{path.basename(module.filename)}")

#- Rules -#

ninja.rule('copy').run('cp $in $out')

#browserify and put dependency list in $out.d in makefile format using
#relative paths
ninja.rule('browserify')
    .run("echo -n '$out: ' > $out.d && #{browserify} $in --list
        | sed 's!#{__dirname}/!!' | tr '\\n' ' '
        >> $out.d && #{browserify} $in -o $out")
    .depfile('$out.d')
    .description("#{browserify} $in -o $out")


ninja.rule('coffee')
    .run("#{coffee} -o $dir $in")


#- Lists of Files -#

sourceCoffee = (browser) ->
    globule.find([
        "src/#{browser}/coffee/*.coffee"
        'src/common/coffee/*.coffee'
    ])

sourceJs = (browser) ->
    globule.find([
        "src/#{browser}/libs/*.js"
        'src/common/libs/*.js'
    ])

sourceFiles = (browser) ->
    sourceCoffee(browser).concat(sourceJs(browser))

copyFiles = (browser) ->
    globule.find([
        "src/#{browser}/html/*"
        "src/#{browser}/images/*"
        "src/#{browser}/data/*.json"
        'src/common/html/*'
        'src/common/images/*'
        'src/common/data/*.json'
    ])

#- Edges -#

browserifyEdge = (target, browser, layer) ->
    ninja.edge(target)
        .from("build/.temp-#{browser}/#{layer}.coffee")
        .after(sourceFiles(browser)
            .map (f) ->
                f.replace(/src\/.*?\/.*?\//, "build/.temp-#{browser}/")
        ).using('browserify')
    targets[browser].push(target)

for layer in ['main', 'popup']
    browserifyEdge("build/chrome/js/#{layer}.js", 'chrome', layer)

browserifyEdge('build/firefox/data/popup.js', 'firefox', 'popup')

for f in sourceCoffee('firefox')
    target = f.replace(/src\/.*?\/.*?\//, 'build/firefox/lib/')
        .replace('.coffee', '.js')
    dir = path.dirname(target)
    ninja.edge(target).assign('dir', dir).from(f).using('coffee')
    targets['firefox'].push(target)

for browser,list of targets
    for f in sourceFiles(browser)
        target = f.replace(/src\/.*?\/.*?\//, "build/.temp-#{browser}/")
        ninja.edge(target).from(f).using('copy')
        targets[browser].push(target)

    ninja.edge(browser).from(list)

ninja.edge('all').from(browser for browser of targets)
ninja.byDefault('all')

ninja.rule('remove').run('rm -rf $in')
ninja.edge('clean').from('build/').using('remove')

ninja.save('build.ninja')

console.log('generated build.ninja')
