import Hash "mo:stdlib/hash.mo";

module {
  public type PrincipalId = Hash.Hash;

  public type Entry = {
    id : PrincipalId;
    connections : [PrincipalId];
    invitations : [PrincipalId];
  };
};
