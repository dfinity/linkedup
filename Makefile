# File       : Makefile
# Copyright  : 2019 Enzo Haussecker
# License    : Apache 2.0 with LLVM Exception
# Maintainer : Enzo Haussecker <enzo@dfinity.org>
# Stability  : Experimental

SRC = src
TGT = app

HTML = /usr/share/java/htmlcompressor-1.5.3.jar
CSS  = /usr/share/java/yuicompressor-2.4.8.jar
JS   = $(CSS)

.PHONY: all
all: $(TGT)/index.mo

.PHONY: clean
clean:
	rm -rf $(TGT)

$(TGT)/index.mo: $(TGT)
	cat $(SRC)/index.template | #\\ \
		sed -e "s/HTML/\"$$( \
			java -jar $(HTML) $(SRC)/index.html | \
				sed -e "s/\\\"/\\\\\\\\\"/g" | \
				sed -e "s/\//\\\\\//g" \
		)\"/g" | #\\ \
		sed -e "s/CSS/\"$$( \
			java -jar $(CSS) $(SRC)/index.css | \
				sed -e "s/\\\"/\\\\\\\\\"/g" | \
				sed -e "s/\//\\\\\//g" \
		)\"/g" | #\\ \
		sed -e "s/JS/\"$$( \
			java -jar $(JS) $(SRC)/index.js | \
				sed -e "s/\\\"/\\\\\\\\\"/g" | \
				sed -e "s/\//\\\\\//g" \
		)\"/g" | #\\ \
		tee $@

$(TGT):
	mkdir -p $@
