# File       : Makefile
# Copyright  : 2019 Enzo Haussecker
# License    : Apache 2.0 with LLVM Exception
# Maintainer : Enzo Haussecker <enzo@dfinity.org>
# Stability  : Experimental

DFX = dfx

SOURCE = src
TARGET = build

INDEX = $(TARGET)/index
NGINX = $(TARGET)/nginx

HTML_COMPRESSOR = /usr/share/java/htmlcompressor-1.5.3.jar
YUI_COMPRESSOR = /usr/share/java/yuicompressor-2.4.8.jar

C1 = ":a; s/(.*)\/\*.*\*\//\1/; ta; /\/\*/ !b; N; ba"
C2 = ":a; N; \$$!ba; s/\n//g"

compress = java -jar $(1) $(2)
compress_html = $(call compress,$(HTML_COMPRESSOR),$1)
compress_css = $(call compress,$(YUI_COMPRESSOR),$1)
compress_js = sed -r $(C1) -e $(C2) $(1)

E1 = "s/\([\"\\]\)/\\\\\1/g"
E2 = "s/\([&/@\\]\)/\\\\\1/g"

escape = sed -e $(E1) -e $(E2)

canister_id = xxd -p -u $(1) | sed -e "s/.*/ibase=16; \0/" | bc

.PHONY: all
all: nginx

.PHONY: profile
profile:
	$(DFX) build $@

$(SOURCE)/index.js: profile
	npm run webpack

$(SOURCE)/index.sed: $(SOURCE)/index.js
	printf "s/___HTML___/\"" > $@
	$(call compress_html,$(SOURCE)/index.html) | $(escape) >> $@
	printf "\"/g\ns/___CSS___/\"" >> $@
	$(call compress_css,$(SOURCE)/index.css) | $(escape) >> $@
	printf "\"/g\ns/___JS___/\"" >> $@
	$(call compress_js,$<) | $(escape) >> $@
	printf "\"/g\n" >> $@

$(SOURCE)/index.mo: $(SOURCE)/index.sed
	sed -f $< $(SOURCE)/index.template > $@

.PHONY: index
index: $(SOURCE)/index.mo
	$(DFX) build $@

$(NGINX):
	mkdir -p $@

$(NGINX)/index.lua: $(NGINX)
	cp $(SOURCE)/index.lua $@

.ONESHELL:
$(NGINX)/nginx.conf: $(NGINX) index
	ID=$$($(call canister_id, $(INDEX)/_canister.id))
	sed -e "s/___ID___/$$ID/g" $(SOURCE)/nginx.template > $@

.PHONY: nginx
nginx: $(NGINX)/index.lua $(NGINX)/nginx.conf

.PHONY: install
install:
	$(DFX) canister install --all

.PHONY: clean
clean:
	rm -f $(SOURCE)/index.{js,mo,sed}
	rm -rf $(TARGET)
