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
  type Entry = Types.Entry;
  type PrincipalId = Types.PrincipalId;

  public class Entries () {

    func passthrough (hash : PrincipalId) : PrincipalId { hash };
    let hashMap = HashMap.HashMap<PrincipalId, Entry>(1, Hash.Hash.hashEq, passthrough);

    public func addConnection (fromUser : PrincipalId, toUser : PrincipalId) : () {
      var existing = Option.unwrap<Entry>(hashMap.get(fromUser));
      let updated : Entry = {
        id = existing.id;
        connections = Array.append<PrincipalId>(existing.connections, [toUser]);
        invitations = existing.invitations;
      };
      ignore hashMap.set(fromUser, updated);
    };

    public func getConnections (userId : PrincipalId) : [PrincipalId] {
      let entry = Option.unwrap<Entry>(hashMap.get(userId));
      entry.connections
    };
  };
};
