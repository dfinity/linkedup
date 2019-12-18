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
import List "mo:stdlib/list.mo";
import Option "mo:stdlib/option.mo";
import Prelude "mo:stdlib/prelude.mo";
import Trie "mo:stdlib/trie.mo";
import Util "../util/util.mo"

type Trie<Key, Value> = Trie.Trie<Key, Value>;
type List<T> = List.List<T>;

actor Graph {

    /**
     * The type of a vertex identifier.
     */
    public type VertexId = {
        unbox : [Word8];
    };

    /**
     * Test vertex identifiers for equality.
     */
    func eq(x : VertexId, y : VertexId) : Bool {
        return Array.equals<Word8>(x.unbox, y.unbox, func (xi, yi) {xi == yi});
    };

    /**
     * Create a trie key from a vertex identifier.
     */
    func key(x : VertexId) : Trie.Key<VertexId> {
        func convert(bytes : [Word8]) : [Word32] {
            return Array.map<Word8, Word32>(Util.word8ToWord32, bytes);
        };
        return {
            key = x;
            hash = Hash.BitVec.hashWord8s(convert(x.unbox));
        };
    };

    /**
     * The type of a vertex.
     */
    public type Vertex = {
        connections : List<VertexId>;
        invitations : List<VertexId>;
    };

    /**
     * The type of the vertex database.
     */
    type VertexDatabase = Trie<VertexId, Vertex>;

    /**
     * Initialize the vertex database.
     */
    var vertices : VertexDatabase = Trie.empty<VertexId, Vertex>();

    /**
     * Find a vertex in the vertex database.
     */
    func find(vertexId : VertexId) : (?Vertex) {
        return Trie.find<VertexId, Vertex>(vertices, key(vertexId), eq);
    };

    /**
     * 
     */
    public func connections(vertexId : VertexId) : async (?List<VertexId>) {
        return Option.map<Vertex, List<VertexId>>(func (vertex) {
            return vertex.connections
        }, find(vertexId));
    };

    /**
     * 
     */
    public func invitations(vertexId : VertexId) : async (?List<VertexId>) {
        return Option.map<Vertex, List<VertexId>>(func (vertex) {
            return vertex.invitations
        }, find(vertexId));
    };

    /**
     * Perform a privileged operation on the vertex database.
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

            // TODO:
            // - Create a connection invitation.
            // - Revoke a connection invitation.
            // - Respond to a connection invitation.
            // - Revoke a connection.

            // Invalid message type.
            case _ {
                Prelude.printLn("invalid message type");
                return false;
            };

        };
    };

}
