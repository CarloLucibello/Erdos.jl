# FatGraphs

[![Build Status](https://travis-ci.org/CarloLucibello/FatGraphs.jl.svg?branch=master)](https://travis-ci.org/CarloLucibello/FatGraphs.jl)
[![codecov.io](http://codecov.io/github/CarloLucibello/FatGraphs.jl/coverage.svg?branch=master)](http://codecov.io/github/CarloLucibello/FatGraphs.jl?branch=master)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://juliagraphs.github.io/FatGraphs.jl/latest)
[![FatGraphs](http://pkg.julialang.org/badges/FatGraphs_0.5.svg)](http://pkg.julialang.org/?pkg=FatGraphs)
[![FatGraphs](http://pkg.julialang.org/badges/FatGraphs_0.6.svg)](http://pkg.julialang.org/?pkg=FatGraphs)

A graph library entirely written in Julia, derived from the beautiful library [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl).

## Documentation
Full documentation available at [GitHub Pages](https://juliagraphs.github.io/FatGraphs.jl/latest).
Documentation for methods is also available via the Julia REPL help system.

## Installation
Installation is straightforward:
```julia
julia> Pkg.clone("https://github.com/CarloLucibello/FatGraphs.jl")
```

## Usage Examples
(all examples apply equally to `DiGraph` unless otherwise noted):

```julia
g = Graph() # empty undirected graph

g = Graph(10) # a graph with 10 veritces and no edges
@assert nv(g) == 10

g = Graph(10, 30) # a graph with 10 vertices and 30 randomly placed edges
@assert ne(g) == 30

add_edge!(g, 4, 5)
add_vertex!(g)
rem_vertex!(g, 2)
neighbors(g, 4)

# iterate over the edges
m = 0
for e in edges(g)
    m += 1
end
@assert m == ne(g)

# show distances between vertex 4 and all other vertices
dijkstra_shortest_paths(g, 4).dists

# as above, but with non-default edge distances
distmx = zeros(10,10)
distmx[4,5] = 2.5
distmx[5,4] = 2.5
dijkstra_shortest_paths(g, 4, distmx=distmx).dists

# graph I/O
g = readgraph("mygraph.gml", :gml)
savegraph("mygraph.gml", g, :gml)
```

## Current functionality
- **core functions:** vertices and edges addition and removal, degree (in/out/histogram), neighbors (in/out/all/common)

- **distance within graphs:** eccentricity, diameter, periphery, radius, center

- **distance between graphs:** spectral_distance, edit_distance

- **connectivity:** strongly- and weakly-connected components, bipartite checks, condensation, attracting components, neighborhood

- **operators:** complement, reverse, reverse!, union, join, intersect, difference, symmetric difference, blkdiag, induced subgraphs, products (cartesian/scalar)

- **shortest paths:** Dijkstra, Dijkstra with predecessors, Bellman-Ford, Floyd-Warshall, A*

- **small graph generators:** see [smallgraphs.jl](https://github.com/CarloLucibello/FatGraphs.jl/blob/master/src/datasets/smallgraphs.jl) for list

- **random graph generators:** Erdős–Rényi, Watts-Strogatz, random regular, arbitrary degree sequence, stochastic block model

- **centrality:** betweenness, closeness, degree, pagerank, Katz

- **traversal operations:** cycle detection, BFS and DFS DAGs, BFS and DFS traversals with visitors, DFS topological sort, maximum adjacency / minimum cut, multiple random walks

- **flow operations:** maximum flow, minimum s-t cut

- **matching:** minimum/maximum optimal matching on bipartite and arbitrary graphs

- **clique enumeration:** maximal cliques

- **linear algebra / spectral graph theory:** adjacency matrix (works as input to [GraphLayout](https://github.com/IainNZ/GraphLayout.jl) and [Metis](https://github.com/JuliaSparse/Metis.jl)), Laplacian matrix, non-backtracking matrix

- **community:** modularity, community detection, core-periphery, clustering coefficients

- **persistence formats:** proprietary compressed, [GraphML](http://en.wikipedia.org/wiki/GraphML), [GML](https://en.wikipedia.org/wiki/Graph_Modelling_Language), [Gexf](http://gexf.net/format), [DOT](https://en.wikipedia.org/wiki/DOT_(graph_description_language)), [Pajek NET](http://gephi.org/users/supported-graph-formats/pajek-net-format/)

- **visualization:** integration with [GraphLayout](https://github.com/IainNZ/GraphLayout.jl), [TikzGraphs](https://github.com/sisl/TikzGraphs.jl), [GraphPlot](https://github.com/afternone/GraphPlot.jl), [NetworkViz](https://github.com/abhijithanilkumar/NetworkViz.jl/)

## Contributing and Reporting Bugs
We welcome contributions and bug reports! Please see [CONTRIBUTING.md](https://github.com/CarloLucibello/FatGraphs.jl/blob/master/CONTRIBUTING.md)
for guidance on development and bug reporting.
