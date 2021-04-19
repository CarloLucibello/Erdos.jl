# Edge and Vertex Maps

Arbitrary values can be associated to a graph's vertices and edges, and handed
over to method's that necessitate them, thanks to the edge maps and vertex maps
interfaces. Also, edge and vector maps can be internally stored in
[network types](@ref network_types) and accessed through the
[property interface](@ref network_interface).

Attention: mutating the graph topology, e.g. adding or removing edges and vertices, invalidates the 
property maps.

**Example usage**:

```julia
# create a graph
g = erdos_renyi(10,0.1)


# assign random weights to each edge
weights = EdgeMap(g, e -> rand())

for e in edges(g)
   # access map value
   w = weights[e]
   # or 
   i, j = e
   w = weights[i,j]
   .....
end
```

## Edge Maps

```@autodocs
Modules = [Erdos]
Pages   = [ "maps/edgemap.jl"]
Private = false
```

## Vertex Maps

Any `AbstractVector{T}` or `Dict{Int,T}` can be used as a vertex map.

```@autodocs
Modules = [Erdos]
Pages   = [ "maps/vertexmap.jl"]
Private = false
```

## PropertyStore

```@autodocs
Modules = [Erdos]
Pages   = [ "maps/property_store.jl"]
Private = false
```
