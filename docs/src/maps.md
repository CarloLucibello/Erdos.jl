# Maps
Arbitrary values can be associated to a graph's vertices and edges, and handed
over to method's that necessitate them, thanks to the edge maps and vertex maps
interfaces.

## Edge Maps
```@autodocs
Modules = [FatGraphs]
Pages   = [ "maps/edgemap.jl"]
Private = false
```

## Vertex Maps
Any `AbstractVector{T}` or `Dict{Int,T}` can be used as a vertex map.
```@autodocs
Modules = [FatGraphs]
Pages   = [ "maps/vertexmap.jl"]
Private = false
```
