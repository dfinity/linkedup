# File       : Makefile
# Copyright  : 2019 Enzo Haussecker
# License    : Apache 2.0 with LLVM Exception
# Maintainer : Enzo Haussecker <enzo@dfinity.org>
# Stability  : Experimental

SOURCE = src
TARGET = build

INDEX = $(TARGET)/index
NGINX = $(TARGET)/nginx

HTML_COMPRESSOR = /usr/share/java/htmlcompressor-1.5.3.jar
YUI_COMPRESSOR = /usr/share/java/yuicompressor-2.4.8.jar

compress = java -jar $(1) $(2)
compress_html = $(call compress,$(HTML_COMPRESSOR),$1)
compress_css = $(call compress,$(YUI_COMPRESSOR),$1)
compress_js = $(compress_css)

E1 = "s/\\\"/\\\\\\\\\"/g"
E2 = "s/\&/\\\\\&/g"
E3 = "s/\//\\\\\//g"

escape = sed -e $(E1) -e $(E2) -e $(E3)

show_id = xxd -p -u $(1) | sed -e "s/.*/ibase=16; \0/" | bc

.PHONY: all
all: nginx

$(SOURCE)/index.mo:
	HTML=$$($(call compress_html,$(SOURCE)/index.html) | $(escape)) #\\ \
	CSS=$$($(call compress_css,$(SOURCE)/index.css) | $(escape)) #\\ \
	JS=$$($(call compress_js,$(SOURCE)/index.js) | $(escape)) #\\ \
	cat $(SOURCE)/index.template | sed \
		-e "s/__INCLUDE_HTML__/\"$$HTML\\\\n\"/g" \
		-e "s/__INCLUDE_CSS__/\"$$CSS\\\\n\"/g" \
		-e "s/__INCLUDE_JS__/\"$$JS\\\\n\"/g" > $@

.PHONY: profile
profile:
	dfx build $@

.PHONY: social-graph
social-graph:
	dfx build $@

.PHONY: index
index: $(SOURCE)/index.mo | profile social-graph
	dfx build $@

$(NGINX):
	mkdir -p $@

$(NGINX)/index.lua: $(NGINX)
	cp $(SOURCE)/index.lua $@

$(NGINX)/nginx.conf: $(NGINX) | index
	ID=$$($(call show_id, $(INDEX)/_canister.id)) #\\ \
	cat $(SOURCE)/nginx.template | sed \
		-e "s/canister_id ''/canister_id '$$ID'/g" > $@

.PHONY: nginx
nginx: $(NGINX)/index.lua $(NGINX)/nginx.conf

.PHONY: install
install:
	dfx canister install --all

.PHONY: clean
clean:
	rm -f $(SOURCE)/index.mo
	rm -rf $(TARGET)
