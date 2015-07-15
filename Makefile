wildc_recursive=$(foreach d,$(wildcard $1*),$(call wildc_recursive,$d/,$2)\
			   	$(filter $(subst *,%,$2),$d))

VERSION = 0.2.0
PACKAGE_NAME = 1clickBOM-v$(VERSION)

CHROME_COFFEE_DIR  = src/chrome/coffee
COMMON_COFFEE_DIR  = src/common/coffee
FIREFOX_COFFEE_DIR = src/firefox/coffee

CHROME_COFFEE_FILES  = $(call wildc_recursive, $(CHROME_COFFEE_DIR), *.coffee)
COMMON_COFFEE_FILES  = $(call wildc_recursive, $(COMMON_COFFEE_DIR), *.coffee)
FIREFOX_COFFEE_FILES = $(call wildc_recursive, $(FIREFOX_COFFEE_DIR), *.coffee)

COMMON_COFFEE_CHROME_TARGET_FILES = $(patsubst src/common/coffee/%.coffee, \
								   	build/chrome/js/%.js, $(COMMON_COFFEE_FILES))
CHROME_COFFEE_TARGET_FILES = build/chrome/js/main.js build/chrome/js/popup.js \
							 build/chrome/js/unit.js build/chrome/js/functional.js \
							 build/chrome/js/options.js
COMMON_COFFEE_FIREFOX_TARGET_FILES = $(patsubst src/common/coffee/%.coffee, \
									 build/firefox/lib/%.js, $(COMMON_COFFEE_FILES)) \
									 build/firefox/data/popup.js
FIREFOX_COFFEE_TARGET_FILES = $(patsubst src/firefox/coffee/%.coffee, \
							  build/firefox/lib/%.js, $(FIREFOX_COFFEE_FILES)) \
							  $(COMMON_COFFEE_FIREFOX_TARGET_FILES)

