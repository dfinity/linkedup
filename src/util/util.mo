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
     * Convert a byte to an unsigned 32-bit integer.
     */
    public func convertByteToWord32(byte : Word8) : Word32 {
        return natToWord32(word8ToNat(byte));
    };

    /**
     * Convert a byte array to an unsigned integer.
     */
    public func convertByteArrayToNat(bytes : [Word8]) : Nat {
        var n = 0;
        var i = 0;
        Array.foldr<Word8, ()>(func (byte, _) {
            n += word8ToNat(byte) * 256 ** i;
            i += 1;
        }, (), bytes);
        return n;
    };

    /**
     * Decode a byte or trap.
     */
    public func decodeByteOrTrap(next : () -> ?Word8) : Word8 {
        return Option.unwrap<Word8>(next());
    };

    /**
     * Decode a byte array or trap.
     */
    public func decodeByteArrayOrTrap(n : Nat, next : () -> ?Word8) : [Word8] {
        var array = Array_init<Word8>(n, 0);
        var i = 0;
        while (i < n) {
            array[i] := decodeByteOrTrap(next);
            i += 1;
        };
        return Array.freeze<Word8>(array);
    };

    /**
     * Decode an unsigned 16-bit integer or trap.
     */
    public func decodeWord16OrTrap(next : () -> ?Word8) : Word16 {
        let bytes = decodeByteArrayOrTrap(2, next);
        return natToWord16(convertByteArrayToNat(bytes));
    };

    /**
     * Decode an unsigned 64-bit integer or trap.
     */
    public func decodeWord64OrTrap(next : () -> ?Word8) : Word64 {
        let bytes = decodeByteArrayOrTrap(8, next);
        return natToWord64(convertByteArrayToNat(bytes));
    };

};
