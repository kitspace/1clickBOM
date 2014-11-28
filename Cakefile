fs    = require("fs")
path  = require("path")
child_process_spawn = require("child_process").spawn

COFFEESCRIPT_DIR = "src/coffee"
HTML_DIR         = "src/html"
DATA_DIR         = "src/data"
LIBS_DIR         = "libs"
IMAGES_DIR       = "images"
CHROME_DIR       = "chrome"
FIREFOX_DIR      = "firefox"
JS_DIR           = "js"

HTML_DEST_DIR   = "html"
DATA_DEST_DIR   = "data"
LIBS_DEST_DIR   = "libs"
IMAGES_DEST_DIR = "images"
JS_DEST_DIR     = "js"

ROOT_PATH         = __dirname
COFFEESCRIPT_PATH = path.join(ROOT_PATH, "/" + COFFEESCRIPT_DIR)
HTML_PATH         = path.join(ROOT_PATH, "/" + HTML_DIR)
DATA_PATH         = path.join(ROOT_PATH, "/" + DATA_DIR)
LIBS_PATH         = path.join(ROOT_PATH, "/" + LIBS_DIR)
IMAGES_PATH       = path.join(ROOT_PATH, "/" + IMAGES_DIR)
JS_PATH           = path.join(ROOT_PATH, "/" + JS_DIR)
CHROME_PATH       = path.join(ROOT_PATH, "/" + CHROME_DIR)
FIREFOX_PATH      = path.join(ROOT_PATH, "/" + FIREFOX_DIR)

SRC_PATHS = [HTML_PATH, DATA_PATH, LIBS_PATH, IMAGES_PATH, JS_PATH]

CHROME_DEST_PATHS = [ path.join(CHROME_PATH, "/" + HTML_DEST_DIR)
                    , path.join(CHROME_PATH, "/" + DATA_DEST_DIR)
                    , path.join(CHROME_PATH, "/" + LIBS_DEST_DIR)
                    , path.join(CHROME_PATH, "/" + IMAGES_DEST_DIR)
                    , path.join(CHROME_PATH, "/" + JS_DEST_DIR)
                    ]

log = (data)->
  console.log data.toString()

spawn = (cmd, args)->
    ps = child_process_spawn(cmd, args)
    ps.stdout.on('data', log)
    ps.stderr.on('data', log)
    return ps

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
    ps = child_process_spawn("coffee", ["--version"])
    ps.stderr.on('data', log)
    ps.stdout.on 'data', (version) ->
        v = []
        for n in version.toString().split(" ")[2].split(".")
            v.push(parseInt(n))
        callback(v)

task 'build', 'Build extension code into the ./' + JS_DIR + ' directory', ->
    if_coffee ->
        spawn("rm", ["-rf"].concat(CHROME_DEST_PATHS))
        get_version (version) ->
            args = ["--output", JS_PATH,"--compile", COFFEESCRIPT_PATH]
            if version > [1,6,1]
                args.unshift("--map")
            else
                warning = "not generating source maps because CoffeeScript version is < 1.6.1"
                console.log("Warning: " + warning)
            ps = spawn("coffee", args)
            ps.on 'exit', (code)->
                spawn("cp", ["-r"].concat(SRC_PATHS).concat([CHROME_PATH]))
                if code != 0
                    console.log 'failed'

task 'watch', 'Build extension code into the ./' + JS_DIR + ' directory automatically', ->
    if_coffee ->
        spawn("rm", ["-rf"].concat(CHROME_DEST_PATHS))
        spawn("ln", ["--symbolic", "--target-directory=" + CHROME_PATH].concat(SRC_PATHS))
        get_version (version) ->
            args = ["--output", JS_PATH,"--watch", COFFEESCRIPT_PATH]
            if version > [1,6,1]
                args.unshift("--map")
            else
                warning = "not generating source maps because CoffeeScript version is < 1.6.1"
                console.log("Warning: " + warning)
            ps = spawn("coffee", args)
            ps.on 'exit', (code)->
                if code != 0
                    console.log 'failed'
