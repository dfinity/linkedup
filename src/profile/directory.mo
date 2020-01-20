import Array "mo:stdlib/array.mo";
import Blob "mo:stdlib/blob.mo";
import HashMap "mo:stdlib/hashMap.mo";
import Hash "mo:stdlib/hash.mo";
import Iter "mo:stdlib/iter.mo";
import List "mo:stdlib/list.mo";
import Nat "mo:stdlib/nat.mo";
import Option "mo:stdlib/option.mo";

import Types "./types.mo";

module {
  type NewProfile = Types.NewProfile;
  type Profile = Types.Profile;
  type PrincipalId = Types.PrincipalId;

  public class Directory () {
    func passthrough (hash : PrincipalId) : PrincipalId { hash };
    let hashMap = HashMap.HashMap<PrincipalId, Profile>(1, Hash.Hash.hashEq, passthrough);
    var seeded = false;

    public func createOne (userId : PrincipalId, _profile : NewProfile) : () {
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

    public func updateOne (userId : PrincipalId, profile : Profile) : () {
      ignore hashMap.set(userId, profile);
    };

    public func findOne (userId : PrincipalId) : ?Profile {
      hashMap.get(userId)
    };

    public func findMany (userIds : [PrincipalId]) : [Profile] {
      func getProfile (userId : PrincipalId) : Profile {
        Option.unwrap<Profile>(hashMap.get(userId))
      };
      Array.map<PrincipalId, Profile>(getProfile, userIds)
    };

    public func findBy (term : Text) : [Profile] {
      // @TODO: Use HashMap.mapFilter
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

    public func seed () : () {
      if (seeded) { return; };

      let table : [[Text]] = [
        ["Dominic", "Williams", "Founder & Chief Scientist", "DFINITY", "Working to reinvent the Internet as a shared supercomputer"],
        ["Diego", "Prats", "Director de Producto", "DFINITY", "Building a public computing platform to rival AWS, Azure, and Google Cloud."],
        ["Stanley", "Jones", "Engineering Manager", "DFINITY", "Making it fun and easy to build apps for the Internet Computer"],
        ["Ryan", "Newman", "Director of Talent", "DFINITY", "The children are our future. Teach them well and let them lead the way."],
        ["Ryan", "Stout", "Software Engineering", "DFINITY", "Ryan Newman ate my lunch again"],
        ["Olive", "Menjo", "Senior Dog", "DFINITY", "Dog stuff"]
      ];

      let profiles : [Profile] = Array.mapWithIndex<[Text], Profile>(makeProfile, table);
      for (profile in profiles.vals()) { ignore hashMap.set(profile.id, profile); };

      seeded := true;
    };

    func makeProfile (row : [Text], index : Nat) : Profile {
        let profile : Profile = {
          id = Nat.toWord32(1000 + index);
          firstName = row[0];
          lastName = row[1];
          title = row[2];
          company = row[3];
          experience = row[4];
        };
        profile
    };
  };
};
