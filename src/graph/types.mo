import Hash "mo:stdlib/hash.mo";

module {
  public type EntryId = Nat32;

  public type Entry = {
    id : EntryId;
    connections : [EntryId];
    invitations : [EntryId];
  };
};
