// Make the Connectd app's public methods available locally
import Connectd "canister:connectd";
import Database "./database";
import Types "./types";
import Utils "./utils";

actor LinkedUp {

  type NewProfile = Types.NewProfile;
  type Profile = Types.Profile;
  type UserId = Types.UserId;

  var directory: Database.Directory = Database.Directory();

  // Healthcheck

  public func healthcheck(): async Bool { true };

  // Profiles

  public shared(msg) func create(profile: NewProfile): async () {
    directory.createOne(msg.caller, profile);
  };

  public shared(msg) func update(profile: Profile): async () {
    if(Utils.hasAccess(msg.caller, profile)) {
      directory.updateOne(profile.id, profile);
    };
  };

  public query func get(userId: UserId): async Profile {
    Utils.getProfile(directory, userId)
  };

  public query func search(term: Text): async [Profile] {
    directory.findBy(term)
  };

  // Connections

  public shared(msg) func connect(userId: UserId): async () {
    // Call Connectd's public methods without an API
    await Connectd.connect(msg.caller, userId);
  };

  public func getConnections(userId: UserId): async [Profile] {
    let userIds = await Connectd.getConnections(userId);
    directory.findMany(userIds)
  };

  public shared(msg) func isConnected(userId: UserId): async Bool {
    let userIds = await Connectd.getConnections(msg.caller);
    Utils.includes(userId, userIds)
  };

  // User Auth

  public shared query(msg) func getOwnId(): async UserId { msg.caller }

};
