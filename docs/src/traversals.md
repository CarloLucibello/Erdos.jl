# Path and Traversal

*FatGraphs.jl* provides several traversal and shortest-path algorithms, along with
various utility functions. Where appropriate, edge distances may be passed in as a
matrix of real number values.

Edge distances for most traversals may be passed in as a sparse or dense matrix
of  values, indexed by `[src,dst]` vertices. That is, `distmx[2,4] = 2.5`
assigns the distance `2.5` to the (directed) edge connecting vertex 2 and vertex 4.
Note that also for undirected graphs `distmx[4,2]` has to be set.

Any graph traversal  will traverse an edge only if it is present in the graph. When a distance matrix is passed in,

1. distance values for undefined edges will be ignored, and
2. any unassigned values (in sparse distance matrices), for edges that are present in the graph, will be assumed to take the default value of 1.0.
3. any zero values (in sparse/dense distance matrices), for edges that are present in the graph, will instead have an implicit edge cost of 1.0.

## Graph Traversal

*Graph traversal* refers to a process that traverses vertices of a graph following certain order (starting from user-input sources). This package implements three traversal schemes:

* `BreadthFirst`,
* `DepthFirst`, and
* `MaximumAdjacency`.
<!---
TODO separate the 3 in different paragraphs?
-->
```@autodocs
Modules = [FatGraphs]
Order = [:type, :function]
Pages   = [ "traversals/bfs.jl",
            "traversals/dfs.jl",
            "traversals/maxadjvisit.jl",
            "traversals/graphvisit.jl"
          ]

Private = false
```
## Random walks

*FatGraphs* includes uniform random walks and self avoiding walks:


```@autodocs
Modules = [FatGraphs]
Order = [:type, :function]
Pages   = [ "traversals/randomwalks.jl"]
Private = false
```
## Connectivity / Bipartiteness

`Graph connectivity` functions are defined on both undirected and directed graphs:


```@autodocs
Modules = [FatGraphs]
Order = [:type, :function]
Pages   = [ "traversals/connectivity.jl"]
Private = false
```
