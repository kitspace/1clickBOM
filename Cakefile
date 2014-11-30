fs    = require("fs")
path  = require("path")
child_process = require("child_process")

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

FIREFOX_DEST_PATHS = [ join(FIREFOX_PATH, HTML_FIREFOX_DEST_DIR)
                     , join(FIREFOX_PATH, DATA_FIREFOX_DEST_DIR)
                     , join(FIREFOX_PATH, LIBS_FIREFOX_DEST_DIR)
                     , join(FIREFOX_PATH, IMAGES_FIREFOX_DEST_DIR)
                     , join(FIREFOX_PATH, JS_FIREFOX_DEST_DIR)
                     ]


FIREFOX_PACKAGE_PATH =

log = (data)->
  console.log data.toString()

spawn = (cmd, args, exit_callback, update_callback)->
    ps = child_process.spawn(cmd, args)
    ps.stdout.on "data", (data) ->
        if update_callback? then update_callback(data)
        log(data)
    ps.stderr.on("data", log)
    ps.on "exit", (code)->
        if code != 0
            console.log "failed"
        if exit_callback? then exit_callback(code)
    return ps

coffee_available = ->
    present = false
    process.env.PATH.split(":").forEach (value, index, array)->
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
    if_coffee ->
        spawn "coffee", ["--version"], undefined, (data) ->
            v = []
            for n in data.toString().split(" ")[2].split(".")
                v.push(parseInt(n))
            callback(v)

rmFilesInDirRecursive = (rm_path) ->
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
                try
                    fs.unlinkSync(p)
                catch err
                    console.log(err.message)

rmDirRecursive = (rm_path) ->
    try
        stats = fs.statSync(rm_path)
    catch err
        unless err.code == "ENOENT"
            throw(err)
    if stats? && stats.isDirectory()
        rmFilesInDirRecursive(rm_path)
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

build = (args, callback) ->
    if_coffee ->
        rmDirRecursive(JS_PATH)
        ps = spawn "coffee", args, () ->
            linkRecursiveAll(SRC_PATHS, FIREFOX_DEST_PATHS)
            linkRecursiveAll(SRC_PATHS, CHROME_DEST_PATHS)
            if callback? then callback()

maybe_map = (version, args) ->
    if version > [1,6,1]
        args.unshift("--map")
    else
        console.log("Warning: not generating source maps because
                     CoffeeScript version is < 1.6.1")
    return args

task "build"
    , "Make symlinks and compile coffeescript"
    , ->
        get_version (version) ->
            args = ["--output", JS_PATH,"--compile", COFFEESCRIPT_PATH]
            args = maybe_map(version,args)
            build(args)

task "watch"
    , "Make symlinks and re-compile coffeescript automatically, watching for
       changes"
    , ->
        if_coffee ->
            linkRecursiveAll(SRC_PATHS, FIREFOX_DEST_PATHS)
            linkRecursiveAll(SRC_PATHS, CHROME_DEST_PATHS)
            get_version (version) ->
                args = ["--output", JS_PATH,"--watch", COFFEESCRIPT_PATH]
                args = maybe_map(version,args)
                ps = spawn("coffee", args)

task "package"
    , "Make packages ready for distribution in ../"
    , ->
        args = ["--output", JS_PATH,"--compile", COFFEESCRIPT_PATH]
        build args, () ->
            manifest = JSON.parse(fs.readFileSync(join(CHROME_PATH, "manifest.json")))
            chrome_name = "1clickBOM-chrome-v" + manifest.version
            chrome_tmp_path = join(ROOT_PATH,chrome_name)
            if fs.existsSync(chrome_tmp_path)
                rmDirRecursive(chrome_tmp_path)
            fs.mkdirSync(chrome_tmp_path)
            chrome_package_path = join(ROOT_PATH + "/../", chrome_name + ".zip")
            if fs.existsSync(chrome_package_path)
                fs.unlinkSync(chrome_package_path)
            linkRecursive(CHROME_PATH, chrome_tmp_path)
            spawn "zip", ["-r" , chrome_package_path, chrome_name], ->
                rmDirRecursive(chrome_tmp_path)

            fpackage = JSON.parse(fs.readFileSync(join(FIREFOX_PATH, "package.json")))
            firefox_name = "1clickBOM-firefox-v" + fpackage.version
            firefox_package_path = join(ROOT_PATH + "/../", firefox_name + ".xpi")
            spawn "cfx", ["--pkgdir=" + FIREFOX_PATH
                         , "--output-file=" + firefox_package_path
                         , "xpi"
                         ]



