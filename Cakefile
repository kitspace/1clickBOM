fs    = require("fs")
path  = require("path")
child_process_spawn = require("child_process").spawn

join = (p1,p2) ->
    path.join(p1, "/" + p2)

COFFEESCRIPT_DIR = "src/coffee"
HTML_DIR         = "src/html"
DATA_DIR         = "src/data"
LIBS_DIR         = "libs"
IMAGES_DIR       = "images"
CHROME_DIR       = "chrome"
FIREFOX_DIR      = "firefox"
JS_DIR           = "js"

HTML_CHROME_DEST_DIR   = "html"
DATA_CHROME_DEST_DIR   = "data"
LIBS_CHROME_DEST_DIR   = "libs"
IMAGES_CHROME_DEST_DIR = "images"
JS_CHROME_DEST_DIR     = "js"

HTML_FIREFOX_DEST_DIR   = "data/html"
DATA_FIREFOX_DEST_DIR   = "data/data"
LIBS_FIREFOX_DEST_DIR   = "data/libs"
IMAGES_FIREFOX_DEST_DIR = "data/images"
JS_FIREFOX_DEST_DIR     = "lib"

ROOT_PATH         = __dirname
COFFEESCRIPT_PATH = join(ROOT_PATH, COFFEESCRIPT_DIR)
HTML_PATH         = join(ROOT_PATH, HTML_DIR)
DATA_PATH         = join(ROOT_PATH, DATA_DIR)
LIBS_PATH         = join(ROOT_PATH, LIBS_DIR)
IMAGES_PATH       = join(ROOT_PATH, IMAGES_DIR)
JS_PATH           = join(ROOT_PATH, JS_DIR)
CHROME_PATH       = join(ROOT_PATH, CHROME_DIR)
FIREFOX_PATH      = join(ROOT_PATH, FIREFOX_DIR)

#the order on these is important for now because of linkRecursiveAll
SRC_PATHS = [HTML_PATH, DATA_PATH, LIBS_PATH, IMAGES_PATH, JS_PATH]

CHROME_DEST_PATHS = [ join(CHROME_PATH, HTML_CHROME_DEST_DIR)
                    , join(CHROME_PATH, DATA_CHROME_DEST_DIR)
                    , join(CHROME_PATH, LIBS_CHROME_DEST_DIR)
                    , join(CHROME_PATH, IMAGES_CHROME_DEST_DIR)
                    , join(CHROME_PATH, JS_CHROME_DEST_DIR)
                    ]

HTML_FIREFOX_DEST_PATH   = join(FIREFOX_PATH, HTML_FIREFOX_DEST_DIR)
DATA_FIREFOX_DEST_PATH   = join(FIREFOX_PATH, DATA_FIREFOX_DEST_DIR)
LIBS_FIREFOX_DEST_PATH   = join(FIREFOX_PATH, LIBS_FIREFOX_DEST_DIR)
IMAGES_FIREFOX_DEST_PATH = join(FIREFOX_PATH, IMAGES_FIREFOX_DEST_DIR)
JS_FIREFOX_DEST_PATH     = join(FIREFOX_PATH, JS_FIREFOX_DEST_DIR)

FIREFOX_DEST_PATHS = [ HTML_FIREFOX_DEST_PATH
                     , DATA_FIREFOX_DEST_PATH
                     , LIBS_FIREFOX_DEST_PATH
                     , IMAGES_FIREFOX_DEST_PATH
                     , JS_FIREFOX_DEST_PATH
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

rmDirRecursive = (rm_path) ->
    if fs.statSync(rm_path).isDirectory()
        files = fs.readdirSync(rm_path)
        for file in files
            p = join(rm_path,file)
            #statSync throws ENOENT errors on files that where deleted at
            #symlink source
            try
                stats = fs.statSync(p)
            catch err
                unless err.code == "ENOENT"
                    throw(err)
            if stats? && stats.isDirectory()
                rmDirRecursive(p)
            else
                fs.unlinkSync(p)
        fs.rmdirSync(rm_path)

linkRecursive = (src_path, dest_path) ->
    if fs.statSync(src_path).isDirectory()
        if fs.existsSync(dest_path)
            rmDirRecursive(dest_path)
        fs.mkdirSync(dest_path)
        files = fs.readdirSync(src_path)
        for file in files
            p = join(src_path,file)
            stats = fs.statSync(p)
            if stats? && stats.isDirectory()
                linkRecursive(p, join(dest_path, file))
            else
                fs.symlinkSync(p, join(dest_path, file))

linkRecursiveAll = (src_paths, dest_paths) ->
    for s,i in src_paths
       d = dest_paths[i]
       linkRecursive(s,d)

task 'build', 'Build extension code into the ./' + JS_DIR + ' directory', ->
    if_coffee ->
        linkRecursiveAll(SRC_PATHS, FIREFOX_DEST_PATHS)
        linkRecursiveAll(SRC_PATHS, CHROME_DEST_PATHS)
        get_version (version) ->
            args = ["--output", JS_PATH,"--compile", COFFEESCRIPT_PATH]
            if version > [1,6,1]
                args.unshift("--map")
            else
                warning = "not generating source maps because CoffeeScript version is < 1.6.1"
                console.log("Warning: " + warning)
            ps = spawn("coffee", args)
            ps.on 'exit', (code)->
                if code != 0
                    console.log 'failed'



task 'watch', 'Build extension code into the ./' + JS_DIR + ' directory automatically', ->
    if_coffee ->
        linkRecursiveAll(SRC_PATHS, FIREFOX_DEST_PATHS)
        linkRecursiveAll(SRC_PATHS, CHROME_DEST_PATHS)
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

