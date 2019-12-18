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
        return Util.equals<Word8>(x.unbox, y.unbox, func (xi, yi) {xi == yi});
    };

    /**
     * Create a trie key from a profile identifier.
     */
    func key(x : ProfileId) : Trie.Key<ProfileId> {
        func convert(bytes : [Word8]) : [Word32] {
            return Array.map<Word8, Word32>(Util.word8ToWord32, bytes);
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
        firstName : Text;
        lastName : Text;
        title : Text;
        company : Text;
        experience : Text;
    };

    /**
     * Decode a profile or fail.
     */
    func decodeProfileOrFail(next : () -> ?Word8) : Profile {

        // Decode a first name or fail.
        let firstNameLen = word8ToNat(Util.decodeByteOrFail(next));
        var firstNamePrime = "" : Text;
        var i = 0;
        while (i < firstNameLen) {
            firstNamePrime #= charToText(Util.decodeASCIIOrFail(next));
            i += 1;
        };

        // Decode a last name or fail.
        let lastNameLen = word8ToNat(Util.decodeByteOrFail(next));
        var lastNamePrime = "";
        i := 0;
        while (i < lastNameLen) {
            lastNamePrime #= charToText(Util.decodeASCIIOrFail(next));
            i += 1;
        };

        // Decode a title or fail.
        let titleLen = word8ToNat(Util.decodeByteOrFail(next));
        var titlePrime = "";
        i := 0;
        while (i < titleLen) {
            titlePrime #= charToText(Util.decodeASCIIOrFail(next));
            i += 1;
        };

        // Decode a company or fail.
        let companyLen = word8ToNat(Util.decodeByteOrFail(next));
        var companyPrime = "";
        i := 0;
        while (i < companyLen) {
            companyPrime #= charToText(Util.decodeASCIIOrFail(next));
            i += 1;
        };

        // Decode an experience or fail.
        let experienceLen = 256
            * word8ToNat(Util.decodeByteOrFail(next))
            + word8ToNat(Util.decodeByteOrFail(next));
        var experiencePrime = "";
        i := 0;
        while (i < experienceLen) {
            experiencePrime #= charToText(Util.decodeASCIIOrFail(next));
            i += 1;
        };

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
        let _ = Util.decodeNonceOrFail(next);
        let messgeType = word8ToNat(Util.decodeByteOrFail(next));
        switch messgeType {

            // Add a profile to the profile database.
            case 1 {
                let profileId = {
                    unbox = signer;
                };
                let profile = decodeProfileOrFail(next);
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
