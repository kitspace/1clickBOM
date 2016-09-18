#!/usr/bin/env node
'use strict'
const fs      = require('fs')
const globule = require('globule')
const path    = require('path')
const cp      = require('child_process')
const ninjaBuildGen = require('ninja-build-gen')

const version = "1.1.5"

const ninja = ninjaBuildGen('1.5.1', 'build/')
ninja.header(`#generated from ${path.basename(module.filename)}`)

const presets = "--presets es2015-script"
const browserify = `browserify -x $exclude --debug --transform [ babelify ${presets} ]`

//- Rules -#

ninja.rule('copy').run('cp $in $out')

ninja.rule('babel').run(`babel ${presets} $in -o $out`)

//browserify and put dependency list in $out.d in makefile format using
//relative paths
ninja.rule('browserify')
    .run(`${browserify} $in --list > $out.d `
         + `&& node ./depfileify.js $out $out.d && ${browserify} $in -o $out`)
    .depfile('$out.d')
    .description("browserify $in -o $out")

ninja.rule('browserify-require')
    .run("browserify --require='./$in' --list > $out.d"
         + "&& node ./depfileify.js $out $out.d && browserify --require='./$in' -o $out")
    .depfile('$out.d')
    .description("browserify $in -o $out")


ninja.rule('sed').run("sed 's$regex' $in > $out")


ninja.rule('remove').run('rm -rf $in')


//- Lists of Files -#

const sourceJs = browser =>
    globule.find([
        `src/${browser}/js/**/*.js`,
        'src/common/js/*.js'
    ])


const copyFiles = browser =>
    globule.find([
        `src/${browser}/html/*`,
        `src/${browser}/images/*`,
        `src/${browser}/data/*.json`,
        'src/common/html/*',
        'src/common/images/*',
        'src/common/data/*.json'
    ])


//- Edges -#

const targets = {firefox:[], chrome:[]}

const browserifyEdge = function(target, browser, layer, exclude='') {
    ninja.edge(target)
        .from(`build/.temp-${browser}/${layer}.js`)
        .assign('exclude', exclude)
        .after(sourceJs(browser).map(f => `build/.temp-${browser}/${path.basename(f)}`))
        .using('browserify')
    return targets[browser].push(target)
}


const iterable = ['main', 'popup', 'options', 'kitnic']
for (let i = 0; i < iterable.length; i++) {
    const layer = iterable[i]
    browserifyEdge(`build/chrome/js/${layer}.js`, 'chrome', layer)
}


browserifyEdge('build/firefox/data/popup.js', 'firefox', 'popup')
browserifyEdge('build/firefox/data/kitnic.js', 'firefox', 'kitnic')


const firefox_js = []
const iterable1 = sourceJs('firefox')
for (let j = 0; j < iterable1.length; j++) {
    const file = iterable1[j]
    const target = `build/firefox/lib/${path.basename(file)}`
    ninja.edge(target).from(file).using('babel')
    firefox_js.push(target)
    targets.firefox.push(target)
}


for (let browser in targets) {
    const list = targets[browser]
    const iterable2 = sourceJs(browser)
    for (let k = 0; k < iterable2.length; k++) {
        const f = iterable2[k]
        const target = `build/.temp-${browser}/${path.basename(f)}`
        ninja.edge(target).from(f).using('copy')
        list.push(target)
    }
}


const qunitSrc = 'build/.temp-chrome/qunit-1.11.0.js'
ninja.edge('build/chrome/js/qunit.js').from(qunitSrc)
    .using('browserify-require')
targets.chrome.push('build/chrome/js/qunit.js')


ninja.edge('build/chrome/js/unit.js').from('build/.temp-chrome/unit.js')
    .assign('exclude', qunitSrc)
    .using('browserify')
targets.chrome.push('build/chrome/js/unit.js')


ninja.edge('build/chrome/js/functional.js').from('build/.temp-chrome/functional.js')
    .assign('exclude', qunitSrc)
    .using('browserify')
targets.chrome.push('build/chrome/js/functional.js')


const iterable3 = copyFiles('chrome')
for (let i1 = 0; i1 < iterable3.length; i1++) {
    const f = iterable3[i1]
    const target = f.replace(/src\/.*?\//, "build/chrome/")
    ninja.edge(target).from(f).using('copy')
    targets.chrome.push(target)
}


const iterable4 = copyFiles('firefox')
for (let j1 = 0; j1 < iterable4.length; j1++) {
    const f = iterable4[j1]
    const target = f.replace(/src\/.*?\//, "build/firefox/data/")
    ninja.edge(target).from(f).using('copy')
    targets.firefox.push(target)
}


for (let browser in targets) {
    const list = targets[browser]
    ninja.edge(browser).from(list)
}


const manifest = 'build/chrome/manifest.json'
ninja.edge(manifest).from(manifest.replace('build','src'))
    .assign('regex',`/@version/\"${version}\"/`).using('sed')
targets.chrome.push(manifest)


ninja.rule('make-package-json')
    .run(`node make-package-json.js ${version}`)
ninja.edge('build/firefox/package.json')
    .from(['src/common/data/countries.json','src/firefox/package.json', 'package.json'])
    .using('make-package-json')
targets.firefox.push('build/firefox/package.json')

const chrome_package_name = `1clickBOM-v${version}-chrome`
ninja.rule('package-chrome')
    .run(`cd build/ && cp -r chrome  ${chrome_package_name}`
         + `&& rm -rf ${chrome_package_name}/js/{functional,unit,qunit}.js `
         + `${chrome_package_name}/html/test.html ${chrome_package_name}/js `
         + `&& zip -r ${chrome_package_name}.zip ${chrome_package_name}/ `
         + `&& rm -rf ${chrome_package_name}`)
ninja.edge(`${chrome_package_name}.zip`).need('chrome').using('package-chrome')
ninja.edge('package-chrome').need(`${chrome_package_name}.zip`)


ninja.rule('npm-install').run('cd build/firefox/ && npm install')
ninja.edge('build/firefox/node_modules')
    .from('build/firefox/package.json')
    .using('npm-install')
targets.firefox.push('build/firefox/node_modules')

ninja.rule('make-jpmignore').run("node make-jpmignore.js $in")
ninja.edge('build/firefox/.jpmignore').from('build/firefox/lib/main.js')
    .need(firefox_js.concat(['src/firefox/.jpmignore', 'make-jpmignore.js']))
    .using('make-jpmignore')
targets.firefox.push('build/firefox/.jpmignore')

const firefox_package = `build/1clickBOM-v${version}-firefox.xpi`
ninja.rule('package-firefox')
    .run(`jpm xpi --addon-dir=${__dirname}/build/firefox `
            + `&& mv build/firefox/*.xpi $out && echo 'moved to ${firefox_package}'`)
ninja.edge(firefox_package).need('firefox').using('package-firefox')
ninja.edge('package-firefox').need(firefox_package)


ninja.edge('all').from(Object.keys(targets))
ninja.byDefault('all')

ninja.edge('clean').from('build/').using('remove')

ninja.save('build.ninja')

console.log('generated build.ninja')
