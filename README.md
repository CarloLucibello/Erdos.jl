# Erdos

[![Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://CarloLucibello.github.io/Erdos.jl/dev)
![CI](https://github.com/CarloLucibello/Erdos.jl/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/CarloLucibello/Erdos.jl/branch/master/graph/badge.svg?token=EWNYPD7ASX)](https://codecov.io/gh/CarloLucibello/Erdos.jl)

A graph library entirely written in Julia. Install it with

```julia
]add Erdos
```

*Erdos* implements some graph types a large number of algorithms to work with them.
Moreover edge and vertex properties can be internally stored in some of the graph types (we call them networks). These features can also be exported to most common graph formats.
Custom graph types can be defined inheriting from *Erdos*' abstract types.

## Usage Example

```julia
julia> using Erdos

julia> g = Network(10, 20) # create erdos-renyi random network

julia> add_edge!(g, 1, 2); # add edge (1, 2) if it doesn't exists

julia> eprop!(g, "w", e -> rand()) # add edge property named "w"
Network(10, 20) with [] graph, [] vertex, ["w"] edge properties

julia> vprop!(g, "x", v -> [1,1]) # add vertex property named "x"
Network(10, 20) with [] graph, ["x"] vertex, ["w"] edge properties

julia> eprop(g, 1, 2, "w")
0.8959648919973169

julia> writenetwork("mygraph.graphml", g)  # save graph and properties in .graphml format
```

## Features

Refer to the [documentation](https://carlolucibello.github.io/Erdos.jl/latest) to explore all the features of Erdos.
Here is a comprehensive list of the implemente algorithms. (*EE*) denotes algorithms in the companion package [ErdosExtras](https://github.com/CarloLucibello/ErdosExtras.jl).

- **core functions:** vertices and edges addition and removal, degree (in/out/all), neighbors (in/out/all)

- **maps** dictionary like types to store properties associated to vertices and edges

- **networks** store vertex/edge/graph properties (maps) inside the graph itself

- **connectivity:** strongly- and weakly-connected components, bipartite checks, condensation, attracting components, neighborhood, k-core

- **operators:** complement, reverse, reverse!, union, join, intersect, difference, symmetric difference, blockdiag, induced subgraphs, products (cartesian/scalar)

- **shortest paths:** Dijkstra, Dijkstra with predecessors, Bellman-Ford, Floyd-Warshall, A*

- **graph datasets:** A collection of real world graphs (e.g. Zachary's karate club)

- **graph generators:** [notorious graphs](https://github.com/CarloLucibello/Erdos.jl/blob/master/src/generators/smallgraphs.jl), euclidean graphs and random graphs (Erdős–Rényi, Watts-Strogatz, random regular, arbitrary degree sequence, stochastic block model)

- **I/O formats:** [graphml](http://en.wikipedia.org/wiki/GraphML), [gml](https://en.wikipedia.org/wiki/Graph_Modelling_Language), [gexf](http://gexf.net/format), [dot](https://en.wikipedia.org/wiki/DOT_(graph_description_language)), [net](http://gephi.org/users/supported-graph-formats/pajek-net-format/), [gt](https://graph-tool.skewed.de/static/doc/gt_format.html). For some of these formats vertex/edge/graph properties can be read and written.

- **centrality:** betweenness, closeness, degree, pagerank, Katz

- **traversal operations:** cycle detection, BFS and DFS DAGs, BFS and DFS traversals with visitors, DFS topological sort, maximum adjacency / minimum cut, multiple random walks

- **flow operations:** maximum flow, minimum s-t cut

- **matching:** minimum weight matching on arbitrary graphs (*EE*), minimum b-matching (*EE*)

- **travelling salesman problem:** a TSP solver based on linear programming (*EE*)

- **dismantling:** collective influencer heuristic

- **clique enumeration:** maximal cliques

- **linear algebra / spectral graph theory:** adjacency matrix, Laplacian matrix, non-backtracking matrix

- **community:** modularity, community detection, core-periphery, clustering coefficients

- **distance within graphs:** eccentricity, diameter, periphery, radius, center

- **distance between graphs:** spectral_distance, edit_distance

## Licence and Credits

*Erdos* is released under MIT License. Graphs stored in the [datasets](https://github.com/CarloLucibello/Erdos.jl/tree/master/datasets) directory are released under GPLv3 License.

Huge credit goes to the contributors of [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl), from which this library is derived. Also thanks to Tiago de Paula Peixoto and his Python library [graph-tool](https://graph-tool.skewed.de/) for inspiration and for the graphs in [datasets](https://github.com/CarloLucibello/Erdos.jl/tree/master/datasets).
