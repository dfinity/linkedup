// Make the Graph app's public methods available locally
import Graph "canister:graph";

import Database "./database.mo";
import Types "./types.mo";
import Utils "./utils.mo";

type NewProfile = Types.NewProfile;
type Profile = Types.Profile;
type PrincipalId = Types.PrincipalId;

actor Profile {
  var directory : Database.Directory = Database.Directory();
  directory.seed();

  public func healthcheck () : async Bool { true };

  // Profiles

  public shared { caller } func create (profile : NewProfile) : async PrincipalId {
    let newUserId = Utils.getUserId(caller);
    directory.createOne(newUserId, profile);
    newUserId
  };

  public shared { caller } func update (profile : Profile) : async () {
    if (Utils.hasAccess(Utils.getUserId(caller), profile)) {
      directory.updateOne(profile.id, profile);
    };
  };

  public shared query { caller } func getOwn () : async Profile {
    Utils.getProfile(directory, Utils.getUserId(caller))
  };

  public query func get (userId : PrincipalId) : async Profile {
    Utils.getProfile(directory, userId)
  };

  public query func search (term : Text) : async [Profile] {
    directory.findBy(term)
  };

  // Connections

  public shared { caller } func connect (userId : PrincipalId) : async () {
    let callerId : PrincipalId = Utils.getUserId(caller);
    // Call Graph's public methods without an API
    await Graph.connect(Utils.toEntryId(callerId), Utils.toEntryId(userId));
  };

  public shared { caller } func getOwnConnections () : async [Profile] {
    let callerId : PrincipalId = Utils.getUserId(caller);
    let entryIds = await Graph.getConnections(Utils.toEntryId(callerId));
    Utils.getConnectionProfiles(directory, entryIds)
  };

  public func getConnections (userId : PrincipalId) : async [Profile] {
    let entryIds = await Graph.getConnections(Utils.toEntryId(userId));
    Utils.getConnectionProfiles(directory, entryIds)
  };

  public shared { caller } func isConnected  (userId : PrincipalId) : async Bool {
    let callerId : PrincipalId = Utils.getUserId(caller);
    let entryIds = await Graph.getConnections(Utils.toEntryId(callerId));
    Utils.includes(Utils.toEntryId(userId), entryIds)
  };

};
