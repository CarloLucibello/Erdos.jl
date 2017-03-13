@compat abstract type ANetwork <: AGraph end
@compat abstract type ADiNetwork <: ADiGraph end
const APropertySimpleGraph = Union{ANetwork, ADiNetwork}

type PropertyStore
    emaps::Dict{String,AEdgeMap}
    vmaps::Dict{String,AVertexMap}
end

PropertyStore() = PropertyStore(Dict{String,AEdgeMap}(), Dict{String,AVertexMap}())

"""
    add_edge_property!(g, name, T)

Add the edge property  `name` with value type `T` to `g`.
"""
function add_edge_property!{T}(g::APropertySimpleGraph, name::String, ::Type{T})
    haskey(g.props.emaps, name) && error("Property $name already present.")
    g.props.emaps[name] = EdgeMap(g, T)
end

"""
    add_edge_property!(g, name, emap::AEdgeMap)

Add the edge map `emap` to `g` with name `name`.
"""
function add_edge_property!(g::APropertySimpleGraph, name::String, emap::AEdgeMap)
    haskey(g.props.emaps, name) && error("Property $name already present.")
    g.props.emaps[name] = emap
end

"""
    rem_edge_property!(g, name)

Remove the edge property  `name` from `g`.
"""
function rem_edge_property!(g::APropertySimpleGraph, name::String)
    !haskey(g.props.emaps, name) && error("Property $name not present.")
    delete!(g.props.emaps, name)
    g.props.emaps
end

"""
    get_edge_property(g, name)

Return an edge map corresponding to property `name` of edges in `g`.
"""
get_edge_property(g::APropertySimpleGraph, name::String) = g.props.emaps[name]

"""
    add_vertex_property!(g, name, T)

Add the vertex property  `name` with value type `T` to `g`.
"""
function add_vertex_property!{T}(g::APropertySimpleGraph, name::String, ::Type{T})
    haskey(g.props.vmaps, name) && error("Property $name already present.")
    g.props.vmaps[name] = VertexMap(g, T)
end

"""
    add_vertex_property!(g, name, vmap::AVertexMap)

Add the vertex map `vmap` to `g` with name `name`.
"""
function add_vertex_property!(g::APropertySimpleGraph, name::String, vmap::AVertexMap)
    haskey(g.props.vmaps, name) && error("Property $name already present.")
    g.props.vmaps[name] = vmap
end

"""
    rem_vertex_property!(g, name)

Remove the vertex property  `name` from `g`.
"""
function rem_vertex_property!(g::APropertySimpleGraph, name::String)
    !haskey(g.props.vmaps, name) && error("Property $name not present.")
    delete!(g.props.vmaps, name)
    g.props.vmaps
end

"""
    get_vertex_property(g, name)

Return an vertex map corresponding to property `name` of vertices in `g`.
"""
get_vertex_property(g::APropertySimpleGraph, name::String) = g.props.vmaps[name]
