import Array "mo:stdlib/array";
import HashMap "mo:stdlib/hashMap";
import Option "mo:stdlib/option";
import Principal "mo:stdlib/principalId";
import Types "./types";
import Utils "./utils";

module {
  type NewProfile = Types.NewProfile;
  type Profile = Types.Profile;
  type UserId = Types.UserId;
  type ProfileId = Types.ProfileId;

  public class Profiles() {
    // The "database" is just an array
    var profiles : [Profile] = [];
    var nextId : ProfileId = 1;

    public func create(creatorId : UserId, newProfile : NewProfile) : Profile {
      let profile = Utils.makeProfile(nextId, creatorId, newProfile);
      profiles := Array.append(profiles, [profile]);
      nextId += 1;
      profile
    };

    public func update(updated : Profile) {
      profiles := Array.map(func (profile : Profile) : Profile {
        if (profile.id == updated.id) { return updated; };
        profile
      }, profiles);
    };

    public func findById(id : ProfileId) : Profile {
      Option.unwrap(Array.find(func (profile : Profile) : Bool {
        profile.id == id
      }, profiles))
    };

    public func findByUserId(userId : UserId) : Profile {
      Option.unwrap(Array.find(func (profile : Profile) : Bool {
        profile.userId == userId
      }, profiles))
    };

    public func findManyById(ids: [ProfileId]): [Profile] {
      Array.filter(func (profile : Profile) : Bool {
        Utils.includesProfileId(profile.id, ids)
      }, profiles)
    };

    public func findManyByText(term : Text) : [Profile] {
      Array.filter(func (profile : Profile) : Bool {
        let fullName = profile.firstName # profile.lastName;
        Utils.includesText(term, fullName)
      }, profiles)
    };
  };
};
