import Principal "mo:base/Principal";

module {
  public type UserId = Principal;

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
    id: UserId;
    firstName: Text;
    lastName: Text;
    title: Text;
    company: Text;
    experience: Text;
    education: Text;
    imgUrl: Text;
  };
};
