/**
 * File       : main.mo
 * Copyright  : 2019 Enzo Haussecker
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Enzo Haussecker <enzo@dfinity.org>
 * Stability  : Experimental
 */

import Array "mo:stdlib/array.mo";
import Hash "mo:stdlib/hash.mo";
import Iter "mo:stdlib/iter.mo";
import Result "mo:stdlib/result.mo";
import Trie "mo:stdlib/trie.mo";
import Util "../common/util.mo";

actor Profile {

  type Result<Ok, Error> = Result.Result<Ok, Error>;
  type Trie<Key, Value> = Trie.Trie<Key, Value>;

  /**
   * The type of a user identifier.
   */
  public type UserId = {
    unbox : [Word8]
  };

  /**
   * Test user identifiers for equality.
   */
  func eq(x : UserId, y : UserId) : Bool {
    Array.equals<Word8>(x.unbox, y.unbox, func (xi, yi) {
      xi == yi
    })
  };

  /**
   * Create a trie key from a user identifier.
   */
  func key(x : UserId) : Trie.Key<UserId> {
    func convert(bytes : [Word8]) : [Word32] {
      Array.map<Word8, Word32>(Util.convWord8ToWord32, bytes)
    };
    {
      key = x;
      hash = Hash.BitVec.hashWord8s(convert(x.unbox))
    }
  };

  /**
   * The type of a profile.
   */
  public type Profile = {
    firstName : [Word8];
    lastName : [Word8];
    title : [Word8];
    company : [Word8];
    experience : [Word8]
  };

  /**
   * Decode a profile.
   */
  func decodeProfile(next : () -> ?Word8) : Result<Profile, Text> {
    Util.decodeWord8ArrayOfWord8SizeThen<Profile>(next, func (bytes0) {
      Util.decodeWord8ArrayOfWord8SizeThen<Profile>(next, func (bytes1) {
        Util.decodeWord8ArrayOfWord8SizeThen<Profile>(next, func (bytes2) {
          Util.decodeWord8ArrayOfWord8SizeThen<Profile>(next, func (bytes3) {
            Util.decodeWord8ArrayOfWord16SizeThen<Profile>(next, func (bytes4) {
              #ok({
                firstName = bytes0;
                lastName = bytes1;
                title = bytes2;
                company = bytes3;
                experience = bytes4
              })
            })
          })
        })
      })
    })
  };

  /**
   * The type of the profile database.
   */
  type ProfileDatabase = Trie<UserId, Profile>;

  /**
   * Initialize the profile database.
   */
  var profiles : ProfileDatabase = Trie.empty<UserId, Profile>();

  /**
   * Find a profile in the profile database.
   */
  public func find(userId : UserId) : async (?Profile) {
    Trie.find<UserId, Profile>(profiles, key(userId), eq)
  };

  /**
   * Insert a profile into the profile database.
   */
  func insert(userId : UserId, profile : Profile) {
    profiles := Trie.insert<UserId, Profile>(
      profiles,
      key(userId),
      eq,
      profile
    ).0
  };

  /**
   * Delete a profile from the profile database.
   */
  func delete(userId : UserId) {
    profiles := Trie.remove<UserId, Profile>(
      profiles,
      key(userId),
      eq
    ).0
  };

  /**
   * The type of an execution report.
   */
  public type ExecutionReport = {
    success : Bool;
    message : Text
  };

  /**
   * Perform a privileged operation on the profile database.
   */
  public /* shared { caller = signer } */ func run(
    signer : [Word8],
    signature : [Word8],
    message : [Word8]
  ) : async ExecutionReport {

    //// Check if the message is authentic.
    //let authentic = Account.authenticate(signer, signature, message);
    //if (not authentic) {
    //  return {
    //    success = false;
    //    message = "Authentication failure."
    //  }
    //};

    // Create an iterator from the message.
    let stream = Iter.fromArray<Word8>(message);
    let next = stream.next;

    // Define a function to process the message.
    func go() : Result<(), Text> {
      Util.decodeMetadataThen<()>(next, func (_, messgeType) {
        let userId = {
          unbox = signer
        };
        switch messgeType {

          // Insert a profile into the profile database.
          case 1 {
            Result.bind<Profile, (), Text>(decodeProfile(next), func (profile) {
              insert(userId, profile);
              #ok()
            })
          };

          // Delete a profile from the profile database.
          case 2 {
            delete(userId);
            #ok()
          };

          // Invalid message type!
          case _ {
            #err("Invalid message type!")
          }
        }
      })
    };

    // Process the message.
    switch (go()) {

      // Success!
      case (#ok()) {
        success = true;
        message = "Success!"
      };

      // Something went wrong!
      case (#err(text)) {
        success = false;
        message = text
      }
    }
  }
}
