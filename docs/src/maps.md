# Edge and Vertex Maps
Arbitrary values can be associated to a graph's vertices and edges, and handed
over to method's that necessitate them, thanks to the edge maps and vertex maps
interfaces. Also, edge and vector maps can be internally stored in
[network types](@ref network_types) and accessed through the
[property interface](@ref network_interface).

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
