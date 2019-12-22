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
import Result "mo:stdlib/result.mo";
import Trie "mo:stdlib/trie.mo";
import Util "../common/util.mo";

actor Graph {

  type List<T> = List.List<T>;
  type Result<Ok, Err> = Result.Result<Ok, Err>;
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
   * Check if a user identifier is an element of a list.
   */
  func elem(xs : List<UserId>, y : UserId) : Bool {
    List.exists<UserId>(xs, func (x) {
      eq(x, y)
    })
  };

  /**
   * The type of a vertex.
   */
  public type Vertex = {
    connections : List<UserId>;
    invitations : List<UserId>
  };

  /**
   * The type of the vertex database.
   */
  type VertexDatabase = Trie<UserId, Vertex>;

  /**
   * Initialize the vertex database.
   */
  var vertices : VertexDatabase = Trie.empty<UserId, Vertex>();

  /**
   * Find a vertex in the vertex database.
   */
  func find(userId : UserId) : (?Vertex) {
    Trie.find<UserId, Vertex>(vertices, key(userId), eq)
  };

  /**
   * Insert a vertex into the vertex database.
   */
  func insert(userId : UserId, vertex : Vertex) {
    vertices := Trie.insert<UserId, Vertex>(
      vertices,
      key(userId),
      eq,
      vertex
    ).0
  };

  /**
   * Find the 1st-degree connections of a vertex in the vertex database.
   */
  public func connections1(userId : UserId) : async List<UserId> {
    Option.option<Vertex, List<UserId>>(find(userId), func (vertex) {
      vertex.connections
    }, List.nil<UserId>())
  };

  ///**
  // * Find the 2st-degree connections of a vertex in the vertex database.
  // */
  //public func connections2(userId : UserId) : async List<UserId> {
  //  List.foldRight<UserId, List<UserId>>(
  //    connections1(userId),
  //    List.nil<UserId>(),
  //    func (connection, accum) {
  //      List.append<UserId>(accum, connections1(userId))
  //    }
  //  )
  //};

  ///**
  // * Find the names of the 1st-degree connections of a vertex in the vertex
  // * database.
  // */
  //public func connectionsWithNames1(
  //  userId : UserId
  //) : async List<(UserId, [Word8], [Word8])> {
  //  List.foldLeft<UserId, List<(UserId, [Word8], [Word8])>>(
  //    connections1(userId),
  //    List.nil<(UserId, [Word8], [Word8])>(),
  //    func (connection, accum) {
  //      let profile = Profile.find(userId);
  //      List.push<(UserId, [Word8], [Word8])>(
  //        (connection, profile.firstName, profile.LastName),
  //        accum
  //      )
  //    }
  //  )
  //};

  ///**
  // * Find the names of the 2st-degree connections of a vertex in the vertex
  // * database.
  // */
  //public func connectionsWithNames2(
  //  userId : UserId
  //) : async List<(UserId, [Word8], [Word8])> {
  //  List.foldLeft<UserId, List<(UserId, [Word8], [Word8])>>(
  //    connections2(userId),
  //    List.nil<(UserId, [Word8], [Word8])>(),
  //    func (connection, accum) {
  //      let profile = Profile.find(userId);
  //      List.push<(UserId, [Word8], [Word8])>(
  //        (connection, profile.firstName, profile.LastName),
  //        accum
  //      )
  //    }
  //  )
  //};

  /**
   * Find the invitations of a vertex in the vertex database.
   */
  public func invitations(userId : UserId) : async (?List<UserId>) {
    Option.map<Vertex, List<UserId>>(func (vertex) {
      vertex.invitations
    }, find(userId))
  };

  /**
   * The type of an execution report.
   */
  public type ExecutionReport = {
    success : Bool;
    message : Text
  };

  /**
   * Perform a privileged operation on the vertex database.
   */
  public func run(
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
        Util.decodeWord8ArrayThen<()>(32, next, func (bytes) {
          let fromId = {
            unbox = signer
          };
          let toId = {
            unbox = bytes
          };
          switch messgeType {

            // Create a connection invitation.
            case 3 {
              switch (find(toId)) {
                case (?to) {
                  if (elem(to.connections, fromId)) {
                    #err("Connection already exists!")
                  } else if (elem(to.invitations, fromId)) {
                    #err("Connection invitation already exists!")
                  } else {
                    insert(toId, {
                      connections = to.connections;
                      invitations = List.push<UserId>(fromId, to.invitations)
                    });
                    #ok()
                  }
                };
                case _ {
                  insert(toId, {
                    connections = List.nil<UserId>();
                    invitations = List.singleton<UserId>(fromId)
                  });
                  #ok()
                }
              }
            };

            // Revoke a connection invitation.
            case 4 {
              switch (find(toId)) {
                case (?to) {
                  insert(toId, {
                    connections = to.connections;
                    invitations = List.filter<UserId>(
                      to.invitations,
                      func (invitation) {
                        not eq(invitation, fromId)
                      }
                    )
                  });
                  #ok()
                };
                case _ {
                  #err("User does not exist!")
                }
              }
            };

            // Accept or reject a connection invitation.
            case 5 {
              Util.decodeWord8Then<()>(next, func (accept) {
                Prelude.unreachable()
              })
            };

            // Revoke a connection.
            case 6 {
              switch (find(fromId), find(toId)) {
                case (?from, ?to) {
                  insert(fromId, {
                    connections = List.filter<UserId>(
                      from.connections,
                      func (connection) {
                        not eq(connection, toId)
                      }
                    );
                    invitations = from.invitations;
                  });
                  insert(toId, {
                    connections = List.filter<UserId>(
                      to.connections,
                      func (connection) {
                        not eq(connection, fromId)
                      }
                    );
                    invitations = to.invitations;
                  });
                  #ok()
                };
                case _ {
                  #err("User does not exist!")
                }
              }
            };

            // Invalid message type!
            case _ {
              #err("Invalid message type!")
            }
          }
        })
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
