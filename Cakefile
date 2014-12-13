fs    = require("fs")
join  = require("path").join
child_process = require("child_process")

EXTENSION_NAME = "1clickBOM"

COFFEE_DIR    = "coffee"
HTML_DIR      = "html"
DATA_DIR      = "data"
LIBS_DIR      = "libs"
TEST_LIBS_DIR = "test_libs"
IMAGES_DIR    = "images"
EXAMPLES_DIR  = "examples"

DEST_DIR = join(__dirname, "build")
SRC_DIR  = join(__dirname, "src")

PACKAGE_DIR = "../"

HTML_COMMON_SRC_DIR      = join(SRC_DIR, "common", "html")
DATA_COMMON_SRC_DIR      = join(SRC_DIR, "common", "data")
EXAMPLES_COMMON_SRC_DIR  = join(SRC_DIR, "common", "examples")
LIBS_COMMON_SRC_DIR      = join(SRC_DIR, "common", "libs")
TEST_LIBS_COMMON_SRC_DIR = join(SRC_DIR, "common", "test_libs")
IMAGES_COMMON_SRC_DIR    = join(SRC_DIR, "common", "images")
COFFEE_COMMON_SRC_DIR    = join(SRC_DIR, "common", "coffee")

HTML_CHROME_SRC_DIR      = join(SRC_DIR, "chrome", "html")
DATA_CHROME_SRC_DIR      = join(SRC_DIR, "chrome", "data")
EXAMPLES_CHROME_SRC_DIR  = join(SRC_DIR, "chrome", "examples")
LIBS_CHROME_SRC_DIR      = join(SRC_DIR, "chrome", "libs")
TEST_LIBS_CHROME_SRC_DIR = join(SRC_DIR, "chrome", "test_libs")
IMAGES_CHROME_SRC_DIR    = join(SRC_DIR, "chrome", "images")
COFFEE_CHROME_SRC_DIR    = join(SRC_DIR, "chrome", "coffee")

HTML_FIREFOX_SRC_DIR       = join(SRC_DIR, "firefox", "html")
DATA_FIREFOX_SRC_DIR       = join(SRC_DIR, "firefox", "data")
EXAMPLES_FIREFOX_SRC_DIR   = join(SRC_DIR, "firefox", "examples")
LIBS_FIREFOX_SRC_DIR       = join(SRC_DIR, "firefox", "libs")
TEST_LIBS_FIREFOX_SRC_DIR  = join(SRC_DIR, "firefox", "test_libs")
IMAGES_FIREFOX_SRC_DIR     = join(SRC_DIR, "firefox", "images")
COFFEE_FIREFOX_SRC_DIR     = join(SRC_DIR, "firefox", "coffee")
COFFEE_LIB_FIREFOX_SRC_DIR = join(SRC_DIR, "firefox", "lib")

HTML_CHROME_DEST_DIR      = join(DEST_DIR, "chrome", "html")
DATA_CHROME_DEST_DIR      = join(DEST_DIR, "chrome", "data")
EXAMPLES_CHROME_DEST_DIR  = join(DEST_DIR, "chrome", "examples")
LIBS_CHROME_DEST_DIR      = join(DEST_DIR, "chrome", "libs")
TEST_LIBS_CHROME_DEST_DIR = join(DEST_DIR, "chrome", "libs")
IMAGES_CHROME_DEST_DIR    = join(DEST_DIR, "chrome", "images")
JS_CHROME_DEST_DIR        = join(DEST_DIR, "chrome", "js")
TEST_LIBS_CHROME_DEST_DIR = join(DEST_DIR, "chrome", "libs")

HTML_FIREFOX_DEST_DIR      = join(DEST_DIR, "firefox", "data/html")
DATA_FIREFOX_DEST_DIR      = join(DEST_DIR, "firefox", "data/data")
EXAMPLES_FIREFOX_DEST_DIR  = join(DEST_DIR, "firefox", "data/examples")
LIBS_FIREFOX_DEST_DIR      = join(DEST_DIR, "firefox", "data/libs")
TEST_LIBS_FIREFOX_DEST_DIR = join(DEST_DIR, "firefox", "data/libs")
IMAGES_FIREFOX_DEST_DIR    = join(DEST_DIR, "firefox", "data/images")
JS_FIREFOX_DEST_DIR        = join(DEST_DIR, "firefox", "data/js")
JS_LIB_FIREFOX_DEST_DIR    = join(DEST_DIR, "firefox", "lib")

