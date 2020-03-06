import Hash "mo:stdlib/hash";

module {
  public type PrincipalId = Hash.Hash;

  public type NewProfile = {
    firstName : Text;
    lastName : Text;
    title : Text;
    company : Text;
    experience : Text;
    education : Text;
    imgUrl : Text;
  };

  public type Profile = {
    id : PrincipalId;
    firstName : Text;
    lastName : Text;
    title : Text;
    company : Text;
    experience : Text;
    education : Text;
    imgUrl : Text;
  };
};
