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
import Prelude "mo:stdlib/prelude.mo";
import Trie "mo:stdlib/trie.mo";
import Util "../util/util.mo"

type Trie<Key, Value> = Trie.Trie<Key, Value>;

actor Profile {

    /**
     * The type of a profile identifier.
     */
    public type ProfileId = {
        unbox : [Word8];
    };

    /**
     * Test profile identifiers for equality.
     */
    func eq(x : ProfileId, y : ProfileId) : Bool {
        return Array.equals<Word8>(x.unbox, y.unbox, func (xi, yi) {xi == yi});
    };

    /**
     * Create a trie key from a profile identifier.
     */
    func key(x : ProfileId) : Trie.Key<ProfileId> {
        func convert(bytes : [Word8]) : [Word32] {
            return Array.map<Word8, Word32>(Util.convertByteToWord32, bytes);
        };
        return {
            key = x;
            hash = Hash.BitVec.hashWord8s(convert(x.unbox));
        };
    };

    /**
     * The type of a profile.
     */
    public type Profile = {
        firstName : [Word8];
        lastName : [Word8];
        title : [Word8];
        company : [Word8];
        experience : [Word8];
    };

    /**
     * Decode a profile or trap.
     */
    func decodeProfileOrTrap(next : () -> ?Word8) : Profile {

        // Decode a first name or trap.
        let firstNameLen = word8ToNat(Util.decodeByteOrTrap(next));
        let firstNamePrime = Util.decodeByteArrayOrTrap(firstNameLen, next);

        // Decode a last name or trap.
        let lastNameLen = word8ToNat(Util.decodeByteOrTrap(next));
        let lastNamePrime = Util.decodeByteArrayOrTrap(lastNameLen, next);

        // Decode a title or trap.
        let titleLen = word8ToNat(Util.decodeByteOrTrap(next));
        let titlePrime = Util.decodeByteArrayOrTrap(titleLen, next);

        // Decode a company or trap.
        let companyLen = word8ToNat(Util.decodeByteOrTrap(next));
        let companyPrime = Util.decodeByteArrayOrTrap(companyLen, next);

        // Decode an experience or trap.
        let experienceLen = word16ToNat(Util.decodeWord16OrTrap(next));
        let experiencePrime = Util.decodeByteArrayOrTrap(experienceLen, next);

        // Return.
        return {
            firstName = firstNamePrime;
            lastName = lastNamePrime;
            title = titlePrime;
            company = companyPrime;
            experience = experiencePrime;
        };
    };

    /**
     * The type of the profile database.
     */
    type ProfileDatabase = Trie<ProfileId, Profile>;

    /**
     * Initialize the profile database.
     */
    var profiles : ProfileDatabase = Trie.empty<ProfileId, Profile>();

    /**
     * Find a profile in the profile database.
     */
    public func find(profileId : ProfileId) : async (?Profile) {
        return Trie.find<ProfileId, Profile>(profiles, key(profileId), eq);
    };

    /**
     * Perform a privileged operation on the profile database.
     */
    public func run(
        signer : [Word8],
        signature : [Word8],
        message : [Word8]
    ) : async Bool {
        // let authentic = Account.authenticate(signer, signature, message);
        // if (not authentic) {
        //     return false;
        // };
        let stream = Iter.fromArray<Word8>(message);
        let next = stream.next;
        let _ = Util.decodeWord64OrTrap(next);
        let messgeType = word8ToNat(Util.decodeByteOrTrap(next));
        switch messgeType {

            // Add a profile to the profile database.
            case 1 {
                let profileId = {
                    unbox = signer;
                };
                let profile = decodeProfileOrTrap(next);
                profiles := Trie.insert<ProfileId, Profile>(
                    profiles,
                    key(profileId),
                    eq,
                    profile
                ).0;
                return true;
            };

            // Remove a profile from the profile database.
            case 2 {
                let profileId = {
                    unbox = signer;
                };
                profiles := Trie.remove<ProfileId, Profile>(
                    profiles,
                    key(profileId),
                    eq
                ).0;
                return true;
            };

            // Invalid message type.
            case _ {
                Prelude.printLn("invalid message type");
                return false;
            };
        };
    };

};
