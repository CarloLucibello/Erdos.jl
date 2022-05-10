# AEdgeMap and AVertexMap defined her for include precedence

"""
    abstract type AEdgeMap{T} end

Type representing an abstract edge map with value type `T`.
"""
abstract type AEdgeMap{T} end

"""
    abstract type AVertexMap{T} end

Type representing an abstract vertex map with value type `T`.
"""
abstract type AVertexMap{T} end

"""
    abstract type AIndexedEdge <: AEdge end

Edge types with unique indexes, accessed by [`idx`](@ref)
"""
abstract type AIndexedEdge <: AEdge end

"""
    idx(e::AIndexedEdge)

Returns the index of edge `e`.
"""
idx(e::AIndexedEdge) = error("Method not defined")

"""
    abstract type ANetwork <: AGraph end

An abstract graph with the additional possibility to attach properties to vertices and edges.
"""
abstract type ANetwork <: AGraph end

"""
    abstract type ADiNetwork <: ADiGraph end

An abstract directed graph with the additional possibility to attach properties to vertices and edges.
"""
abstract type ADiNetwork <: ADiGraph end

const ANetOrDiNet = Union{ANetwork, ADiNetwork}


### GRAPH
"""
    set_graph_property!(g, name, x)

Set the property `name` to value `x` to `g`. Creates the property if it doesn't exist.
[`gprop!`](@ref) can be conveniently used as a short form of this function.

**Example**
```julia
g = Network(10, 20)
set_graph_property!(g, "label", "My Network")
# or equivalently
gprop!(g, "label", "My Network")
```
"""
set_graph_property!(g::ANetOrDiNet, name::AbstractString, x) = set_graph_property!(g.props, name, x)

"""See [`set_graph_property!`](@ref)"""
gprop! = set_graph_property!

"""
    rem_graph_property!(g, name)

Remove the property `name` from `g`.

[`rem_gprop!`](@ref) is the short form of this function.
"""
rem_graph_property!(g::ANetOrDiNet, name::AbstractString) = rem_graph_property!(g.props, name)

"""See [`rem_graph_property!`](@ref)"""
rem_gprop! = rem_graph_property!

"""
    graph_property(g, name)

Return the property `name` of `g`.

    graph_property(g)

Returns a dictionary with elements `property_name => property_value`

[`gprop`](@ref) is the short form of this function.
"""
graph_property(g::ANetOrDiNet, name::AbstractString) = graph_property(g.props, name)
graph_property(g::ANetOrDiNet) = graph_property(g.props)

"""See [`graph_property`](@ref)"""
gprop = graph_property

"""
    has_graph_property(g, name)

Check if network  `g` has a graph property named `name`.

[`has_gprop`](@ref) is the short form of this function.
"""
has_graph_property(g::ANetOrDiNet, name::AbstractString) = has_graph_property(g.props, name)

"""See [`has_graph_property`](@ref)"""
has_gprop = has_graph_property


### EDGE
"""
    add_edge_property!(g, name, T)
    add_edge_property!(g, name, emap)

Add the edge property  `name` to `g`.

If a type `T` is given as an input, an edge map with valtype `T` is created and
stored into `g`.

As an alternative, an existing edge map `emap` can be stored into `g`.

[`eprop!`](@ref) is the short form of this function.

**Example**
```julia
g = random_regular_graph(10, 3, Network)

add_edge_property!(g, "weight", Float64)
# or equivalently
eprop!(g, "weight", Float64)
```
"""
add_edge_property!(g::ANetOrDiNet, name::AbstractString, emap::AEdgeMap) = 
    (add_edge_property!(g.props, name, emap); g)
add_edge_property!(g::ANetOrDiNet, name::AbstractString, ::Type{T}) where {T} = add_edge_property!(g, name, EdgeMap(g, T))
add_edge_property!(g::ANetOrDiNet, name::AbstractString, data) = add_edge_property!(g, name, EdgeMap(g, data))


"""See [`add_edge_property!`](@ref)"""
eprop! = add_edge_property!

"""
    rem_edge_property!(g, name)

Remove the edge property  `name` from `g`.

[`rem_eprop!`](@ref) is the short form of this function.
"""
rem_edge_property!(g::ANetOrDiNet, name::AbstractString) = 
    (rem_edge_property!(g.props, name); g)

"""See [`rem_edge_property!`](@ref)"""
rem_eprop! = rem_edge_property!

