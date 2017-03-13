@compat abstract type ANetwork <: AGraph end
@compat abstract type ADiNetwork <: ADiGraph end

const ASimpleNetwork = Union{ANetwork, ADiNetwork}

type PropertyStore
    emaps::Dict{String,AEdgeMap}
    vmaps::Dict{String,AVertexMap}
end

PropertyStore() = PropertyStore(Dict{String,AEdgeMap}(), Dict{String,AVertexMap}())

"""
    add_edge_property!(g, name, T)

Add the edge property  `name` with value type `T` to `g`.
"""
function add_edge_property!{T}(g::ASimpleNetwork, name::String, ::Type{T})
    haskey(g.props.emaps, name) && error("Property $name already present.")
    g.props.emaps[name] = EdgeMap(g, T)
end

"""
    add_edge_property!(g, name, emap::AEdgeMap)

Add the edge map `emap` to `g` with name `name`.
"""
function add_edge_property!(g::ASimpleNetwork, name::String, emap::AEdgeMap)
    haskey(g.props.emaps, name) && error("Property $name already present.")
    g.props.emaps[name] = emap
end

"""
    rem_edge_property!(g, name)

Remove the edge property  `name` from `g`.
"""
function rem_edge_property!(g::ASimpleNetwork, name::String)
    !haskey(g.props.emaps, name) && error("Property $name not present.")
    delete!(g.props.emaps, name)
    g.props.emaps
end

"""
    edge_property(g, name)

Return an edge map corresponding to property `name` of edges in `g`.
"""
edge_property(g::ASimpleNetwork, name::String) = g.props.emaps[name]

"""
    edge_properties(g)

Return a vector listing the names of the properties of edges in `g`.
"""
edge_properties(g::ASimpleNetwork) = collect(keys(g.props.emaps))


"""
    add_vertex_property!(g, name, T)

Add the vertex property  `name` with value type `T` to `g`.
"""
function add_vertex_property!{T}(g::ASimpleNetwork, name::String, ::Type{T})
    haskey(g.props.vmaps, name) && error("Property $name already present.")
    g.props.vmaps[name] = VertexMap(g, T)
end

"""
    add_vertex_property!(g, name, vmap::AVertexMap)

Add the vertex map `vmap` to `g` with name `name`.
"""
function add_vertex_property!(g::ASimpleNetwork, name::String, vmap::AVertexMap)
    haskey(g.props.vmaps, name) && error("Property $name already present.")
    g.props.vmaps[name] = vmap
end

"""
    rem_vertex_property!(g, name)

Remove the vertex property  `name` from `g`.
"""
function rem_vertex_property!(g::ASimpleNetwork, name::String)
    !haskey(g.props.vmaps, name) && error("Property $name not present.")
    delete!(g.props.vmaps, name)
    g.props.vmaps
end

"""
    vertex_property(g, name)

Return an vertex map corresponding to property `name` of vertices in `g`.
"""
vertex_property(g::ASimpleNetwork, name::String) = g.props.vmaps[name]

"""
    vertex_properties(g)

Return a vector listing the names of the properties of vertices in `g`.
"""
vertex_properties(g::ASimpleNetwork) = collect(keys(g.props.vmaps))

function swap_vertices!(props::PropertyStore, u::Integer, v::Integer)
    for vmap in values(props.vmaps)
        hasu, hasv = hasindex(vmap, u), hasindex(vmap, v)
        if hasu && hasv
            vmap[u], vmap[v] = vmap[v], vmap[u]
        else
            if hasu
                vmap[v] = vmap[u]
            end
            if hasv
                vmap[u] = vmap[v]
            end
        end
    end
    #TODO should swap edges for non indexed graphs
end
