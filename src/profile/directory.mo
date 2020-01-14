import Array "mo:stdlib/array.mo";
import HashMap "mo:stdlib/hashMap.mo";
import Hash "mo:stdlib/hash.mo";
import Iter "mo:stdlib/iter.mo";
import List "mo:stdlib/list.mo";

import Types "./types.mo";

module {
  type Profile = Types.Profile;
  type PrincipalId = Types.PrincipalId;

  public class Directory () {
    func passthrough (hash : PrincipalId) : PrincipalId { hash };
    let hashMap = HashMap.HashMap<PrincipalId, Profile>(1, Hash.Hash.hashEq, passthrough);

    public func get (userId : PrincipalId) : ?Profile {
      hashMap.get(userId)
    };

    public func set (userId : PrincipalId, _profile : Profile) : () {
      let profile : Profile = {
        id = userId;
        firstName = _profile.firstName;
        lastName = _profile.lastName;
        title = _profile.title;
        company = _profile.company;
        experience = _profile.experience;
      };
      ignore hashMap.set(userId, profile);
    };

    public func search (term : Text) : [Profile] {
      var profiles : [Profile] = [];
      for ((id, profile) in hashMap.iter()) {
        let fullName = profile.firstName # " " # profile.lastName;
        if (includesText(fullName, term)) {
          profiles := Array.append<Profile>(profiles, [profile]);
        };
      };
      profiles
    };

    func includesText (string : Text, term : Text) : Bool {
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