FIREFOX_PORT = "8888"

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

isOnPath = (exe) ->
    present = false
    process.env.PATH.split(":").forEach (value, index, array)->
        present ||= fs.existsSync(join(value,exe))
    unless present
        console.log("'" + exe + "'" + " can't be found in your $PATH.")
        process.exit(1)

getVersion = (callback)->
    isOnPath "coffee"
    ps = child_process.spawn "coffee", ["--version"]
    ps.stdout.on "data", (data) ->
        v = []
        for n in data.toString().split(" ")[2].split(".")
            v.push(parseInt(n))
        callback(v)

stat = (p) ->
    #statSync throws ENOENT errors on files that where deleted at symlink
    #source
    try
        stats = fs.statSync(p)
    catch err
        unless err.code == "ENOENT"
            throw(err)
    return stats

rmFilesInDirRecursive = (rm_path) ->
    files = fs.readdirSync(rm_path)
    for file in files
        p = join(rm_path,file)
        stats = stat(p)
        if stats? && stats.isDirectory()
            rmDirRecursive(p)
        else
            fs.unlinkSync(p)

rmDirRecursive = (rm_path) ->
    stats = stat(rm_path)
    if stats? && stats.isDirectory()
        rmFilesInDirRecursive(rm_path)
        fs.rmdirSync(rm_path)

linkRecursive = (src_path, dest_path) ->
    if fs.existsSync(src_path)
        unless fs.existsSync(dest_path)
            fs.mkdirSync(dest_path)
        files = fs.readdirSync(src_path)
        for file in files
            p = join(src_path,file)
            stats = stat(p)
            if stats? && stats.isDirectory()
                linkRecursive(p, join(dest_path, file))
            else unless fs.existsSync(join(dest_path, file))
                fs.symlinkSync(p, join(dest_path, file))

linkHTML = () ->
    linkRecursive(HTML_CHROME_SRC_DIR, HTML_CHROME_DEST_DIR)
    linkRecursive(HTML_COMMON_SRC_DIR, HTML_CHROME_DEST_DIR)
    linkRecursive(HTML_FIREFOX_SRC_DIR, HTML_FIREFOX_DEST_DIR)
    linkRecursive(HTML_COMMON_SRC_DIR, HTML_FIREFOX_DEST_DIR)

linkData = () ->
    linkRecursive(DATA_CHROME_SRC_DIR, DATA_CHROME_DEST_DIR)
    linkRecursive(DATA_COMMON_SRC_DIR, DATA_CHROME_DEST_DIR)
    linkRecursive(DATA_FIREFOX_SRC_DIR, DATA_FIREFOX_DEST_DIR)
    linkRecursive(DATA_COMMON_SRC_DIR, DATA_FIREFOX_DEST_DIR)

linkImages = () ->
    linkRecursive(IMAGES_CHROME_SRC_DIR, IMAGES_CHROME_DEST_DIR)
    linkRecursive(IMAGES_COMMON_SRC_DIR, IMAGES_CHROME_DEST_DIR)
    linkRecursive(IMAGES_FIREFOX_SRC_DIR, IMAGES_FIREFOX_DEST_DIR)
    linkRecursive(IMAGES_COMMON_SRC_DIR, IMAGES_FIREFOX_DEST_DIR)

linkLibs = () ->
    linkRecursive(LIBS_CHROME_SRC_DIR, LIBS_CHROME_DEST_DIR)
    linkRecursive(LIBS_COMMON_SRC_DIR, LIBS_CHROME_DEST_DIR)
    linkRecursive(LIBS_FIREFOX_SRC_DIR, LIBS_FIREFOX_DEST_DIR)
    linkRecursive(LIBS_COMMON_SRC_DIR, LIBS_FIREFOX_DEST_DIR)

