import Digraph "./digraph";
import Types "./types";

actor Connectd {
  type Vertex = Types.Vertex;

  var graph: Digraph.Digraph = Digraph.Digraph();

  public func healthcheck(): async Bool { true };

  public func connect(userA: Vertex, userB: Vertex): async () {
    graph.addEdge(userA, userB);
  };

  public func getConnections(user: Vertex): async [Vertex] {
    graph.getAdjacent(user)
  };

};
