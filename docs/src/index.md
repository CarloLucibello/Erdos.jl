# FatGraphs
**FatGraphs** is a graph library written in Julia.
  
## Installation
Installation is straightforward:
```julia
julia> Pkg.add("FatGraphs")
```

## Basic examples
All examples apply equally to `DiGraph` unless otherwise noted:

```julia
g = Graph() # empty undirected graph

g = Graph(10) # a graph with 10 vertices and no edges
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
writegraph("mygraph.gml", g, :gml)
```
