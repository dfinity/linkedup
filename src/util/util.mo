/**
 * File       : util.mo
 * Copyright  : 2019 Enzo Haussecker
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Enzo Haussecker <enzo@dfinity.org>
 * Stability  : Experimental
 */

module Util {

    public func equals<T>(a : [T], b : [T], eq : (T, T) -> Bool) : Bool {
        if (a.len() != b.len()) { 
            return false;
        };
        var i = 0;
        while (i < a.len()) {
            if (not eq(a[i], b[i])) {
                return false;
            };
            i += 1;
        };
        true
    };

    public func word8ToWord32(byte : Word8) : Word32 {
        natToWord32(word8ToNat(byte))
    };

}
