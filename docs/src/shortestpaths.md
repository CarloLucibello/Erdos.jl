# Shortest-Path Algorithms

## General properties of shortest path algorithms

* The distance from a vertex to itself is always `0`.
* The distance between two vertices with no connecting edge is always `Inf`.

<!---
TODO separate in paragraphs?
TODO remove mincut

# Shortest-Path Algorithms
```@autodocs
Modules = [Erdos]
Pages   = ["shortestpaths/shortestpaths.jl",
            "shortestpaths/astar.jl",
            "shortestpaths/bellman-ford.jl",
            "shortestpaths/dijkstra.jl",
            "shortestpaths/floyd-warshall.jl"
]
Private = false
```
--->
```@docs
a_star
dijkstra_shortest_paths
bellman_ford_shortest_paths
floyd_warshall_shortest_paths
```

## Path discovery / enumeration

```@docs
enumerate_paths
```

For Floyd-Warshall path states, please note that the output is a bit different,
since this algorithm calculates all shortest paths for all pairs of vertices:
`enumerate_paths(state)` will return a vector (indexed by source vertex) of
vectors (indexed by destination vertex) of paths. `enumerate_paths(state, v)`
will return a vector (indexed by destination vertex) of paths from source `v`
to all other vertices. In addition, `enumerate_paths(state, v, d)` will return
a vector representing the path from vertex `v` to vertex `d`.

## Path States

The `floyd_warshall_shortest_paths`, `bellman_ford_shortest_paths`,
`dijkstra_shortest_paths`, and `dijkstra_predecessor_and_distance` functions
return a state that contains various information about the graph learned during
traversal. The three state types have the following common information,
accessible via the type:

`.dists`
Holds a vector of distances computed, indexed by source vertex.

`.parents`
Holds a vector of parents of each source vertex. The parent of a source vertex
is always `0`.

In addition, the `dijkstra_predecessor_and_distance` function stores the
following information:

`.predecessors`
Holds a vector, indexed by vertex, of all the predecessors discovered during
shortest-path calculations. This keeps track of all parents when there are
multiple shortest paths available from the source.

`.pathcounts`
Holds a vector, indexed by vertex, of the path counts discovered during
traversal. This equals the length of each subvector in the `.predecessors`
output above.
