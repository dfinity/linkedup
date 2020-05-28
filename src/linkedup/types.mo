import Principal "mo:stdlib/principalId";

module {
  public type UserId = Principal;
  public type ProfileId = Nat8;

  public type NewProfile = {
    firstName: Text;
    lastName: Text;
    title: Text;
    company: Text;
    experience: Text;
    education: Text;
    imgUrl: Text;
  };

  public type Profile = {
    id: ProfileId;
    userId: UserId;
    firstName: Text;
    lastName: Text;
    title: Text;
    company: Text;
    experience: Text;
    education: Text;
    imgUrl: Text;
    connections: [ProfileId];
  };
};