linkTestLibs = () ->
    linkRecursive(TEST_LIBS_COMMON_SRC_DIR, TEST_LIBS_CHROME_DEST_DIR)
    linkRecursive(TEST_LIBS_CHROME_SRC_DIR, TEST_LIBS_CHROME_DEST_DIR)
    linkRecursive(TEST_LIBS_COMMON_SRC_DIR, TEST_LIBS_FIREFOX_DEST_DIR)
    linkRecursive(TEST_LIBS_FIREFOX_SRC_DIR, TEST_LIBS_FIREFOX_DEST_DIR)

linkExamples = () ->
    linkRecursive(EXAMPLES_COMMON_SRC_DIR, EXAMPLES_CHROME_DEST_DIR)
    linkRecursive(EXAMPLES_CHROME_SRC_DIR, EXAMPLES_CHROME_DEST_DIR)
    linkRecursive(EXAMPLES_COMMON_SRC_DIR, EXAMPLES_FIREFOX_DEST_DIR)
    linkRecursive(EXAMPLES_FIREFOX_SRC_DIR, EXAMPLES_FIREFOX_DEST_DIR)

linkRecursiveDist = () ->
    rmDirRecursive(DEST_DIR)
    fs.mkdirSync(DEST_DIR)
    fs.mkdirSync(join(DEST_DIR, "firefox"))
    fs.mkdirSync(join(DEST_DIR, "firefox", "lib"))
    fs.mkdirSync(join(DEST_DIR, "firefox", "data"))
    fs.mkdirSync(join(DEST_DIR, "chrome"))
    fs.symlinkSync(join(SRC_DIR, "firefox/package.json") , join(DEST_DIR, "firefox/package.json"))
    fs.symlinkSync(join(SRC_DIR, "chrome/manifest.json") , join(DEST_DIR, "chrome/manifest.json"))
    linkHTML()
    linkData()
    linkImages()
    linkLibs()

linkRecursiveAll = () ->
    linkRecursiveDist()
    linkTestLibs()
    linkExamples()

