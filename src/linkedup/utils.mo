import Array "mo:stdlib/array";
import Principal "mo:stdlib/principalId";
import Nat "mo:stdlib/nat";
import Option "mo:stdlib/option";

import Database "./database";
import Types "./types";

module {
  type NewProfile = Types.NewProfile;
  type Profile = Types.Profile;

  // Profiles
  public func getProfile(directory : Database.Directory, userId : Principal) : Profile {
    let existing = directory.findOne(userId);
    switch (existing) {
      case (?existing) { existing };
      case (null) {
        {
          id = userId;
          firstName = "";
          lastName = "";
          title = "";
          company = "";
          experience = "";
          education = "";
          imgUrl = "";
        }
      };
    };
  };

  // Connections

  public func getConnectionProfiles(directory : Database.Directory, entryIds : [Principal]) : [Profile] {
    directory.findMany(entryIds)
  };


  public func includes(x : Principal, xs : [Principal]) : Bool {
    func isX(y : Principal) : Bool { x == y };
    switch (Array.find<Principal>(isX, xs)) {
      case (null) { false };
      case (_) { true };
    };
  };

  // Authorization

  let adminIds : [Principal] = [];

  public func isAdmin(userId : Principal) : Bool {
    func identity(x : Principal) : Bool { x == userId };
    Option.isSome<Principal>(Array.find<Principal>(identity, adminIds))
  };

  public func hasAccess(userId : Principal, profile : Profile) : Bool {
    userId == profile.id or isAdmin(userId)
  };
};
