# File       : Makefile
# Copyright  : 2019 Enzo Haussecker
# License    : Apache 2.0 with LLVM Exception
# Maintainer : Enzo Haussecker <enzo@dfinity.org>
# Stability  : Experimental

SRC = src

HTML = /usr/share/java/htmlcompressor-1.5.3.jar
CSS  = /usr/share/java/yuicompressor-2.4.8.jar
JS   = $(CSS)

E1 = "s/\\\"/\\\\\\\\\"/g"
E2 = "s/\//\\\\\//g"

.PHONY: all
all: $(SRC)/index.mo

.PHONY: clean
clean:
	rm -f $(SRC)/index.mo

$(SRC)/index.mo:
	cat $(SRC)/index.template | #\\ \
		sed -e "s/HTML/\"$$( \
			java -jar $(HTML) $(SRC)/index.html | \
				sed -e $(E1) | \
				sed -e $(E2) \
		)\\\\n\"/g" | #\\ \
		sed -e "s/CSS/\"$$( \
			java -jar $(CSS) $(SRC)/index.css | \
				sed -e $(E1) | \
				sed -e $(E2) \
		)\\\\n\"/g" | #\\ \
		sed -e "s/JS/\"$$( \
			java -jar $(JS) $(SRC)/index.js | \
				sed -e $(E1) | \
				sed -e $(E2) \
		)\\\\n\"/g" > $@