CHROME_HTML_FILES  = $(wildcard src/chrome/html/*)
COMMON_HTML_FILES  = $(wildcard src/common/html/*)
FIREFOX_HTML_FILES = $(wildcard src/firefox/html/*)

CHROME_LIBS_FILES  = $(wildcard src/chrome/libs/*)
COMMON_LIBS_FILES  = $(wildcard src/common/libs/*)
FIREFOX_LIBS_FILES = $(wildcard src/firefox/libs/*)

CHROME_IMAGE_FILES  = $(wildcard src/chrome/images/*)
COMMON_IMAGE_FILES  = $(wildcard src/common/images/*)
FIREFOX_IMAGE_FILES = $(wildcard src/firefox/images/*)

CHROME_DATA_FILES  = $(wildcard src/chrome/data/*)
COMMON_DATA_FILES  = $(wildcard src/common/data/*)
FIREFOX_DATA_FILES = $(wildcard src/firefox/data/*)

SUB_DIRS = target/html target/images target/libs target/data target/js
CHROME_DIRS  = build/chrome/.dir \
			   $(patsubst target/%,build/chrome/%/.dir, $(SUB_DIRS))
FIREFOX_DIRS = build/firefox/.dir build/firefox/data/.dir \
			   $(patsubst target/%,build/firefox/data/%/.dir, $(SUB_DIRS)) build/

CHROME_TEMP_SRC_FILES = $(CHROME_COFFEE_FILES) $(COMMON_COFFEE_FILES) \
					   	$(COMMON_LIBS_FILES) $(CHROME_LIBS_FILES)

FIREFOX_TEMP_SRC_FILES = $(FIREFOX_COFFEE_FILES) $(COMMON_COFFEE_FILES) \
					   	$(COMMON_LIBS_FILES)

CHROME_TEMP_TARGET_FILES = $(addprefix build/.temp-chrome/, \
						   $(notdir $(CHROME_TEMP_SRC_FILES)))
FIREFOX_TEMP_TARGET_FILES = $(addprefix build/.temp-firefox/, \
							$(notdir $(FIREFOX_TEMP_SRC_FILES)))

all: firefox chrome

firefox: dirs $(FIREFOX_COFFEE_TARGET_FILES) firefox_html firefox_images firefox_data build/firefox/package.json

chrome: dirs $(CHROME_COFFEE_TARGET_FILES) chrome_html chrome_libs chrome_images chrome_data build/chrome/manifest.json

dirs: build/.dir $(CHROME_DIRS) $(FIREFOX_DIRS)

build/chrome/manifest.json: src/chrome/manifest.json
	sed 's/@version/"$(VERSION)"/' $< > $@

build/firefox/package.json: src/firefox/package.json src/common/data/countries.json
	coffee makeFirefoxPackageJSON.coffee $(VERSION)

build/.temp-chrome/.dir:
	mkdir $(dir $@)
	@touch $@

build/.temp-chrome/%: src/chrome/coffee/%
	cp $< $@

build/.temp-chrome/%: src/chrome/coffee/tests/%
	cp $< $@

build/.temp-chrome/%: src/common/coffee/%
	cp $< $@

build/.temp-chrome/%: src/common/libs/%
	cp $< $@

build/.temp-firefox/.dir:
	mkdir $(dir $@)
	@touch $@

build/.temp-firefox/%: src/firefox/coffee/%
	cp $< $@

build/.temp-firefox/%: src/common/coffee/%
	cp $< $@

build/.temp-firefox/%: src/common/libs/%
	cp $< $@


build/chrome/js/%.js: build/.temp-chrome/.dir $(CHROME_TEMP_TARGET_FILES)
	browserify --debug --transform coffeeify --extension=".coffee" \
		./build/.temp-chrome/$(basename $(@F)).coffee -o $@

build/chrome/js/qunit.js: build/.temp-chrome/.dir $(CHROME_TEMP_TARGET_FILES)
	browserify --debug -r ./build/.temp-chrome/qunit-1.11.0.js -o $@

build/chrome/js/unit.js: build/chrome/js/qunit.js $(CHROME_TEMP_TARGET_FILES)
	browserify --debug --transform coffeeify --extension=".coffee" \
		-x ./build/.temp-chrome/qunit-1.11.0.js build/.temp-chrome/$(basename $(@F)).coffee -o $@

build/chrome/js/functional.js: build/chrome/js/qunit.js $(CHROME_TEMP_TARGET_FILES)
	browserify --debug --transform coffeeify --extension=".coffee" \
		-x ./build/.temp-chrome/qunit-1.11.0.js build/.temp-chrome/$(basename $(@F)).coffee -o $@

build/firefox/data/popup.js: build/.temp-firefox/.dir $(FIREFOX_TEMP_TARGET_FILES)
	browserify --debug --transform coffeeify --extension=".coffee" \
		./build/.temp-firefox/$(basename $(@F)).coffee -o $@

build/firefox/lib/%.js: $(FIREFOX_COFFEE_FILES) $(COMMON_COFFEE_FILES)
	mkdir -p build/firefox/lib
	cp src/common/libs/*.js build/firefox/lib/
	coffee -m -c -o build/firefox/lib/ $(FIREFOX_COFFEE_DIR) $(COMMON_COFFEE_DIR)

chrome_html: dirs $(patsubst src/common/%, build/chrome/%, $(COMMON_HTML_FILES)) \
   			$(patsubst src/%, build/%, $(CHROME_HTML_FILES))
firefox_html: dirs $(patsubst src/common/%, build/firefox/data/%,\
   	$(COMMON_HTML_FILES)) $(patsubst src/%, build/%, $(FIREFOX_HTML_FILES))

chrome_libs: dirs $(patsubst src/common/%, build/chrome/%, $(COMMON_LIBS_FILES)) \
   	$(patsubst src/%, build/%, $(CHROME_LIBS_FILES))

chrome_images: dirs $(patsubst src/common/%, build/chrome/%, \
	$(COMMON_IMAGE_FILES)) $(patsubst src/%, build/%, $(CHROME_IMAGE_FILES))
firefox_images: dirs $(patsubst src/common/%, build/firefox/data/%, \
	$(COMMON_IMAGE_FILES)) $(patsubst src/%, build/%, $(FIREFOX_IMAGE_FILES))

chrome_data: dirs $(patsubst src/common/%, build/chrome/%, $(COMMON_DATA_FILES)) \
	$(patsubst src/%, build/%, $(CHROME_DATA_FILES))
firefox_data: dirs $(patsubst src/common/%, build/firefox/data/%, \
	$(COMMON_DATA_FILES)) $(patsubst src/%, build/%, $(FIREFOX_DATA_FILES))

watch:
	while true; do make | grep --invert-match "^make\[1\]:"; sleep 1; done

CHROME_PACKAGE_NAME = $(PACKAGE_NAME)-chrome

package-chrome: chrome
	cp -r build/chrome $(CHROME_PACKAGE_NAME)
	rm -f $(patsubst build/chrome/%,$(CHROME_PACKAGE_NAME)/%,$(CHROME_DIRS))
	rm -rf $(CHROME_PACKAGE_NAME)/js/functional.js $(CHROME_PACKAGE_NAME)/js/qunit.js\
	       	$(CHROME_PACKAGE_NAME)/js/unit.js $(CHROME_PACKAGE_NAME)/html/test.html\
	       	$(CHROME_PACKAGE_NAME)/libs
	zip -r $(CHROME_PACKAGE_NAME).zip $(CHROME_PACKAGE_NAME)/
	rm -rf $(CHROME_PACKAGE_NAME)

build/.temp-firefox/tmp.xpi: firefox
	cfx xpi --pkgdir=build/firefox --output-file=$@

load-firefox: build/.temp-firefox/tmp.xpi
	wget --post-file=build/.temp-firefox/tmp.xpi "http://localhost:8888" 2>&1 |\
	   	grep --invert-match 399 #ignore 399 errors, they are normal

%/.dir:
	mkdir $*
	@touch $@

build/chrome/%: src/chrome/%
	cp $< $@

build/chrome/%: src/common/%
	cp $< $@

build/firefox/data/%: src/firefox/%
	cp $< $@

build/firefox/data/%: src/common/%
	cp $< $@

clean:
	rm -rf build

.PHONY: all firefox chrome dirs chrome_dirs firefox_dirs coffee clean watch \
	package_chrome
