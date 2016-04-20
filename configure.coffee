#!/usr/bin/env coffee
fs      = require('fs')
globule = require('globule')
path    = require('path')
cp      = require('child_process')
ninjaBuildGen = require('ninja-build-gen')

version = "0.6.2"

browserify = 'browserify -x $exclude --debug --extension=".coffee" --transform coffeeify'

coffee = 'coffee -m -c'

ninja = ninjaBuildGen('1.5.1', 'build/')

ninja.header("#generated from #{path.basename(module.filename)}")

#- Rules -#

ninja.rule('copy').run('cp $in $out')


#browserify and put dependency list in $out.d in makefile format using
#relative paths
ninja.rule('browserify')
    .run("#{browserify} $in --list > $out.d
        && coffee ./depfileify.coffee $out $out.d
        && #{browserify} $in -o $out")
    .depfile('$out.d')
    .description("browserify $in -o $out")

ninja.rule('browserify-require')
    .run("#{browserify} --require='./$in' --list > $out.d
        && coffee ./depfileify.coffee $out $out.d
        && #{browserify} --require='./$in' -o $out")
    .depfile('$out.d')
    .description("browserify $in -o $out")

ninja.rule('coffee')
    .run("#{coffee} -o $dir $in")


ninja.rule('sed').run("sed 's$regex' $in > $out")


ninja.rule('remove').run('rm -rf $in')


#- Lists of Files -#

sourceCoffee = (browser) ->
    globule.find([
        "src/#{browser}/coffee/**/*.coffee"
        'src/common/coffee/**/*.coffee'
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
        "src/#{browser}/libs/*.css"
        'src/common/html/*'
        'src/common/images/*'
        'src/common/data/*.json'
    ])

#- Edges -#

targets = {firefox:[], chrome:[]}

browserifyEdge = (target, browser, layer, exclude='') ->
    ninja.edge(target)
        .from("build/.temp-#{browser}/#{layer}.coffee")
        .assign('exclude', exclude)
        .after(sourceFiles(browser)
            .map (f) ->
                "build/.temp-#{browser}/#{path.basename(f)}"
        ).using('browserify')
    targets[browser].push(target)


for layer in ['main', 'popup', 'options', 'kitnic']
    browserifyEdge("build/chrome/js/#{layer}.js", 'chrome', layer)


browserifyEdge('build/firefox/data/popup.js', 'firefox', 'popup')


for file in sourceJs('firefox')
    target = "build/firefox/lib/#{path.basename(file)}"
    ninja.edge(target).from(file).using('copy')
    targets.firefox.push(target)


for f in sourceCoffee('firefox')
    target = f.replace(/src\/.*?\/.*?\//, 'build/firefox/lib/')
        .replace('.coffee', '.js')
    dir = path.dirname(target)
    ninja.edge(target).assign('dir', dir).from(f).using('coffee')
    targets['firefox'].push(target)


for browser,list of targets
    for f in sourceFiles(browser)
        target = "build/.temp-#{browser}/#{path.basename(f)}"
        ninja.edge(target).from(f).using('copy')
        list.push(target)


qunitSrc = 'build/.temp-chrome/qunit-1.11.0.js'
ninja.edge('build/chrome/js/qunit.js').from(qunitSrc)
    .using('browserify-require')
targets.chrome.push('build/chrome/js/qunit.js')


ninja.edge('build/chrome/js/unit.js').from('build/.temp-chrome/unit.coffee')
    .assign('exclude', qunitSrc)
    .using('browserify')
targets.chrome.push('build/chrome/js/unit.js')


ninja.edge('build/chrome/js/functional.js').from('build/.temp-chrome/functional.coffee')
    .assign('exclude', qunitSrc)
    .using('browserify')
targets.chrome.push('build/chrome/js/functional.js')


for f in copyFiles('chrome')
    target = f.replace(/src\/.*?\//, "build/chrome/")
    ninja.edge(target).from(f).using('copy')
    targets.chrome.push(target)


for f in copyFiles('firefox')
    target = f.replace(/src\/.*?\//, "build/firefox/data/")
    ninja.edge(target).from(f).using('copy')
    targets.firefox.push(target)


for browser,list of targets
    ninja.edge(browser).from(list)


manifest = 'build/chrome/manifest.json'
ninja.edge(manifest).from(manifest.replace('build','src'))
    .assign('regex',"/@version/\"#{version}\"/").using('sed')
targets.chrome.push(manifest)


ninja.rule('make-package-json')
    .run("coffee make-package-json.coffee #{version}")
ninja.edge('build/firefox/package.json')
    .from(['src/common/data/countries.json','src/firefox/package.json', 'package.json'])
    .using('make-package-json')
targets.firefox.push('build/firefox/package.json')

chrome_package_name = "1clickBOM-v#{version}-chrome"
ninja.rule('package-chrome')
    .run("cd build/ && cp -r chrome  #{chrome_package_name} &&
        rm -rf #{chrome_package_name}/js/{functional,unit,qunit}.js
            #{chrome_package_name}/html/test.html #{chrome_package_name}/libs &&
        zip -r #{chrome_package_name}.zip #{chrome_package_name}/ &&
        rm -rf #{chrome_package_name}")
ninja.edge("#{chrome_package_name}.zip").need('chrome').using('package-chrome')
ninja.edge('package-chrome').need("#{chrome_package_name}.zip")


ninja.rule('npm-install').run('cd build/firefox/ && npm install')
ninja.edge('build/firefox/node_modules').from('build/firefox/package.json').using('npm-install')
targets.firefox.push('build/firefox/node_modules')

ninja.rule('make-jpmignore').run("coffee make-jpmignore.coffee $in")
ninja.edge('build/firefox/.jpmignore').from('build/firefox/lib/main.js')
    .need(['src/firefox/.jpmignore', 'make-jpmignore.coffee'])
    .using('make-jpmignore')
targets.firefox.push('build/firefox/.jpmignore')

firefox_package = "build/1clickBOM-v#{version}-firefox.xpi"
ninja.rule('package-firefox')
    .run("jpm xpi --addon-dir=#{__dirname}/build/firefox
        && mv build/firefox/*.xpi $out && echo 'moved to #{firefox_package}'")
ninja.edge(firefox_package).need('firefox').using('package-firefox')
ninja.edge('package-firefox').need(firefox_package)


ninja.edge('all').from(browser for browser of targets)
ninja.byDefault('all')

ninja.edge('clean').from('build/').using('remove')

ninja.save('build.ninja')

console.log('generated build.ninja')
