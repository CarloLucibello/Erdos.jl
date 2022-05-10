# [Network Types and Interface] (@id network_interface)

Networks in *Erdos* are graphs with the additional capability of storing
properties associated to vertices, edges, and to the graph itself.
Edge and vertex properties are nothing else than edge and vertex maps with
a name associated to them. *Erdos* defines some interface methods and their
convenient short form equivalents to work with networks and properties.

```julia
julia> using Erdos

julia> g = Network(10, 20) # create erdos-renyi random network

julia> add_edge!(g, 1, 2); # add edge (1, 2) if it doesn't exists

julia> eprop!(g, "w", e -> rand()) # add edge property named "w"
Network(10, 20) with [] graph, [] vertex, ["w"] edge properties

julia> vprop!(g, "x", v -> [1,1]) # add vertex property named "x"
Network(10, 20) with [] graph, ["x"] vertex, ["w"] edge properties

julia> eprop(g, 1, 2, "w")
0.8959648919973169

julia> writenetwork("mygraph.graphml", g)  # save graph and properties in .graphml format
```

Attention: mutating the graph topology, e.g. adding or removing edges and vertices, invalidates the 
property maps.

## Property Interface

```@autodocs
Modules = [Erdos]
Pages   = ["core/interface_network.jl"]
Order   = [:function]
Private = false
```

## Defining new network types

In order to define a custom network type, e.g. `MyNet <: ANetwork`, the corresponding
[interface methods](@ref network_interface)  have to be implemented.
This is automatically done for custom network types having a `props::PropertyStore`
member. Take a look at `src/factory/network.jl` and `src/maps/property_store.jl` for an example.
