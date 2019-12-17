/**
 * File       : util.mo
 * Copyright  : 2019 Enzo Haussecker
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Enzo Haussecker <enzo@dfinity.org>
 * Stability  : Experimental
 */

import Array "mo:stdlib/array.mo";
import Option "mo:stdlib/option.mo";

module Util {

    /**
     * Decode an ASCII character or fail.
     */
    public func decodeASCIIOrFail(next : () -> ?Word8) : Char {
        return word32ToChar(word8ToWord32(decodeByteOrFail(next)));
    };

    /**
     * Decode a byte or fail.
     */
    public func decodeByteOrFail(next : () -> ?Word8) : Word8 {
        return Option.unwrap<Word8>(next());
    };

    /**
     * Decode a byte array or fail.
     */
    public func decodeByteArrayOrFail(n : Nat, next : () -> ?Word8) : [Word8] {
        var array = Array_init<Word8>(n, 0);
        var i = 0;
        while (i < n) {
            array[i] := decodeByteOrFail(next);
            i += 1;
        };
        return Array.freeze<Word8>(array);
    };

    /**
     * Decode a nonce or fail.
     */
    public func decodeNonceOrFail(next : () -> ?Word8) : Word64 {
        var n = 0;
        var i = 7 : Int;
        while (i >= 0) {
            n += word8ToNat(decodeByteOrFail(next)) * 256 ** abs(i);
            i -= 1 : Int;
        };
        return natToWord64(n);
    };

    /**
     * Test arrays for equality.
     */
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
        return true;
    };

    /**
     * Convert an 8-bit unsigned integer to a 32-bit unsigned integer.
     */
    public func word8ToWord32(byte : Word8) : Word32 {
        return natToWord32(word8ToNat(byte));
    };

};
