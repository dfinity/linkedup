/**
 * File       : main.mo
 * Copyright  : 2019 Enzo Haussecker
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Enzo Haussecker <enzo@dfinity.org>
 * Stability  : Experimental
 */

import Entries "./entries.mo";
import Types "./types.mo";

type Entry = Types.Entry;
type EntryId = Types.EntryId;

actor Graph {
  var entries : Entries.Entries = Entries.Entries();

  public func healthcheck () : async Bool { true };

  // Connections

  public func connect (caller : Nat32, userId : Nat32) : async () {
    entries.addConnection(caller, userId);
  };

  public func getConnections (userId : EntryId) : async [EntryId] {
    entries.getConnections(userId)
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
};
