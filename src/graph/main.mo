import Database "./database";
import Types "./types";

type Entry = Types.Entry;
type EntryId = Types.EntryId;

actor Graph {
  var entries : Database.Entries = Database.Entries();

  public func healthcheck() : async Bool { true };

  // Connections

  // "public" makes this method available as Graph.connect
  public func connect(caller : Nat32, userId : Nat32) : async () {
    entries.addConnection(caller, userId);
  };

  public func getConnections(userId : EntryId) : async [EntryId] {
    entries.getConnections(userId)
  };

};