maybeAddMap = (version, args) ->
    if version > [1,6,1]
        args.unshift("--map")
    else
        console.log("Warning: not generating source maps because
                     CoffeeScript version is < 1.6.1")
    return args


_compile = (args, add_map, callback) ->
    getVersion (version) ->
        if add_map
            args = maybeAddMap(version, args)
        ps = spawn "coffee", args, (code) ->
            if code == 0
                if callback? then callback()
            else
                process.exit(2)

compile = (add_map, callback) ->
    isOnPath "coffee"
    args = ["--output", JS_FIREFOX_DEST_DIR,"--compile", COFFEE_COMMON_SRC_DIR]
    _compile args, add_map, () ->
        args = ["--output", JS_FIREFOX_DEST_DIR,"--compile", COFFEE_FIREFOX_SRC_DIR]
        _compile args, add_map, () ->
            args = ["--output", JS_LIB_FIREFOX_DEST_DIR,"--compile", COFFEE_LIB_FIREFOX_SRC_DIR]
            _compile args, add_map, () ->
                args = ["--output", JS_CHROME_DEST_DIR,"--compile", COFFEE_COMMON_SRC_DIR]
                _compile args, add_map, () ->
                    args = ["--output", JS_CHROME_DEST_DIR,"--compile", COFFEE_CHROME_SRC_DIR]
                    _compile(args, add_map, callback)

task "build"
    , "Make symlinks and compile coffeescript"
    , ->
        linkRecursiveAll()
        compile(true)

watch = (paths, callback) ->
    for p in paths
        fs.watchFile(p, { persistent: true, interval: 1000 }, callback)

task "watch"
    , "Make symlinks and re-compile coffeescript automatically, watching for
       changes"
    , ->
        console.log("/Every move you make/")
        watch [HTML_COMMON_SRC_DIR, HTML_CHROME_SRC_DIR, HTML_FIREFOX_SRC_DIR],  ->
            console.log("Re-symlinking HTML")
            linkHTML()
        watch [DATA_COMMON_SRC_DIR, DATA_CHROME_SRC_DIR, DATA_FIREFOX_SRC_DIR], ->
            console.log("Re-symlinking data")
            linkData()
        watch [IMAGES_COMMON_SRC_DIR, IMAGES_CHROME_SRC_DIR, IMAGES_FIREFOX_SRC_DIR], ->
            console.log("Re-symlinking images")
            linkImages()
        watch [LIBS_COMMON_SRC_DIR, LIBS_CHROME_SRC_DIR, LIBS_FIREFOX_SRC_DIR], ->
            console.log("Re-symlinking libs")
            linkLibs()
        watch [EXAMPLES_COMMON_SRC_DIR, EXAMPLES_CHROME_SRC_DIR, EXAMPLES_FIREFOX_SRC_DIR], ->
            console.log("Re-symlinking examples")
            linkExamples()
        watch [TEST_LIBS_COMMON_SRC_DIR, TEST_LIBS_CHROME_SRC_DIR, TEST_LIBS_FIREFOX_SRC_DIR], ->
            console.log("Re-symlinking test_libs")
            linkTestLibs()
        watch [COFFEE_COMMON_SRC_DIR, COFFEE_CHROME_SRC_DIR, COFFEE_FIREFOX_SRC_DIR, COFFEE_LIB_FIREFOX_SRC_DIR], ->
            console.log("Re-compiling coffeescript")
            compile(true)
        compile(true)
#
#uglifyRecursive = (callback) ->
#    if fs.statSync(JS_PATH).isDirectory()
#        files = fs.readdirSync(JS_PATH)
#        count = files.length
#        for file in files
#            p = join(JS_PATH,file)
#            stats = fs.statSync(p)
#            if stats? && stats.isDirectory()
#                uglifyRecursive p, join(dest_path, file), ()->
#                    count--
#                    if count == 0 && callback? then callback()
#            else
#                spawn "uglifyjs2", ["--overwrite", p], () ->
#                    count--
#                    if count == 0 && callback? then callback()
#
#task "package"
#    , "Make packages ready for distribution in " + PACKAGE_DIR
#    , ->
#        isOnPath "coffee"
#        isOnPath "zip"
#        isOnPath "cfx"
#        isOnPath "uglifyjs2"
#        compile false, ->
#            rmDirRecursive(JS_TESTS_PATH)
#            uglifyRecursive () ->
#                linkRecursiveDist()
#                manifest = JSON.parse(fs.readFileSync(join(CHROME_PATH, "manifest.json")))
#                chrome_name = EXTENSION_NAME + "-chrome-v" + manifest.version
#                chrome_tmp_path = join(ROOT_PATH,chrome_name)
#                fs.mkdirSync(chrome_tmp_path)
#                chrome_package_path = join(ROOT_PATH + "/" + PACKAGE_DIR, chrome_name + ".zip")
#                if fs.existsSync(chrome_package_path)
#                    fs.unlinkSync(chrome_package_path)
#                linkRecursive(CHROME_PATH, chrome_tmp_path)
#                spawn "zip", ["-r" , chrome_package_path, chrome_name], ->
#                    rmDirRecursive(chrome_tmp_path)
#                fpackage = JSON.parse(fs.readFileSync(join(FIREFOX_PATH, "package.json")))
#                firefox_name = EXTENSION_NAME + "-firefox-v" + fpackage.version
#                firefox_package_path = join(ROOT_PATH + "/" + PACKAGE_DIR, firefox_name + ".xpi")
#                spawn "cfx", ["--pkgdir=" + FIREFOX_PATH
#                             , "--output-file=" + firefox_package_path
#                             , "xpi"
#                             ]
#
## this sends the extension to the auto-installer extension
## https://addons.mozilla.org/en-US/firefox/addon/autoinstaller/
## the 500 no-content error is normal
#task "reload-firefox"
#    , "Build a temporary xpi and send to the Firefox auto-installer on port " + FIREFOX_PORT
#    , ->
#        isOnPath "cfx"
#        isOnPath "wget"
#        spawn "cfx", ["--pkgdir=" + FIREFOX_PATH, "--output-file=tmp.xpi", "xpi"], ->
#                console.log("Sending extension to Firefox on port " + FIREFOX_PORT)
#                child_process.spawn "wget", ["--post-file=tmp.xpi", "http://localhost:" + FIREFOX_PORT]
