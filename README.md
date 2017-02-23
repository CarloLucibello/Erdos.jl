# Erdos

[![Build Status](https://travis-ci.org/CarloLucibello/Erdos.jl.svg?branch=master)](https://travis-ci.org/CarloLucibello/Erdos.jl)
[![codecov.io](http://codecov.io/github/CarloLucibello/Erdos.jl/coverage.svg?branch=master)](http://codecov.io/github/CarloLucibello/Erdos.jl?branch=master)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://carlolucibello.github.io/Erdos.jl)

A graph library entirely written in Julia.
It is derived from [LightGraphs.jl](https://github.com/JuliaGraphs/LightGraphs.jl), with the addition of an abstract
graph interface and custom graph types, e.g. Erdos has `Graph{Int32}` (to save memory when working with very large graphs) and graph types with indexed edges. It comes with other goodies such as edge/vertex maps, improved flows, k-core, graph dismantling and many more stuff. We welcome contributions and bug reports!

## Documentation
Full documentation available at [GitHub Pages](https://carlolucibello.github.io/Erdos.jl).
Documentation for methods is also available via the Julia REPL help system.
See also the [CHANGELOG](https://github.com/CarloLucibello/Erdos.jl/blob/master/CHANGELOG.md) for differences with previous versions.

## Installation
Installation is straightforward:
```julia
julia> Pkg.clone("https://github.com/CarloLucibello/Erdos.jl")
```

## Features
- **core functions:** vertices and edges addition and removal, degree (in/out/histogram), neighbors (in/out/all/common)

- **distance within graphs:** eccentricity, diameter, periphery, radius, center

- **distance between graphs:** spectral_distance, edit_distance

- **connectivity:** strongly- and weakly-connected components, bipartite checks, condensation, attracting components, neighborhood, k-core

- **operators:** complement, reverse, reverse!, union, join, intersect, difference, symmetric difference, blkdiag, induced subgraphs, products (cartesian/scalar)

- **shortest paths:** Dijkstra, Dijkstra with predecessors, Bellman-Ford, Floyd-Warshall, A*

- **small graph generators:** see [smallgraphs.jl](https://github.com/CarloLucibello/Erdos.jl/blob/master/src/datasets/smallgraphs.jl) for a list

- **random graph generators:** Erdős–Rényi, Watts-Strogatz, random regular, arbitrary degree sequence, stochastic block model

- **centrality:** betweenness, closeness, degree, pagerank, Katz

- **traversal operations:** cycle detection, BFS and DFS DAGs, BFS and DFS traversals with visitors, DFS topological sort, maximum adjacency / minimum cut, multiple random walks

- **flow operations:** maximum flow, minimum s-t cut

- **matching:** maximum weight matching on arbitrary graphs (through BlossomV algorithm)

- **dismantling:** collective influencer heuristic

- **clique enumeration:** maximal cliques

- **linear algebra / spectral graph theory:** adjacency matrix, Laplacian matrix, non-backtracking matrix

- **community:** modularity, community detection, core-periphery, clustering coefficients

- **I/O formats:** [graphml](http://en.wikipedia.org/wiki/GraphML), [gml](https://en.wikipedia.org/wiki/Graph_Modelling_Language), [gexf](http://gexf.net/format), [dot](https://en.wikipedia.org/wiki/DOT_(graph_description_language)), [net](http://gephi.org/users/supported-graph-formats/pajek-net-format/), [gt](https://graph-tool.skewed.de/static/doc/gt_format.html)
