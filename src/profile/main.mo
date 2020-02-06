// Make the Graph app's public methods available locally
import Graph "canister:graph";

import Database "./database";
import Types "./types";
import Utils "./utils";

type NewProfile = Types.NewProfile;
type Profile = Types.Profile;
type PrincipalId = Types.PrincipalId;

actor Profile {
  var directory : Database.Directory = Database.Directory();
  directory.seed();

  public func healthcheck () : async Bool { true };

  // Profiles

  public shared(msg) func create (profile : NewProfile) : async PrincipalId {
    let newUserId = Utils.getUserId(msg.caller);
    directory.createOne(newUserId, profile);
    newUserId
  };

  public shared(msg) func update (profile : Profile) : async () {
    if (Utils.hasAccess(Utils.getUserId(msg.caller), profile)) {
      directory.updateOne(profile.id, profile);
    };
  };

  public shared query(msg) func getOwn () : async Profile {
    Utils.getProfile(directory, Utils.getUserId(msg.caller))
  };

  public query func get (userId : PrincipalId) : async Profile {
    Utils.getProfile(directory, userId)
  };

  public query func search (term : Text) : async [Profile] {
    directory.findBy(term)
  };

  // Connections

  public shared(msg) func connect (userId : PrincipalId) : async () {
    let callerId : PrincipalId = Utils.getUserId(msg.caller);
    // Call Graph's public methods without an API
    await Graph.connect(Utils.toEntryId(callerId), Utils.toEntryId(userId));
  };

  public shared(msg) func getOwnConnections () : async [Profile] {
    let callerId : PrincipalId = Utils.getUserId(msg.caller);
    let entryIds = await Graph.getConnections(Utils.toEntryId(callerId));
    Utils.getConnectionProfiles(directory, entryIds)
  };

  public func getConnections (userId : PrincipalId) : async [Profile] {
    let entryIds = await Graph.getConnections(Utils.toEntryId(userId));
    Utils.getConnectionProfiles(directory, entryIds)
  };

  public shared(msg) func isConnected  (userId : PrincipalId) : async Bool {
    let callerId : PrincipalId = Utils.getUserId(msg.caller);
    let entryIds = await Graph.getConnections(Utils.toEntryId(callerId));
    Utils.includes(Utils.toEntryId(userId), entryIds)
  };

};
