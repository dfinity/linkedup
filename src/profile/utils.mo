import Array "mo:stdlib/array";
import Principal "mo:stdlib/principalId";
import Nat "mo:stdlib/nat";
import Option "mo:stdlib/option";

import Database "./database";
import Types "./types";

module {
  type NewProfile = Types.NewProfile;
  type Profile = Types.Profile;
  type PrincipalId = Types.PrincipalId;

  // Profiles
  public func getProfile(directory : Database.Directory, userId : PrincipalId) : Profile {
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

  public func getConnectionProfiles(directory : Database.Directory, entryIds : [Nat32]) : [Profile] {
    let profileIds = Array.map<Nat32, PrincipalId>(fromEntryId, entryIds);
    directory.findMany(profileIds)
  };

  public func toEntryId(userId : PrincipalId) : Nat32 { Nat.toNat32(Nat.fromWord32(userId)) };
  public func fromEntryId(entryId : Nat32) : PrincipalId { Nat.toWord32(Nat.fromNat32(entryId)) };

  public func includes(x : Nat32, xs : [Nat32]) : Bool {
    func isX(y : Nat32) : Bool { x == y };
    switch (Array.find<Nat32>(isX, xs)) {
      case (null) { false };
      case (_) { true };
    };
  };

  // Authorization

  let adminIds : [PrincipalId] = [];

  public func getUserId(caller : Principal) : PrincipalId { Principal.hash(caller) };

  public func isAdmin(userId : PrincipalId) : Bool {
    func identity(x : PrincipalId) : Bool { x == userId };
    Option.isSome<PrincipalId>(Array.find<PrincipalId>(identity, adminIds))
  };

  public func hasAccess(userId : PrincipalId, profile : Profile) : Bool {
    userId == profile.id or isAdmin(userId)
  };
};
