# [Network Types and Interface] (@id network_interface)
Networks in *Erdos* are graphs with additional ability to store internally
properties associated to vertices, edges and the graph itself.
Edge and vertex properties are nothing else than edge and vertex maps with
a name associated to them. *Erdos* defines some interface methods (and their
convenient short form equivalent) to work with networks and properties.

Here is a basic usage example:
```juliarepl
julia> using Erdos

julia> g=Network(10,20)
Network(10, 20) with [] graph, [] vertex, [] edge properties

julia> pos = vprop!(g, "pos", v->rand())
VertexMap: [0.604985, 0.98424, 0.212992, 0.739688, 0.560481, 0.620635, 0.946185, 0.44427, 0.346736, 0.708372]

julia> p = vprop!(g, "pos", v->rand())
VertexMap: [0.215528, 0.133838, 0.163788, 0.00937637, 0.436608, 0.0866319, 0.508895, 0.169567, 0.950561, 0.590688]

julia> w = eprop!(g, "weight", e->norm(p[src(e)] - p[dst(e)]))
EdgeMap: [0.16019, 0.786773, 0.0722865, 0.0771557, 0.349976, 0.0459615, 0.863929, 0.206152, 0.272821, 0.441666, 0.124462, 0.339328, 0.0299495, 0.504056, 0.0817933, 0.422263, 0.154411, 0.293367, 0.128896, 0.941184]

julia> writenetwork("net.gml", g)
1
```
or
```juliarepl
julia> g=readnetwork(:karate)
Network(34, 78) with ["readme", "description"] graph, ["pos"] vertex, [] edge properties

julia> vprop(g,"pos")
VertexMap: Array{Float64,1}[[-97.5189, -18.552], [-96.584, -16.904], [-93.4618, -17.9775], [-96.2455, -19.7365], [-99.9672, -20.0633], [-101.336, -21.6801], [-102.016, -19.8316], [-94.8687, -20.1434], [-93.8192, -15.8012], [-90.4103, -19.2883], [-99.2873, -22.1104], [-101.699, -16.7668], [-96.7786, -22.2723], [-94.9534, -17.5084], [-90.1117, -10.6745], [-90.0671, -12.4262], [-104.189, -21.8703], [-98.9084, -15.083], [-88.2782, -12.0377], [-95.9041, -15.011], [-91.9721, -10.9999], [-99.476, -17.0712], [-93.4856, -11.8873], [-88.4684, -15.9041], [-88.2959, -20.1105], [-87.2487, -18.2964], [-86.4256, -14.2439], [-89.5336, -17.6307], [-92.0378, -19.4002], [-88.3818, -14.0777], [-94.1062, -13.9659], [-91.5065, -17.5656], [-91.3596, -13.783], [-91.175, -15.0284]]

julia> p = vprop(g,"pos")
VertexMap: Array{Float64,1}[[-97.5189, -18.552], [-96.584, -16.904], [-93.4618, -17.9775], [-96.2455, -19.7365], [-99.9672, -20.0633], [-101.336, -21.6801], [-102.016, -19.8316], [-94.8687, -20.1434], [-93.8192, -15.8012], [-90.4103, -19.2883], [-99.2873, -22.1104], [-101.699, -16.7668], [-96.7786, -22.2723], [-94.9534, -17.5084], [-90.1117, -10.6745], [-90.0671, -12.4262], [-104.189, -21.8703], [-98.9084, -15.083], [-88.2782, -12.0377], [-95.9041, -15.011], [-91.9721, -10.9999], [-99.476, -17.0712], [-93.4856, -11.8873], [-88.4684, -15.9041], [-88.2959, -20.1105], [-87.2487, -18.2964], [-86.4256, -14.2439], [-89.5336, -17.6307], [-92.0378, -19.4002], [-88.3818, -14.0777], [-94.1062, -13.9659], [-91.5065, -17.5656], [-91.3596, -13.783], [-91.175, -15.0284]]

julia> w = eprop!(g, "weight", e->norm(p[src(e)] - p[dst(e)]))
EdgeMap: Any[0.16019, 0.786773, 0.0722865, 0.0771557, 0.349976, 0.0459615, 0.863929, 0.206152, 0.272821, 0.441666, 0.124462, 0.339328, 0.0299495, 0.504056, 0.0817933, 0.422263, 0.154411, 0.293367, 0.128896, 0.941184]

julia> writenetwork("net.gml", g)
1
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
[interface methods](@ref network_interface)  have to be implemented.
This is automatically done for custom network types having a `props::PropertyStore`
member. Take a look to `src/factory/net.jl` and `src/maps/property_store.jl` for an example.
