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

const ASimpleNetwork = Union{ANetwork, ADiNetwork}


function show{G<:ASimpleNetwork}(io::IO, g::G)
    print(io, split("$G",'.')[end], "($(nv(g)), $(ne(g)))")
    print(io, " with ")
    _printstrvec(io, graph_properties(g))
    print(io, " graph, ")
    _printstrvec(io, vertex_properties(g))
    print(io," vertex, ")
    _printstrvec(io, edge_properties(g))
    print(io, " edge properties.")
end

function _printstrvec(io::IO, vs::Vector{String})
    print(io,"[")
    if length(vs) > 0
        for s in vs[1:end-1]
            print(io, "\"" * s * "\", ")
        end
        print(io, "\"" * last(vs) * "\"")
    end
    print(io,"]")
end


type PropertyStore
    gmaps::Dict{String, Any}
    emaps::Dict{String,AEdgeMap}
    vmaps::Dict{String,AVertexMap}
end

PropertyStore() = PropertyStore(Dict{String, Any}(), Dict{String,AEdgeMap}(), Dict{String,AVertexMap}())

### GRAPH
"""
    set_graph_property!(g, name, x)

Add the property `name` with value `x` to `g`.
"""
function set_graph_property!(g::ASimpleNetwork, name::String, x)
    g.props.gmaps[name] = x
end

"""
    rem_graph_property!(g, name)

Remove the property `name` from `g`.
"""
function rem_graph_property!(g::ASimpleNetwork, name::String)
    !haskey(g.props.gmaps, name) && error("Property $name not present.")
    delete!(g.props.gmaps, name)
    g.props.gmaps
end

"""
    graph_property(g, name)

Return the property `name` of `g`.
"""
graph_property(g::ASimpleNetwork, name::String) = g.props.gmaps[name]

"""
    graph_properties(g)

Return a vector listing the names of the properties of `g`.
"""
graph_properties(g::ASimpleNetwork) = collect(keys(g.props.gmaps))


### EDGE
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

function ==(p1::PropertyStore, p2::PropertyStore)
    oke = true
    for name in keys(p1.emaps)
        if !haskey(p2.emaps, name)
            oke = false
            break
        end
        oke &= p1.emaps[name] == p2.emaps[name]
    end
    return (p1.gmaps == p2.gmaps) && (p1.emaps == p2.emaps) && oke
end
