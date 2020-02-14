import Principal "mo:stdlib/principalId";
import Digraph "./digraph";

actor Connectd {
  var graph : Digraph.Digraph = Digraph.Digraph();

  public func healthcheck() : async Bool { true };

  public func connect(userA : Principal, userB : Principal) : async () {
    graph.addEdge(userA, userB);
  };

  public func getConnections(user : Principal) : async [Principal] {
    graph.getAdjacent(user)
  };
};
