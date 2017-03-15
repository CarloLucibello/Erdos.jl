# [Network Types and Interface] (@id network_types)
Networks in *Erdos.jl* are graphs with additional ability to store properties
associated to vertices, edges and the graph itself.
The ready to go network types are the `Net` and `DiNet` types. Custom
types con be defined inheriting from `ANetwork` and `ADiNetwork` abstract types.

## Abstract Types

```@docs
ANetwork
ADiNetwork
AIndexedEdge
AEdgeMap
AVertexMap
```

## Net / DiNet / IndexedEdge

```@docs
Net
DiNet
IndexedEdge
```
## Property Interface

```@autodocs
Modules = [Erdos]
Pages   = ["core/interface_network.jl"]
Order   = [:function]
Private = false
```

## Defining new network types
In order to define a custom network type, e.g. `MyNet <: ANetwork`, the corresponding
methods in the preceding paragraph have to be implemented.
This is automatically done for custom network types having a `props::PropertyStore`
member. Take a look to `src/factory/net.jl` and `src/maps/property_store.jl` for an example.
