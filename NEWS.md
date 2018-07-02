File no longer updated. See GitHub Releases for latest changes. 

## v0.5  2017.7.10
- add constructors `EdgeMap(g, e -> f(e))` and `VertexMap(g, v->f(v))`
- add `sort` for edges
- add `size(emap)` for edge map `emap` returning `(nv(g), nv(g))`
- add `Vector(vmap)`  
- fix bug in `has_edge` throwing error in some corner cases
- add `contract!` method
- add `rem_vertices!(g, v1, v2, ....)`
- `rem_vertices!` now returns a vertex map of the reindexed vertices instead of a vector of length `nv(g)`
- fix docs deploy

## v0.4  2017.6.16
- faster constructor from matrix. Also add the possibility to select only the upper triangular and/or the non-diagonal part.
- fix a bug with `DiGraph()` constructor returning a `Graph(0,0)`.
- `EdgeMap(g, m)` for matrix argument `m` now uses only the upper triangular part
of `m` if `g` is an undirected graph.
- add `edgemap2adjlist`
- `crosspath(n, g)` -> `crosspath(g, n)`
- conform indexing of `cartesian_product(g,h)` and `tensor_product(g,h)` to julia indexing for matrices:
  - before: `id(i,j) = (i-1)*nv(h) + nv(g)`
  - after: `id(i,j) = i + (j-1)*nv(g)`
- add `sparse` method to convert and edge map to a sparse matrix
- add `Matrix` method to convert and edge map to a matrix

## v0.3  2017.6.11
- `is_cyclic(g)` -> `has_cycles(g)`. Also it was basically not working for undirected graphs, fixed now.
- add `is_tree(g)`
- `vprop(g, v)` and `eprop(g, e)` return a dictionary containing the properties
of vertex `v` and edge `e` respectively.
- Improved support for `gexf` format. Now vertex/edge properties can be
exported and inported with `writenetwork` and `readnetwork`.
- add methods `has_eprop(g, name, e)` and `has_vprop(g, name, v)`
- internal implementation of `.gml`  parser. Dropped dependence on unmaintained ParserCombinator.jl package.
- Dropping `.dot` support until implementation of an internal parser.
- fixed all julia 0.6 deprecations
- Remove hack in matching with floating point: now using floating point compiled version
  of BlossomV.

## v0.2.0  2017.4.2
- Defined Abstract Network types and interfaces. Networks are graphs with properties. Properties can be associated to vertices, edges or the graph itself
- Implemented two default network types: `Network` and `DiNetwork`.
Internally they are the `GTGraph` and `GTDiGraph` of previous versions,
with the addition of a member of the newly defined type `PropertyStore`.
- `readnetwork` and `writenetwork` can read/write graph and graph/vertex/edge/properties to and from some graph file formats:
.gt, .graphml, .gml
- `subnetwork` is the analogue of `subgraph` method and preserves vertex/edge properties
- improvements to the `EdgeMap` type and interface
- more efficient `remove_vertex` and `swap_vertices`
- `add_edge!` now returns `(ok, new_edge)` instead of just `ok`
- `VertexMap` is now its own type

## v0.1.3  2017.3.8
- doc system updates
- release datasets under GPLv3
- interface with graph collection (datasets) through `readgraph`
- move testsets into files

## v0.1.2  2017.3.5
- read/write consistency: make sure that `writegraph("file",g); g == readgraph("file")`
- fixed some bugs in gml, net and dot formats

## v0.1.1  2017.3.4
- fix julia 0.6 deprecations
- update REQUIRE, README and docs

## v0.1  2017.2.19 (changes from LightGraphs 0.7.1)
### Highlights
- add changelog
- `Edge` is now its own type (not a `Pair{Int,Int}` anymore)
- improved docs
- introduce abstract types `AGraph`, `ADiGraph`  
- make all methods accept abstract graph types
- vertex type for Graph can be any integer, i.e. we have Graph{Int32} along the default Graph{Int}
- add `Network` and `DiNetwork`, graph types with indexed edges, inspired by graph-tool library
- simplified and generic edge iterator (now a Generator)
- improve maximum_flow performance
- add Benchmarks through BenchmarkTools
- add minimum s-t cut
- unsafe_add_edge! for faster graph creation
- add dismantling (influence propagation)
- remove dependence from Distributions, add StatsFuns
- add missing write support for dot
- add rem_vertices! Returns a map from the new vertices to old ones
- add cores and kcore

### Other Changes
- drop lg graph format
- removed member vertices from graph types
- removed graphmatrices (LinAlg submodule)
- bring in Matching, Community from LightGraphExtras
- removed linear programming matching on bipartite graphs in favor of BlossomV
- file and folders reorganization
- [I/O] rename save/load to readgraph/writegraph and drop support for multiple graphs in one file
- in_edges and out_edges now return iterators and not vectors
- change the return type of add_vertex! to nv(g)
- removed dynamic stochastic block model
- Graph(dg) -> graph(dg)
- remove fadj(g, v) in favor of out_neighbors(g, v)
- more efficient equality test for DiGraph
- remove fadj(g) in favor of adjacency_list
- add `graph` and `digraph`
- add `edge`
- add `edges(g, v)` and `edges(g, vertices)`
- induced_subgraph -> subgraph
- graph generators for arbitrary graph types
- smallgraph -> graph
- all_neighbors in digraph iterates over distinct neighbors
- kruskal_mst -> minimum_spanning_tree and more tests
- tests polishing and `@testset`
- remove is_connected and connected_components methods for digraphs
- add oriented option for incidence_matrix
- fix num connected components for empty graphs (now is one)
- add all_edges
- add graph-tool  i/o format (.gt)
- add datasets directory. Graphs from graph-tool collection
- add swap_vertices!
- move from LightXML to EzXML
- add missing read support for gexf
- deprecate adjacency_spectrum
