// Make the Connectd app's public methods available locally
// import Connectd "canister:connectd";
import Database "./database";
import Types "./types";
import Utils "./utils";

type NewProfile = Types.NewProfile;
type Profile = Types.Profile;
type UserId = Types.UserId;
type ProfileId = Types.ProfileId;

actor LinkedUp {
  var profiles = Database.Profiles();

  // Healthcheck

  public func healthcheck() : async Bool { true };

  // Profiles

  public shared { caller } func create(newProfile : NewProfile) : async Profile {
    profiles.create(caller, newProfile)
  };

  public shared { caller } func update(updatedProfile : Profile) : async Profile {
    let profile = profiles.findById(updatedProfile.id);
    if (Utils.hasAccess(caller, profile)) { profiles.update(updatedProfile); };
    updatedProfile
  };

  public query func get(id : ProfileId) : async Profile {
    profiles.findById(id)
  };

  public query func search(term : Text) : async [Profile] {
    profiles.findManyByText(term)
  };

  // Connections

  public shared { caller } func connect(fromId : ProfileId, toId : ProfileId) : async Profile {
    let profile = profiles.findById(fromId);
    if (Utils.hasAccess(caller, profile)) {
      let updatedProfile = Utils.addConnection(profile, toId);
      profiles.update(updatedProfile);
      return updatedProfile;
    };
    profile

    // Call Connectd's public methods without an API
    // await Connectd.connect(msg.caller, userId);
  };

  public query func getConnections(id : ProfileId) : async [Profile] {
    // let userIds = await Connectd.getConnections(userId);
    profiles.findManyById(profiles.findById(id).connections)
  };

  // User Auth

  public shared query { caller } func getOwnId() : async ProfileId {
    profiles.findByUserId(caller).id
  };

};
