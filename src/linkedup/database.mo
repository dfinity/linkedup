import Array "mo:stdlib/array";
import HashMap "mo:stdlib/hashMap";
import Iter "mo:stdlib/iter";
import Option "mo:stdlib/option";
import Principal "mo:stdlib/principalId";
import Types "./types";

module {
  type NewProfile = Types.NewProfile;
  type Profile = Types.Profile;

  public class Directory() {
    func isEq(x : Principal, y : Principal) : Bool { x == y };
    let hashMap = HashMap.HashMap<Principal, Profile>(1, isEq, Principal.hash);

    public func createOne(userId : Principal, _profile : NewProfile) {
      ignore hashMap.set(userId, makeProfile(userId, _profile));
    };

    public func updateOne(userId : Principal, profile : Profile) {
      ignore hashMap.set(userId, profile);
    };

    public func findOne(userId : Principal) : ?Profile {
      hashMap.get(userId)
    };

    public func findMany(userIds : [Principal]) : [Profile] {
      func getProfile(userId : Principal) : Profile {
        Option.unwrap<Profile>(hashMap.get(userId))
      };
      Array.map<Principal, Profile>(getProfile, userIds)
    };

    public func findBy(term : Text) : [Profile] {
      var profiles : [Profile] = [];
      for ((id, profile) in hashMap.iter()) {
        let fullName = profile.firstName # " " # profile.lastName;
        if (includesText(fullName, term)) {
          profiles := Array.append<Profile>(profiles, [profile]);
        };
      };
      profiles
    };

    // Helpers

    func makeProfile(userId : Principal, profile : NewProfile) : Profile {
      {
        id = userId;
        firstName = profile.firstName;
        lastName = profile.lastName;
        title = profile.title;
        company = profile.company;
        experience = profile.experience;
        education = profile.education;
        imgUrl = profile.imgUrl;
      }
    };

    func includesText(string : Text, term : Text) : Bool {
      let stringArray = Iter.toArray<Char>(string.chars());
      let termArray = Iter.toArray<Char>(term.chars());

      var i = 0;
      var j = 0;

      while (i < stringArray.len() and j < termArray.len()) {
        if (stringArray[i] == termArray[j]) {
          i += 1;
          j += 1;
          if (j == termArray.len()) { return true; }
        } else {
          i += 1;
          j := 0;
        }
      };
      false
    };
  };
};
