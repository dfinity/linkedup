import Principal "mo:stdlib/principalId";

module {
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
    id : Principal;
    firstName : Text;
    lastName : Text;
    title : Text;
    company : Text;
    experience : Text;
    education : Text;
    imgUrl : Text;
  };
};
