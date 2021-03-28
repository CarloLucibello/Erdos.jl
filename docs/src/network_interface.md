# [Network Types and Interface] (@id network_interface)
Networks in *Erdos* are graphs with additional ability to store internally
properties associated to vertices, edges and the graph itself.
Edge and vertex properties are nothing else than edge and vertex maps with
a name associated to them. *Erdos* defines some interface methods (and their
convenient short form equivalent) to work with networks and properties.

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
member. Take a look to `src/factory/network.jl` and `src/maps/property_store.jl` for an example.
