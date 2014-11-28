fs    = require("fs")
path  = require("path")
spawn = require("child_process").spawn

COFFEESCRIPT_DIR    = "src/coffee"
HTML_DIR            = "src/html"
DATA_DIR            = "src/data"
LIBS_DIR            = "libs"
IMAGES_DIR          = "images"
EXTENSION_DIR       = "chrome"
JAVASCRIPT_DIR      = "js"

ROOT_PATH         = __dirname
COFFEESCRIPT_PATH = path.join(ROOT_PATH, "/" + COFFEESCRIPT_DIR)
HTML_PATH         = path.join(ROOT_PATH, "/" + HTML_DIR)
DATA_PATH         = path.join(ROOT_PATH, "/" + DATA_DIR)
LIBS_PATH         = path.join(ROOT_PATH, "/" + LIBS_DIR)
IMAGES_PATH       = path.join(ROOT_PATH, "/" + IMAGES_DIR)
EXTENSION_PATH    = path.join(ROOT_PATH, "/" + EXTENSION_DIR)
JAVASCRIPT_PATH   = path.join(ROOT_PATH, "/" + EXTENSION_DIR + "/" + JAVASCRIPT_DIR)

log = (data)->
  console.log data.toString()

coffee_available = ->
    present = false
    process.env.PATH.split(':').forEach (value, index, array)->
        present ||= path.exists("#{value}/coffee")

    present

if_coffee = (callback)->
  unless coffee_available
    console.log("CoffeeScript can't be found in your $PATH.")
    console.log("Please run 'npm install coffee-script.")
    exit(-1)
  else
    callback()

get_version = (callback)->
    ps = spawn("coffee", ["--version"])
    ps.stderr.on('data', log)
    ps.stdout.on 'data', (version) ->
        v = []
        for n in version.toString().split(" ")[2].split(".")
            v.push(parseInt(n))
        callback(v)

task 'build', 'Build extension code into the ./' + JAVASCRIPT_DIR + ' directory', ->
    if_coffee ->
        psa = spawn("cp", ["-r", HTML_PATH, DATA_PATH, LIBS_PATH, IMAGES_PATH, EXTENSION_PATH])
        psa.stdout.on('data', log)
        psa.stderr.on('data', log)
        get_version (version) ->
            args = ["--output", JAVASCRIPT_PATH,"--compile", COFFEESCRIPT_PATH]
            if version > [1,6,1]
                args.unshift("--map")
            else
                warning = "not generating source maps because CoffeeScript version is < 1.6.1"
                console.log "Warning: " + warning
            ps = spawn("coffee", args)
            ps.stdout.on('data', log)
            ps.stderr.on('data', log)
            ps.on 'exit', (code)->
                if warning?
                    console.log warning
                if code != 0
                    console.log 'failed'

task 'watch', 'Build extension code into the ./' + JAVASCRIPT_DIR + ' directory automatically', ->
    if_coffee ->
        get_version (version) ->
            args = ["--output", JAVASCRIPT_PATH,"--watch", COFFEESCRIPT_PATH]
            if version > [1,6,1]
                args.unshift("--map")
            else
                warning = "not generating source maps because CoffeeScript version is < 1.6.1"
                console.log "Warning: " + warning
            ps = spawn("coffee", args)
            ps.stdout.on('data', log)
            ps.stderr.on('data', log)
            ps.on 'exit', (code)->
                if code != 0
                    console.log 'failed'