"""
    edge_property(g, name)

Return an edge map corresponding to property `name` of edges in `g`.

    edge_property(g)

Returns a dictionary with elements `property_name => edge_map`.

    edge_property(g, e)
    edge_property(g, u, v)

Returns a dictionary of the form `name => val` containing all the properties
associated to edge `e`.

    edge_property(g, e, name)
    edge_property(g, u, v, name)

Equivalent to `edge_property(g, e)[name]`

[`eprop`](@ref) is the short form of this function.
"""
edge_property(g::ANetOrDiNet, name::AbstractString) = edge_property(g.props, name)
edge_property(g::ANetOrDiNet) = edge_property(g.props)
edge_property(g::ANetOrDiNet, e::AEdge) = edge_property(g.props, e)
edge_property(g::ANetOrDiNet, u::Integer, v::Integer) = edge_property(g.props, edge(g, u, v))
edge_property(g::ANetOrDiNet, e::AEdge, name::AbstractString) = 
    edge_property(g.props, e)[name]
edge_property(g::ANetOrDiNet, u::Integer, v::Integer, name::AbstractString) = 
    edge_property(g.props, edge(g, u, v))[name]


"""See [`edge_property`](@ref)"""
eprop = edge_property


"""
    has_edge_property(g, name)
    has_edge_property(g, name, e)

Check if network  `g` has an edge property named `name`.
The second method checks also if edge `e` has an assigned value for
that property.



[`has_eprop`](@ref) is the short form of this function.
"""
has_edge_property(g::ANetOrDiNet, name::AbstractString) = has_edge_property(g.props, name)
has_edge_property(g::ANetOrDiNet, name::AbstractString, e::AEdge) = has_edge_property(g.props, name, e)


"""See [`has_edge_property`](@ref)"""
has_eprop = has_edge_property

####################

"""
    add_vertex_property!(g, name, T)
    add_vertex_property!(g, name, vmap)

Add the vertex property  `name` to `g`.

If a type `T` is given as an input, a vertex map with valtype `T` is created and
stored into `g`.

As an alternative, an existing vertex map `vmap` can be stored into `g`.

[`vprop!`](@ref) is the short form of this function.
"""
add_vertex_property!(g::ANetOrDiNet, name::AbstractString, vmap::AVertexMap) = 
    (add_vertex_property!(g.props, name, vmap); g)
add_vertex_property!(g::ANetOrDiNet, name::AbstractString, ::Type{T}) where {T} = add_vertex_property!(g, name, VertexMap(g, T))
add_vertex_property!(g::ANetOrDiNet, name::AbstractString, data) = add_vertex_property!(g, name, VertexMap(g, data))

"""See [`add_vertex_property!`](@ref)"""
vprop! = add_vertex_property!


"""
    rem_vertex_property!(g, name)

Remove the vertex property  `name` from `g`.

[`rem_vprop!`](@ref) is the short form of this function.
"""
rem_vertex_property!(g::ANetOrDiNet, name::AbstractString) = 
    (rem_vertex_property!(g.props, name); g)

"""See [`rem_vertex_property!`](@ref)"""
rem_vprop! = rem_vertex_property!

"""
    vertex_property(g, name)

Return an vertex map corresponding to property `name` of vertices in `g`.

    vertex_property(g)

Returns a dictionary with elements `property_name => vertex_map`.

    vertex_property(g, v)

Returns a dictionary in the form `name => val` containing all the properties
associated to vertex `v`.

    vertex_property(g, v, name)

Equivalent to `vertex_property(g, v)[name]`.

[`vprop`](@ref) is the short form for this function.
"""
vertex_property(g::ANetOrDiNet, name::AbstractString) = vertex_property(g.props, name)
vertex_property(g::ANetOrDiNet) = vertex_property(g.props)
vertex_property(g::ANetOrDiNet, v::Integer) = vertex_property(g.props, v)
vertex_property(g::ANetOrDiNet, v::Integer, name::AbstractString) = vertex_property(g.props, v)[name]

"""See [`vertex_property`](@ref)"""
vprop = vertex_property

"""
    has_vertex_property(g, name, v)

Check if network  `g` has a vertex property named `name`.
The second method checks also if vertex `v` has an assigned value for
that property.

[`has_vprop`](@ref) is the short form of this function.
"""
has_vertex_property(g::ANetOrDiNet, name::AbstractString) = has_vertex_property(g.props, name)
has_vertex_property(g::ANetOrDiNet, name::AbstractString, v::Integer) =
                                    has_vertex_property(g.props, name, v)

"""See [`has_vertex_property`](@ref)"""
has_vprop = has_vertex_property


# TODO export
gprop_names(g::ANetOrDiNet) = collect(keys(gprop(g)))
vprop_names(g::ANetOrDiNet) = collect(keys(vprop(g)))
eprop_names(g::ANetOrDiNet) = collect(keys(eprop(g)))
