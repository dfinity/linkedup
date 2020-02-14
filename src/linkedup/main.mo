import Principal "mo:stdlib/principalId";
import Connectd "canister:connectd";
import Database "./database";
import Types "./types";
import Utils "./utils";

type NewProfile = Types.NewProfile;
type Profile = Types.Profile;

actor Profile {
  var directory : Database.Directory = Database.Directory();

  public func healthcheck () : async Bool { true };

  // Profiles

  public shared(msg) func create (profile : NewProfile) : async Principal {
    directory.createOne(msg.caller, profile);
    msg.caller
  };

  public shared(msg) func update (profile : Profile) : async () {
    if (Utils.hasAccess(msg.caller, profile)) {
      directory.updateOne(profile.id, profile);
    };
  };

  public shared query(msg) func getOwn () : async Profile {
    Utils.getProfile(directory, msg.caller)
  };

  public query func get (userId : Principal) : async Profile {
    Utils.getProfile(directory, userId)
  };

  public query func search (term : Text) : async [Profile] {
    directory.findBy(term)
  };

  // Connections

  public shared(msg) func connect (userId : Principal) : async () {
    await Connectd.connect(msg.caller, userId);
  };

  public shared(msg) func getOwnConnections () : async [Profile] {
    let entryIds = await Connectd.getConnections(msg.caller);
    Utils.getConnectionProfiles(directory, entryIds)
  };

  public func getConnections (userId : Principal) : async [Profile] {
    let entryIds = await Connectd.getConnections(userId);
    Utils.getConnectionProfiles(directory, entryIds)
  };

  public shared(msg) func isConnected  (userId : Principal) : async Bool {
    await Connectd.hasConnection(msg.caller, userId)
  };

};
