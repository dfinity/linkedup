import Array "mo:stdlib/array";
import Iter "mo:stdlib/iter";
import Option "mo:stdlib/option";
import Prim "mo:prim";
import Types "./types";

module {
  type NewProfile = Types.NewProfile;
  type Profile = Types.Profile;
  type UserId = Types.UserId;
  type ProfileId = Types.ProfileId;

  // Profile Utilities

  public func makeProfile(nextId : ProfileId, creatorId : UserId, newProfile : NewProfile) : Profile {
    {
      id = nextId;
      userId = creatorId;
      firstName = newProfile.firstName;
      lastName = newProfile.lastName;
      title = newProfile.title;
      company = newProfile.company;
      experience = newProfile.experience;
      education = newProfile.education;
      imgUrl = newProfile.imgUrl;
      connections = [nextId];
    }
  };

  public func addConnection(profile : Profile, connection : ProfileId) : Profile {
    {
      id = profile.id;
      userId = profile.userId;
      firstName = profile.firstName;
      lastName = profile.lastName;
      title = profile.title;
      company = profile.company;
      experience = profile.experience;
      education = profile.education;
      imgUrl = profile.imgUrl;
      connections = Array.append(profile.connections, [connection]);
    }
  };

  // Nat8 Utilities

  func identityProfileId(x : ProfileId) : ProfileId -> Bool {
    func (y : ProfileId) : Bool { x == y }
  };

  public func includesProfileId(x : ProfileId, xs : [ProfileId]) : Bool {
    Option.isSome(Array.find<ProfileId>(identityProfileId(x), xs))
  };

  // Principal Utilities

  func identityPrincipal(x : Principal) : Principal -> Bool {
    func (y : Principal) : Bool { x == y }
  };

  func includesPrincipal(x : Principal, xs : [Principal]) : Bool {
    Option.isSome(Array.find<Principal>(identityPrincipal(x), xs))
  };

  // Text Utilities

  public func includesText(term : Text, string : Text) : Bool {
    let stringArray = Iter.toArray<Char>(string.chars());
    let termArray = Iter.toArray<Char>(term.chars());

    var i = 0;
    var j = 0;

    while (i < stringArray.len() and j < termArray.len()) {
      if (toUpper(stringArray[i]) == toUpper(termArray[j])) {
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

  public func toUpper(char: Char): Char {
    var charCode = Prim.charToWord32(char);
    if (charCode >= Prim.charToWord32('a') and charCode <= Prim.charToWord32('z')) {
      charCode -= 32;
    };
    Prim.word32ToChar(charCode)
  };

  // Authorization Utilities

  let adminIds: [UserId] = [];

  public func isAdmin(userId : UserId) : Bool {
    includesPrincipal(userId, adminIds)
  };

  public func hasAccess(userId : UserId, profile:  Profile) : Bool {
    userId == profile.userId or isAdmin(userId)
  };
};
