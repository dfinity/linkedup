/**
 * File       : util.mo
 * Copyright  : 2019 Enzo Haussecker
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Enzo Haussecker <enzo@dfinity.org>
 * Stability  : Experimental
 */

import Array "mo:stdlib/array.mo";
import Result "mo:stdlib/result.mo";

module Util {

  type Result<Ok, Error> = Result.Result<Ok, Error>;

  /**
   * Convert an unsigned 8-bit integer to an unsigned 32-bit integer.
   */
  public func convWord8ToWord32(byte : Word8) : Word32 {
    natToWord32(word8ToNat(byte))
  };

  /**
   * Convert an unsigned 8-bit integer array to an unsigned integer.
   */
  public func convWord8ArrayToNat(bytes : [Word8]) : Nat {
    var n = 0;
    var i = 0;
    Array.foldr<Word8, ()>(func (byte, _) {
      n += word8ToNat(byte) * 256 ** i;
      i += 1
    }, (), bytes);
    n
  };

  /**
   * Decode an unsigned 8-bit integer.
   */
  public func decodeWord8(next : () -> ?Word8) : Result<Word8, Text> {
    Result.fromOption<Word8, Text>(next(), "Not enough input!")
  };

  /**
   * Decode an unsigned 8-bit integer and perform an action with it.
   */
  public func decodeWord8Then<T>(
    next : () -> ?Word8,
    f : Word8 -> Result<T, Text>
  ) : Result<T, Text> {
    Result.bind<Word8, T, Text>(decodeWord8(next), f)
  };

  /**
   * Decode an unsigned 8-bit integer array.
   */
  public func decodeWord8Array(
    n : Nat,
    next : () -> ?Word8
  ) : Result<[Word8], Text> {
    var bytes = Array_init<Word8>(n, 0);
    var i = 0;
    while (i < n) {
      switch (decodeWord8(next)) {
        case (#ok(byte)) {
          bytes[i] := byte
        };
        case (#err(text)) {
          return #err(text)
        }
      };
      i += 1
    };
    #ok(Array.freeze<Word8>(bytes))
  };

  /**
   * Decode an unsigned 8-bit integer array and perform an action with it.
   */
  public func decodeWord8ArrayThen<T>(
    n : Nat,
    next : () -> ?Word8,
    f : [Word8] -> Result<T, Text>
  ) : Result<T, Text> {
    Result.bind<[Word8], T, Text>(decodeWord8Array(n, next), f)
  };

  /**
   * TODO: Documentation.
   */
  public func decodeWord8ArrayOfWord8SizeThen<T>(
    next : () -> ?Word8,
    f : [Word8] -> Result<T, Text>
  ) : Result<T, Text> {
    decodeWord8Then<T>(next, func (n) {
      decodeWord8ArrayThen<T>(word8ToNat(n), next, f)
    })
  };

  /**
   * TODO: Documentation.
   */
  public func decodeWord8ArrayOfWord16SizeThen<T>(
    next : () -> ?Word8,
    f : [Word8] -> Result<T, Text>
  ) : Result<T, Text> {
    decodeWord16Then<T>(next, func (n) {
      decodeWord8ArrayThen<T>(word16ToNat(n), next, f)
    })
  };

  /**
   * Decode an unsigned 16-bit integer.
   */
  public func decodeWord16(next : () -> ?Word8) : Result<Word16, Text> {
    Result.mapOk<[Word8], Word16, Text>(
      decodeWord8Array(2, next),
      func (bytes) {
        natToWord16(convWord8ArrayToNat(bytes))
      }
    )
  };

  /**
   * Decode an unsigned 16-bit integer and perform an action with it.
   */
  public func decodeWord16Then<T>(
    next : () -> ?Word8,
    f : Word16 -> Result<T, Text>
  ) : Result<T, Text> {
    Result.bind<Word16, T, Text>(decodeWord16(next), f)
  };

  /**
   * Decode an unsigned 64-bit integer.
   */
  public func decodeWord64(next : () -> ?Word8) : Result<Word64, Text> {
    Result.mapOk<[Word8], Word64, Text>(
      decodeWord8Array(8, next),
      func (bytes) {
        natToWord64(convWord8ArrayToNat(bytes))
      }
    )
  };

  /**
   * Decode an unsigned 64-bit integer and perform an action with it.
   */
  public func decodeWord64Then<T>(
    next : () -> ?Word8,
    f : Word64 -> Result<T, Text>
  ) : Result<T, Text> {
    Result.bind<Word64, T, Text>(decodeWord64(next), f)
  };

  /**
   * Decode a nonce and message type and perform an action with them.
   */
  public func decodeMetadataThen<T>(
    next : () -> ?Word8,
    f : (Word64, Word8) -> Result<T, Text>
  ) : Result<T, Text> {
    decodeWord64Then<T>(next, func (nonce) {
      decodeWord8Then<T>(next, func (messageType) {
        f(nonce, messageType)
      })
    })
  }
}
