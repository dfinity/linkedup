/**
 * File       : main.mo
 * Copyright  : 2019 Enzo Haussecker
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Enzo Haussecker <enzo@dfinity.org>
 * Stability  : Experimental
 */

import Array "mo:stdlib/array.mo";
import Hash "mo:stdlib/hash.mo";
import Prelude "mo:stdlib/prelude.mo";
import Trie "mo:stdlib/trie.mo";

import Util "../util/util.mo"

type Trie<K,V> = Trie.Trie<K,V>;

actor Profile {

    /**
     * The type of a profile identifier.
     */
    type ProfileId = {
        unbox : [Word8];
    };

    /**
     * Test profile identifiers for equality.
     *
     * TODO: Replace 'Util.equals' with 'Array.equals' once dfx 0.4.10 becomes
     * available.
     */
    func eqProfileId(x : ProfileId, y : ProfileId) : Bool {
        Util.equals<Word8>(x.unbox, y.unbox, func (xi, yi) {xi == yi})
    };

    /**
     * Create a trie key from a profile identifier.
     */
    func keyProfileId(profileId : ProfileId) : Trie.Key<ProfileId> {
        func convert(array : [Word8]) : [Word32] {
            Array.map<Word8, Word32>(Util.word8ToWord32, array)
        };
        {
            key = profileId;
            hash = Hash.BitVec.hashWord8s(convert(profileId.unbox));
        }
    };

    /**
     * The type of a profile.
     */
    type Profile = {
        firstName : Text;
        lastName : Text;
        organization : Text;
        position : Text;
        summary : Text;
    };

    /**
     * Serialize a profile.
     */
    func serialize(profile : Profile) : [Word8] {
        Prelude.printLn("serialize: Not yet implemented!");
        Prelude.unreachable()
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
    public func lookup(profileId : ProfileId) : async (?Profile) {
        Trie.find<ProfileId, Profile>(
            profiles,
            keyProfileId(profileId),
            eqProfileId
        )
    };

    /**
     * Insert a profile into the profile database.
     */
    public func insert(
        signer : [Word8],
        signature : [Word8],
        nonce : Word64,
        profile : Profile
    ) : async Bool {
        //let message = serialize(profile);
        //let digest = Sha256.hash(message);
        //let success = Account.authenticate(signer, signature, nonce, digest);
        //if (success) {
            let profileId = {
                unbox = signer;
            };
            profiles := Trie.insert<ProfileId, Profile>(
                profiles,
                keyProfileId(profileId),
                eqProfileId,
                profile
            ).0;
            true
        //} else {
        //    false
        //}
    };

}
