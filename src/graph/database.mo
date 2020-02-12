import Array "mo:stdlib/array";
import HashMap "mo:stdlib/hashMap";
import Hash "mo:stdlib/hash";
import Iter "mo:stdlib/iter";
import List "mo:stdlib/list";
import Nat "mo:stdlib/nat";
import Option "mo:stdlib/option";

import Types "./types";

module {
  type Entry = Types.Entry;
  type EntryId = Types.EntryId;

  public class Entries() {

    func natEq(x : Nat32, y : Nat32) : Bool { x == y };
    func hashEntryId(x : EntryId) : Hash.Hash { Nat.toWord32(Nat.fromNat32(x)) };
    let hashMap = HashMap.HashMap<EntryId, Entry>(1, natEq, hashEntryId);

    public func addConnection(fromUser : EntryId, toUser : EntryId) {
      let entry = getEntry(fromUser);
      let updated : Entry = {
        id = entry.id;
        connections = Array.append<EntryId>(entry.connections, [toUser]);
        invitations = entry.invitations;
      };
      ignore hashMap.set(fromUser, updated);
    };

    func getEntry(entryId : EntryId) : Entry {
      let existing = hashMap.get(entryId);
      switch (existing) {
        case (?existing) { existing };
        case (null) { { id = entryId; connections = []; invitations = []; } };
      };
    };

    public func getConnections(userId : EntryId) : [EntryId] {
      let entry = getEntry(userId);
      entry.connections
    };
  };
};
