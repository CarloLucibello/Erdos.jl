# Graph Types and Constructors
*Erdos.jl* defines a type hierarchy and associated methods for expressing a
graph topology and implementing related algorithms.
The ready to go graph types are the `Graph` type for undirected graphs and
the `DiGraph` type for directed graphs. Custom
types con be defined inheriting from the abstract types `AGraph` and `ADiGraph`.
Graph types supporting the internal storages of edge/vertex properties are
called **networks** in Erdos and are documeted [here](@ref network_types)

## Abstract Types

```@docs
AGraph
ADiGraph
AGraphOrDiGraph
AEdge
```

## Graph / DiGraph / Edge

```@docs
Graph
DiGraph
Edge
```

## Defining new types
In order to define a custom graph type, e.g. `MyGraph <: AGraph`, some guarantee have to be respected and some methods have to be exposed. Take a look to the files in `src/factory/` for some examples. Custom edges, e.g. `MyEdge <: AEdge`,  have to expose `src(e)` and `dst(e)` methods.

**Guarantees**:
- vertices are integers in 1:nv(g)

**Mandatory methods**:
- basic constructors (e.g. MyGraph(n), MyGraph())
- nv(g)
- ne(g)
- out_neighbors(g, v)
- in_neighbors(g, v) #digraph
- edge(g, u, v)
- add_edge!(g, u, v)
- rem_edge!(g, u, v)
- add_vertex!(g)
- pop_vertex!(g)
- graphtype(g)
- digraphtype(g)
- edgetype(g)
- vertextype(g)
- swap_vertices!(g, u, v)

Some methods have general fallbacks relying on the more foundamental API described above, but could probably made more efficient knowing the internal
implementation of the graph.

**Reccomended overrides**:
- in_adjlist(g) #digraph
- out_adjlist(g)
- has_edge(g, u, v)
- ==(g, h)
- out_edges(g, u)
- in_edges(g, u) # digraph
- rem_edge!(g, e)
- graph(dg)
- digraph(g)
- reverse!(g) #digraph
- unsafe_add_edge!(g, u, v)
- rebuild!(g)
- rem_vertex!(g, v)
