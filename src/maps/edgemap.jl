"""
    AEdgeMap{T}

Type representing an abstract vertex map.
"""
@compat abstract type AEdgeMap{T} end

valtype{T}(m::AEdgeMap{T}) = T

"""
    type EdgeMap{G <: ASimpleGraph, T, D} <: AEdgeMap{T}
        g::G
        vtype::Type{T}
        data::D
    end

Type implementing an edge map. The underlying container `data` can be a dictionary,
a matrix or a vector (for graphs with indexed edges).

    EdgeMap{T}(g, ::Type{T})

Returns a map that associates values of type `T`
to the vertices of  graph `g`. The underlying storage structures is chosen
accordingly.
"""
type EdgeMap{G<:ASimpleGraph, T, D} <: AEdgeMap{T}
    g::G
    vtype::Type{T}
    data::D
end
show{G,T,D}(io::IO, m::EdgeMap{G,T,D}) = print(io, "EdgeMap{$T} -> $(m.data)")

EdgeMap{T}(g::ASimpleGraph, d::AbstractMatrix{T}) = EdgeMap(g, T, d)
EdgeMap{T}(g::ASimpleGraph, d::AbstractVector{T}) = EdgeMap(g, T, d)

function EdgeMap{T}(g::ASimpleGraph, ::Type{T})
    V = vertextype(g)
    E = Edge{V}
    return EdgeMap(g, T, Dict{E,T}())
end

length(m::EdgeMap) = length(m.data)

### MATRIX DATA
# Associative interface
getindex{G,T,D<:AbstractMatrix}(m::EdgeMap{G,T,D}, e::AEdge) =
    getindex(m.data, src(e), dst(e))
setindex!{G,T,D<:AbstractMatrix}(m::EdgeMap{G,T,D}, x, e::AEdge) =
    setindex!(m.data, x, src(e), dst(e))
get{G,T,D<:AbstractMatrix}(m::EdgeMap{G,T,D}, e::AEdge, x) =
    get(m.data, (src(e), dst(e)), x)

# matrix interface
getindex{G,T,D<:AbstractMatrix}(m::EdgeMap{G,T,D}, i::Integer, j::Integer) =
    getindex(m.data, i, j)
setindex!{G,T,D<:AbstractMatrix}(m::EdgeMap{G,T,D}, x, i::Integer, j::Integer) =
    setindex!(m.data, x, i, j)

### VECTOR DATA
# vector interface
getindex{G,T,D<:AbstractVector}(m::EdgeMap{G,T,D}, e::AIndexedEdge) =
    getindex(m, idx(e))

setindex!{G,T,D<:AbstractVector}(m::EdgeMap{G,T,D}, x, e::AIndexedEdge) =
    setindex!(m.data, x, idx(e))

getindex{G,T,D<:AbstractVector}(m::EdgeMap{G,T,D}, idx::Integer) =
    getindex(m.data, idx)
setindex!{G,T,D<:AbstractVector}(m::EdgeMap{G,T,D}, x, idx::Integer) =
    setindex!(m.data, x, idx)

### Dict{Edge{V},T} DATA
# Associative interface
getindex{G,T,V}(m::EdgeMap{G,T,Dict{Edge{V},T}}, e::Edge{V}) =
    getindex(m.data, e)
setindex!{G,T,V}(m::EdgeMap{G,T,Dict{Edge{V},T}}, x, e::Edge{V}) =
    setindex!(m.data, x, e)
get{G,T,V}(m::EdgeMap{G,T,Dict{Edge{V},T}}, e::Edge{V}, x) =
    get(m.data, e, x)

getindex{G,T,V}(m::EdgeMap{G,T,Dict{Edge{V},T}}, e::AEdge) =
    getindex(m.data, Edge{V}(src(e), dst(e)))
setindex!{G,T,V}(m::EdgeMap{G,T,Dict{Edge{V},T}}, x, e::AEdge) =
    setindex!(m.data, x, Edge{V}(src(e), dst(e)))
get{G,T,V}(m::EdgeMap{G,T,Dict{Edge{V},T}}, e::AEdge, x) =
    get(m.data, Edge{V}(src(e), dst(e)), x)

# matrix interface
getindex{G,T,V}(m::EdgeMap{G,T,Dict{Edge{V},T}}, i::Integer, j::Integer) =
    getindex(m.data, Edge{V}(i, j))
setindex!{G,T,V}(m::EdgeMap{G,T,Dict{Edge{V},T}}, x, i::Integer, j::Integer) =
    setindex!(m.data, x, Edge{V}(i, j))

####
values{G,T,D<:Dict}(m::EdgeMap{G,T,D}) = values(m.data)
values{G,T,D<:Matrix}(m::EdgeMap{G,T,D}) = m.data
values{G,T,D<:AbstractSparseMatrix}(m::EdgeMap{G,T,D}) = nonzeros(m.data)

###
"""
    immutable ConstEdgeMap{T} <: SimpleEdgeMap{T}
        val::T
    end

A type representing a constant vector map.
Any attempt to change the internal value, e.g. `emap[u,v] = 4`, will
fail silently.
"""
immutable ConstEdgeMap{T} <: AEdgeMap{T}
    val::T
end

ConstEdgeMap(g::ASimpleGraph, x) = ConstEdgeMap(x)

length(m::ConstEdgeMap) = typemax(Int)
getindex(m::ConstEdgeMap, e::AEdge) = m.val
setindex!(m::ConstEdgeMap, x, i::Integer, j::Integer) = nothing
getindex(m::ConstEdgeMap, i::Integer, j::Integer) = m.val
setindex!(m::ConstEdgeMap, x, e::AEdge) = nothing
get(m::ConstEdgeMap, e::AEdge, x) = m.val
size(m::ConstEdgeMap) = (typemax(Int),)

values(m::ConstEdgeMap) = [m.val]
