# Erdos
[![][docs-latest-img]][docs-latest-url]
[![][codecov-img]][codecov-url]
[![][travis-img]][travis-url]
[![][pkg-0.5-img]][pkg-0.5-url]
[![][pkg-0.6-img]][pkg-0.6-url]


[pkg-0.5-img]: http://pkg.julialang.org/badges/Erdos_0.5.svg
[pkg-0.5-url]: http://pkg.julialang.org/?pkg=Erdos
[pkg-0.6-img]: http://pkg.julialang.org/badges/Erdos_0.6.svg
[pkg-0.6-url]: http://pkg.julialang.org/?pkg=Erdos

[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://carlolucibello.github.io/Erdos.jl/

[travis-img]: https://travis-ci.org/CarloLucibello/Erdos.jl.svg?branch=master
[travis-url]: https://travis-ci.org/CarloLucibello/Erdos.jl

[codecov-img]: https://codecov.io/gh/CarloLucibello/Erdos.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/CarloLucibello/Erdos.jl


A graph library entirely written in Julia. Install it with
```julia
julia> Pkg.add("Erdos")
```
## Documentation
Full documentation available at [GitHub Pages](https://carlolucibello.github.io/Erdos.jl).
Methods' documentation is also available via the Julia REPL help system.
See also [NEWS.md](https://github.com/CarloLucibello/Erdos.jl/blob/master/NEWS.md) for differences with previous versions.

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
