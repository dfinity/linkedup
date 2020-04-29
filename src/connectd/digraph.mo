import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Types "./types";

module {
  type Vertex = Types.Vertex;

  public class Digraph() {

    var vertexList: [Vertex] = [];
    var edgeList: [(Vertex, Vertex)] = [];

    public func addVertex(vertex: Vertex) {
      vertexList := Array.append<Vertex>(vertexList, [vertex]);
    };

    public func addEdge(fromVertex: Vertex, toVertex: Vertex) {
      edgeList := Array.append<(Vertex, Vertex)>(edgeList, [(fromVertex, toVertex)]);
    };

    public func getAdjacent(vertex: Vertex): [Vertex] {
      var adjacencyList: [Vertex] = [];
      for ((fromVertex, toVertex) in Iter.fromArray<(Vertex, Vertex)>(edgeList)) {
        if (fromVertex == vertex) {
          adjacencyList := Array.append<Vertex>(adjacencyList, [toVertex]);
        };
      };
      adjacencyList
    };

  };
};
