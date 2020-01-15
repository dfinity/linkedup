/**
 * File       : main.mo
 * Copyright  : 2019 Enzo Haussecker
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Enzo Haussecker <enzo@dfinity.org>
 * Stability  : Experimental
 */

import Array "mo:stdlib/array.mo";
import Blob "mo:stdlib/blob.mo";
import Nat "mo:stdlib/nat.mo";
import Option "mo:stdlib/option.mo";

import Graph "canister:graph";

import Directory "./directory.mo";
import Types "./types.mo";

type Profile = Types.Profile;
type PrincipalId = Types.PrincipalId;

actor Profile {
  var directory : Directory.Directory = Directory.Directory();
  directory.seed();

  public func healthcheck () : async Bool {
    let isGraphAlive : Bool = await Graph.healthcheck();
    true and isGraphAlive
  };

  // Profiles

  public shared { caller } func set (profile : Profile) : async PrincipalId {
    let userId : PrincipalId = Blob.hash(caller);
    directory.updateOne(userId, profile);
    userId
  };

  public shared { caller } func setMany (profiles : [Profile]) : async () {
    if (not isAdmin(Blob.hash(caller))) { return; };
    for (profile in profiles.vals()) { directory.updateOne(profile.id, profile); };
  };

  public query func get (userId : PrincipalId) : async ?Profile {
    directory.findOne(userId)
  };

  public query func search (term : Text) : async [Profile] {
    directory.findBy(term)
  };

  // Connections

  public shared { caller } func connect (userId : PrincipalId) : async () {
    await Graph.connect(toEntryId(Blob.hash(caller)), toEntryId(userId));
  };

  public query func getConnections (userId : PrincipalId) : async [Profile] {
    let entryIds = await Graph.getConnections(toEntryId(userId));
    let profileIds = Array.map<Nat32, PrincipalId>(fromEntryId, entryIds);
    directory.findMany(profileIds)
  };

  func toEntryId (userId : PrincipalId) : Nat32 { Nat.toNat32(Nat.fromWord32(userId)) };
  func fromEntryId (entryId : Nat32) : PrincipalId { Nat.toWord32(Nat.fromNat32(entryId)) };

  // Authorization

  let adminIds : [PrincipalId] = [];

  func isAdmin (userId : PrincipalId) : Bool {
    func identity (x : PrincipalId) : Bool { x == userId };
    Option.isSome<PrincipalId>(Array.find<PrincipalId>(identity, adminIds))
  };
};
