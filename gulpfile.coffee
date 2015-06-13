gulp       = require('gulp')
coffee     = require('gulp-coffee')
sourcemaps = require('gulp-sourcemaps')
replace    = require('gulp-replace')
del        = require('del')
merge      = require('merge-stream')
changed    = require('gulp-changed')

VERSION = '0.1.7.1'

paths = (browser) ->
    { coffee : ["src/#{browser}/coffee/**/*.coffee", 'src/common/coffee/**/*.coffee']
    , images : ["src/#{browser}/images/**/*", 'src/common/images/**/*']
    , html   : ["src/#{browser}/html/**/*", 'src/common/html/**/*']
    , data   : ["src/#{browser}/data/**/*", 'src/common/data/**/*']
    , libs   : ["src/#{browser}/libs/**/*", 'src/common/libs/**/*']
    }

gulp.task 'chrome-coffee', () ->
    gulp.src(paths('chrome').coffee)
        .pipe(changed('build/chrome/js'))
        .pipe(sourcemaps.init())
            .pipe(coffee())
        .pipe(sourcemaps.write())
        .pipe(gulp.dest('build/chrome/js'))

gulp.task 'chrome-manifest', ()  ->
    gulp.src(['src/chrome/manifest.json'])
        .pipe(changed('build/chrome/js'))
        .pipe(replace(/@version/, '"' + VERSION + '"'))
        .pipe(gulp.dest('build/chrome'))

gulp.task 'chrome-copy', () ->
    html = gulp.src(paths('chrome').html)
        .pipe(changed('build/chrome/html'))
        .pipe(gulp.dest('build/chrome/html'))
    images = gulp.src(paths('chrome').images)
        .pipe(changed('build/chrome/images'))
        .pipe(gulp.dest('build/chrome/images'))
    data = gulp.src(paths('chrome').data)
        .pipe(changed('build/chrome/data'))
        .pipe(gulp.dest('build/chrome/data'))
    libs = gulp.src(paths('chrome').libs)
        .pipe(changed('build/chrome/libs'))
        .pipe(gulp.dest('build/chrome/libs'))
    return merge(html, images, data, libs)

gulp.task 'clean', (callback) ->
    del(['build'], callback)

gulp.task('chrome', ['chrome-coffee', 'chrome-manifest', 'chrome-copy'])

gulp.task('default', ['chrome'])
