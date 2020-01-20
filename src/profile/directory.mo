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
        education = _profile.education;
        imgUrl = _profile.imgUrl;
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
        [
          "Dominic",
          "Williams",
          "Founder & Chief Scientist",
          "DFINITY",
          "**President & Chief Scientist**, DFINITY  \nJan 2015 – Present  \nPalo Alto, CA\n\n**President & CTO**, String Labs, Inc  \nJun 2015 – Feb 2018  \nPalo Alto, CA",
          "**King's College London**  \nBA, Computer Science",
          "https://media-exp1.licdn.com/dms/image/C5603AQHdxGV6zMbg-A/profile-displayphoto-shrink_800_800/0?e=1585180800&v=beta&t=Tnsg560fWry_85AVz6MSkeUqOisiSi0e47Hl5T0Yzxk"
        ],
        [
          "Diego",
          "Prats",
          "Director de Producto",
          "DFINITY",
          "**Director of Product**, DFINITY  \nMay 2019 – Present  \nPalo Alto, CA\n\n**VP Product Engineering**, Overnight  \nFeb 2016 – Aug 2018  \nLos Angeles, CA",
          "**Harvard University**  \nBA, Economics",
          "https://media-exp1.licdn.com/dms/image/C5603AQEsCX2F2XWSAA/profile-displayphoto-shrink_800_800/0?e=1585180800&v=beta&t=fyvnlBegGsbZSiZcWarxNTBRimRk3vfVTHWb8MH-HLU"
        ],
        [
          "Jan",
          "Camenisch",
          "VP of Research",
          "DFINITY",
          "**VP of Research**, DFINITY  \nSep 2018 – Present  \nZurich, CH\n\n**Principal Research Staff Member**, IBM Research  \nJul 1999 – Aug 2018  \nZurich, CH",
          "**ETH Zurich**  \nPhD, Computer Science / Cryptography",
          "https://media-exp1.licdn.com/dms/image/C5603AQFQTQN-Vnp7Lw/profile-displayphoto-shrink_800_800/0?e=1585180800&v=beta&t=_riz0HNQ0NlhTeg3iVcoHjo9oeTM87CrmqTj3ASv518"
        ],
        [
          "Barack",
          "Obama",
          "President (Retired)",
          "United States of America",
          "**President**, USA  \nJan 2009 – Jan 2017  \nWashington, DC",
          "**Harvard University**  \nJD, Law",
          "https://media-exp1.licdn.com/dms/image/C4E03AQF2C6iUecWOnQ/profile-displayphoto-shrink_800_800/0?e=1585180800&v=beta&t=HlFVhKOrVV5QK8AMZb_IDNPSi8oExM9lNIqAoTQ5HKo"
        ]
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
          education = row[5];
          imgUrl = row[6];
        };
        profile
    };
  };
};
