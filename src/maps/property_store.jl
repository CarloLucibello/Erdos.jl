"""
    mutable struct PropertyStore
        gmaps::Dict{String, Any}
        emaps::Dict{String,AEdgeMap}
        vmaps::Dict{String,AVertexMap}
    end

A type storing properties associated to networks.
"""
mutable struct PropertyStore
    gmaps::Dict{String, Any}
    emaps::Dict{String,AEdgeMap}
    vmaps::Dict{String,AVertexMap}
end

PropertyStore() = PropertyStore(Dict{String, Any}(), Dict{String,AEdgeMap}(), Dict{String,AVertexMap}())

### GRAPH
function set_graph_property!(p::PropertyStore, name::AbstractString, x)
    p.gmaps[name] = x
end

function rem_graph_property!(p::PropertyStore, name::AbstractString)
    !haskey(p.gmaps, name) && error("Property $name not present.")
    delete!(p.gmaps, name)
    p.gmaps
end

graph_property(p::PropertyStore, name::AbstractString) = p.gmaps[name]
graph_property(p::PropertyStore) = p.gmaps


### EDGE
function add_edge_property!(p::PropertyStore, name::AbstractString, emap::AEdgeMap)
    haskey(p.emaps, name) && error("Property $name already present.")
    p.emaps[name] = emap
end

function rem_edge_property!(p::PropertyStore, name::AbstractString)
    !haskey(p.emaps, name) && error("Property $name not present.")
    delete!(p.emaps, name)
    p.emaps
end

edge_property(p::PropertyStore, name::AbstractString) = p.emaps[name]

edge_property(p::PropertyStore) = p.emaps

function edge_property(p::PropertyStore, e::AEdge)
    pe = Dict{String, Any}()
    for (name, em) in edge_property(p)
        if haskey(em, e)
            pe[name] = em[e]
        end
    end
    return pe
end

## VERTEX
function add_vertex_property!(p::PropertyStore, name::AbstractString, vmap::AVertexMap)
    haskey(p.vmaps, name) && error("Property $name already present.")
    p.vmaps[name] = vmap
end
function rem_vertex_property!(p::PropertyStore, name::AbstractString)
    !haskey(p.vmaps, name) && error("Property $name not present.")
    delete!(p.vmaps, name)
    p.vmaps
end

vertex_property(p::PropertyStore, name::AbstractString) = p.vmaps[name]
vertex_property(p::PropertyStore) = p.vmaps

function vertex_property(p::PropertyStore, i::Integer)
    pi = Dict{String, Any}()
    for (name, vm) in vertex_property(p)
        if haskey(vm, i)
            pi[name] = vm[i]
        end
    end
    return pi
end

###

function swap_vertices!(props::PropertyStore, u::Integer, v::Integer)
    for vmap in values(props.vmaps)
        hasu, hasv = haskey(vmap, u), haskey(vmap, v)
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

has_graph_property(props::PropertyStore, name::AbstractString) = haskey(props.gmaps, name)
has_vertex_property(props::PropertyStore, name::AbstractString) = haskey(props.vmaps, name)
has_vertex_property(props::PropertyStore, name::AbstractString, v::Integer) =
            haskey(props.vmaps, name) && haskey(props.vmaps[name], v)

has_edge_property(props::PropertyStore, name::AbstractString) = haskey(props.emaps, name)
has_edge_property(props::PropertyStore, name::AbstractString, e::AEdge) =
            haskey(props.emaps, name) && haskey(props.emaps[name], e)


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
