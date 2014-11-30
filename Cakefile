fs    = require("fs")
path  = require("path")
child_process = require("child_process")

join = (p1,p2) ->
    path.join(p1, "/" + p2)

COFFEE_DIR = "src/coffee"
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
COFFEE_PATH = join(ROOT_PATH, COFFEE_DIR)
HTML_PATH         = join(ROOT_PATH, HTML_DIR)
DATA_PATH         = join(ROOT_PATH, DATA_DIR)
LIBS_PATH         = join(ROOT_PATH, LIBS_DIR)
IMAGES_PATH       = join(ROOT_PATH, IMAGES_DIR)
JS_PATH           = join(ROOT_PATH, JS_DIR)
CHROME_PATH       = join(ROOT_PATH, CHROME_DIR)
FIREFOX_PATH      = join(ROOT_PATH, FIREFOX_DIR)

HTML_CHROME_DEST_PATH   = join(CHROME_PATH, HTML_CHROME_DEST_DIR)
DATA_CHROME_DEST_PATH   = join(CHROME_PATH, DATA_CHROME_DEST_DIR)
LIBS_CHROME_DEST_PATH   = join(CHROME_PATH, LIBS_CHROME_DEST_DIR)
IMAGES_CHROME_DEST_PATH = join(CHROME_PATH, IMAGES_CHROME_DEST_DIR)
JS_CHROME_DEST_PATH     = join(CHROME_PATH, JS_CHROME_DEST_DIR)

HTML_FIREFOX_DEST_PATH   = join(FIREFOX_PATH, HTML_FIREFOX_DEST_DIR)
DATA_FIREFOX_DEST_PATH   = join(FIREFOX_PATH, DATA_FIREFOX_DEST_DIR)
LIBS_FIREFOX_DEST_PATH   = join(FIREFOX_PATH, LIBS_FIREFOX_DEST_DIR)
IMAGES_FIREFOX_DEST_PATH = join(FIREFOX_PATH, IMAGES_FIREFOX_DEST_DIR)
JS_FIREFOX_DEST_PATH     = join(FIREFOX_PATH, JS_FIREFOX_DEST_DIR)

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
        ps = child_process.spawn "coffee", ["--version"]
        ps.stdout.on "data", (data) ->
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

linkRecursiveAll = () ->
    linkRecursive(HTML_PATH, HTML_CHROME_DEST_PATH)
    linkRecursive(DATA_PATH, DATA_CHROME_DEST_PATH)
    linkRecursive(LIBS_PATH, LIBS_CHROME_DEST_PATH)
    linkRecursive(IMAGES_PATH, IMAGES_CHROME_DEST_PATH)
    linkRecursive(JS_PATH, JS_CHROME_DEST_PATH)
    linkRecursive(HTML_PATH, HTML_FIREFOX_DEST_PATH)
    linkRecursive(DATA_PATH, DATA_FIREFOX_DEST_PATH)
    linkRecursive(LIBS_PATH, LIBS_FIREFOX_DEST_PATH)
    linkRecursive(IMAGES_PATH, IMAGES_FIREFOX_DEST_PATH)
    linkRecursive(JS_PATH, JS_FIREFOX_DEST_PATH)

coffee = (args, callback) ->
    if_coffee ->
        rmDirRecursive(JS_PATH)
        ps = spawn "coffee", args, () ->
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
            args = ["--output", JS_PATH,"--compile", COFFEE_PATH]
            args = maybe_map(version,args)
            coffee args, () ->
                linkRecursiveAll()

watch = (path, callback) ->
    fs.watchFile(path, { persistent: true, interval: 1007 }, callback)

task "watch"
    , "Make symlinks and re-compile coffeescript automatically, watching for
       changes"
    , ->
        if_coffee ->
            console.log("/Every move you make/")
            watch HTML_PATH, ->
                console.log("/Every html file you change/")
                linkRecursive(HTML_PATH, HTML_FIREFOX_DEST_PATH)
                linkRecursive(HTML_PATH, HTML_CHROME_DEST_PATH)
            watch DATA_PATH, ->
                console.log("/Every data file you change/")
                linkRecursive(DATA_PATH, DATA_FIREFOX_DEST_PATH)
                linkRecursive(DATA_PATH, DATA_CHROME_DEST_PATH)
            watch IMAGES_PATH, ->
                console.log("/Every image you change/")
                linkRecursive(IMAGES_PATH, IMAGES_FIREFOX_DEST_PATH)
                linkRecursive(IMAGES_PATH, IMAGES_CHROME_DEST_PATH)
            watch LIBS_PATH, ->
                console.log("/Every lib you change/")
                linkRecursive(LIBS_PATH, LIBS_FIREFOX_DEST_PATH)
                linkRecursive(LIBS_PATH, LIBS_CHROME_DEST_PATH)
            get_version (version) ->
                args = ["--output", JS_PATH,"--compile", COFFEE_PATH]
                args = maybe_map(version,args)
                watch COFFEE_PATH, () ->
                    console.log("/Every step you take/")
                    coffee args, (code) ->
                        if code == 0
                            linkRecursive(JS_PATH, JS_FIREFOX_DEST_PATH)
                            linkRecursive(JS_PATH, JS_CHROME_DEST_PATH)
                coffee args, (code) ->
                    if code == 0
                        linkRecursiveAll()

task "package"
    , "Make packages ready for distribution in ../"
    , ->
        args = ["--output", JS_PATH,"--compile", COFFEE_PATH]
        coffee args, () ->
            linkRecursiveAll()
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



