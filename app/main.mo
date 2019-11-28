/**
 * File        : main.mo
 * Copyright   : 2019 Enzo Haussecker
 * License     : Apache 2.0 with LLVM Exception
 * Maintainer  : Enzo Haussecker <enzo@dfinity.org>
 * Stability   : Experimental
 */

actor Main {

    public query func index() : async Text {
        "<!DOCTYPE html><html><body><h1>Hello World!</h1></body></html>\n"
    };

}
