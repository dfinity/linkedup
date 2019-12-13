# File       : Makefile
# Copyright  : 2019 Enzo Haussecker
# License    : Apache 2.0 with LLVM Exception
# Maintainer : Enzo Haussecker <enzo@dfinity.org>
# Stability  : Experimental

DFX = dfx
NODE = node
NGINX = nginx

SOURCE = src
TARGET = build

HTML_COMPRESSOR = /usr/share/java/htmlcompressor-1.5.3.jar
YUI_COMPRESSOR = /usr/share/java/yuicompressor-2.4.8.jar

R1 = ":a; s/(.*)\/\*.*\*\//\1/; ta; /\/\*/ !b; N; ba"
R2 = ":a; N; \$$!ba; s/\n//g"

compress = java -jar $(1) $(2)
compress_html = $(call compress,$(HTML_COMPRESSOR),$1)
compress_css = $(call compress,$(YUI_COMPRESSOR),$1)
compress_js = cat $(1) | sed -r $(R1) | sed -r $(R2)

E1 = "s/\([\"\\]\)/\\\\\1/g"
E2 = "s/\([&/@\\]\)/\\\\\1/g"

escape = sed -e $(E1) -e $(E2)

canister_id = xxd -p -u $(1) | sed -e "s/.*/ibase=16; \0/" | bc

.PHONY: all
all: nginx

.PHONY: graph
graph:
	$(DFX) build $@

.PHONY: profile
profile:
	$(DFX) build $@

$(SOURCE)/index/index.js: graph profile
	$(NODE) node_modules/webpack-cli/bin/cli.js

.ONESHELL:
$(SOURCE)/index/main.sed: $(SOURCE)/index/index.js
	HTML=$$($(call compress_html,$(SOURCE)/index/index.html) | $(escape))
	CSS=$$($(call compress_css,$(SOURCE)/index/index.css) | $(escape))
	JS=$$($(call compress_js,$<) | $(escape))
	cat > $@ <<EOF
	s/___HTML___/"$$HTML"/g
	s/___CSS___/"$$CSS"/g
	s/___JS___/"$$JS"/g
	EOF

$(SOURCE)/index/main.mo: $(SOURCE)/index/main.sed
	sed -f $< $(SOURCE)/index/main.template > $@

.PHONY: index
index: $(SOURCE)/index/main.mo
	$(DFX) build $@

$(TARGET)/nginx:
	mkdir -p $@

$(TARGET)/nginx/index.lua: $(TARGET)/nginx
	cp $(SOURCE)/nginx/index.lua $@

.ONESHELL:
$(TARGET)/nginx/nginx.conf: $(TARGET)/nginx index
	ID=$$($(call canister_id, $(TARGET)/index/_canister.id))
	sed -e "s/___ID___/$$ID/g" $(SOURCE)/nginx/nginx.template > $@

.PHONY: nginx
nginx: $(TARGET)/nginx/index.lua $(TARGET)/nginx/nginx.conf

.PHONY: install
install:
	$(DFX) canister install --all

.PHONY: run
run:
	$(NGINX) -c nginx.conf -p build/nginx

.PHONY: clean
clean:
	rm -f $(SOURCE)/index/index.js
	rm -f $(SOURCE)/index/main.mo
	rm -f $(SOURCE)/index/main.sed
	rm -rf $(TARGET)
