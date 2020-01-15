/**
 * File       : main.mo
 * Copyright  : 2019 Enzo Haussecker
 * License    : Apache 2.0 with LLVM Exception
 * Maintainer : Enzo Haussecker <enzo@dfinity.org>
 * Stability  : Experimental
 */

import Blob "mo:stdlib/blob.mo";
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

  public query func get (userId : PrincipalId) : async ?Profile {
    directory.findOne(userId)
  };

  public query func search (term : Text) : async [Profile] {
    directory.findBy(term)
  };

  // Connections

  // public shared { caller } func connect (userId : PrincipalId) : async () {
  //   await Graph.connect(Blob.hash(caller), userId);
  // };

  // public query func getConnections (userId : PrincipalId) : async [Profile] {
  //   let profileIds = await Graph.getConnections(userId);
  //   directory.findMany(profileIds)
  // };
};
