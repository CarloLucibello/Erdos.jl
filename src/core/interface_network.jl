"""
    abstract type AIndexedEdge <: AEdge end

Edge types with unique indexes, accessed by [`idx`](@ref)
"""
@compat abstract type AIndexedEdge <: AEdge end

"""
    idx(e::AIndexedEdge)

Returns the index of edge `e`.
"""
idx(e::AIndexedEdge) = error("Method not defined")

"""
    const AVertexMap{V,T} = Union{AbstractVector{T}, Dict{V,T}}

Type representing an abstract vertex map.
"""
@compat const AVertexMap{V,T} = Union{AbstractVector{T}, Dict{V,T}}

"""
    AEdgeMap{T}

Type representing an abstract edge map.
"""
@compat abstract type AEdgeMap{T} end

valtype{T}(m::AEdgeMap{T}) = T

"""
    abstract type ANetwork <: AGraph end

An abstract graph with the additional possibility to attach properties to vertices and edges.
"""
@compat abstract type ANetwork <: AGraph end

"""
    abstract type ADiNetwork <: ADiGraph end

An abstract directed graph with the additional possibility to attach properties to vertices and edges.
"""
@compat abstract type ADiNetwork <: ADiGraph end

const ANetOrDiNet = Union{ANetwork, ADiNetwork}


### GRAPH
"""
    set_graph_property!(g, name, x)

Set the property `name` to value `x` to `g`. Creates the property if it doesn't exist.
"""
set_graph_property!(g::ANetOrDiNet, name::String, x) = set_graph_property!(g.props, name, x)
gprop! = set_graph_property!

"""
    rem_graph_property!(g, name)

Remove the property `name` from `g`.
"""
rem_graph_property!(g::ANetOrDiNet, name::String) = rem_graph_property!(g.props, name)
rem_gprop! = rem_graph_property!
"""
    graph_property(g, name)

Return the property `name` of `g`.
"""
graph_property(g::ANetOrDiNet, name::String) = graph_property(g.props, name)
gprop = graph_property

"""
    graph_properties(g)

Return a vector listing the names of the properties of `g`.
"""
graph_properties(g::ANetOrDiNet) = graph_properties(g.props)
gprops = graph_properties

### EDGE
"""
    add_edge_property!(g, name, T)

Add the edge property  `name` with value type `T` to `g`.
"""
add_edge_property!{T}(g::ANetOrDiNet, name::String, ::Type{T}) = add_edge_property!(g.props, name, EdgeMap(g, T))
eprop! = add_edge_property!

"""
    add_edge_property!(g, name, emap::AEdgeMap)

Add the edge map `emap` to `g` with name `name`.
"""
add_edge_property!(g::ANetOrDiNet, name::String, emap::AEdgeMap) = add_edge_property!(g.props, name, emap)

"""
    rem_edge_property!(g, name)

Remove the edge property  `name` from `g`.
"""
rem_edge_property!(g::ANetOrDiNet, name::String) = rem_edge_property!(g.props, name)
rem_eprop! = rem_edge_property!

"""
    edge_property(g, name)

Return an edge map corresponding to property `name` of edges in `g`.
"""
edge_property(g::ANetOrDiNet, name::String) = edge_property(g.props, name)
eprop = edge_property

"""
    edge_properties(g)

Return a vector listing the names of the properties of edges in `g`.
"""
edge_properties(g::ANetOrDiNet) = edge_properties(g.props)
eprops = edge_properties

"""
    add_vertex_property!(g, name, T)

Add the vertex property  `name` with value type `T` to `g`.
"""
add_vertex_property!{T}(g::ANetOrDiNet, name::String, ::Type{T}) = add_vertex_property!(g.props, name, VertexMap(g, T))
vprop! = add_vertex_property!
"""
    add_vertex_property!(g, name, vmap::AVertexMap)

Add the vertex map `vmap` to `g` with name `name`.
"""
add_vertex_property!(g::ANetOrDiNet, name::String, vmap::AVertexMap) = add_vertex_property!(g.props, name, vmap)

"""
    rem_vertex_property!(g, name)

Remove the vertex property  `name` from `g`.
"""
rem_vertex_property!(g::ANetOrDiNet, name::String) = rem_vertex_property!(g.props, name)
rem_vprop! = rem_vertex_property!

"""
    vertex_property(g, name)

Return an vertex map corresponding to property `name` of vertices in `g`.
"""
vertex_property(g::ANetOrDiNet, name::String) = vertex_property(g.props, name)
vprop = vertex_property

"""
    vertex_properties(g)

Return a vector listing the names of the properties of vertices in `g`.
"""
vertex_properties(g::ANetOrDiNet) = vertex_properties(g.props)
vprops = vertex_properties

gprop_names(g::ANetOrDiNet) = collect(keys(gprops(g)))
vprop_names(g::ANetOrDiNet) = collect(keys(vprops(g)))
eprop_names(g::ANetOrDiNet) = collect(keys(eprops(g)))

has_gprop(g::ANetOrDiNet, name::String) = has_gprop(g.props, name)
has_vprop(g::ANetOrDiNet, name::String) = has_vprop(g.props, name)
has_eprop(g::ANetOrDiNet, name::String) = has_eprop(g.props, name)

# TODO document short forms
