"""
    type EdgeMap{G <: AGraphOrDiGraph, T, D} <: AEdgeMap{T}
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
type EdgeMap{G<:AGraphOrDiGraph, T, D} <: AEdgeMap{T}
    g::G
    vtype::Type{T}
    data::D
end
show{G,T,D}(io::IO, m::EdgeMap{G,T,D}) = print(io, "EdgeMap{$T}:$(m.data)")

EdgeMap{T}(g::AGraphOrDiGraph, d::AbstractMatrix{T}) = EdgeMap(g, T, d)
EdgeMap{T}(g::AGraphOrDiGraph, d::AbstractVector{T}) = EdgeMap(g, T, d)
EdgeMap{T}(g::AGraphOrDiGraph, d::Dict{Int, T}) = EdgeMap(g, T, d)

function EdgeMap{T}(g::AGraphOrDiGraph, ::Type{T})
    E = edgetype(g)
    if E <: AIndexedEdge
        return EdgeMap(g, T, Dict{Int,T}())
    else
        return EdgeMap(g, T, Dict{E,T}())
    end
end

length(m::EdgeMap) = length(m.data)

### ALL DATA
# matrix interface
getindex(m::EdgeMap, i::Integer, j::Integer) = getindex(m, edge(m.g, i, j))
setindex!(m::EdgeMap, x, i::Integer, j::Integer) = setindex!(m, x, edge(m.g, i, j))

### MATRIX DATA
# Associative interface
getindex{G<:AGraphOrDiGraph,T,D<:AbstractMatrix}(m::EdgeMap{G,T,D}, e::AEdge) =
    getindex(m.data, src(e), dst(e))
setindex!{G<:AGraphOrDiGraph,T,D<:AbstractMatrix}(m::EdgeMap{G,T,D}, x, e::AEdge) =
    setindex!(m.data, x, src(e), dst(e))
get{G<:AGraphOrDiGraph,T,D<:AbstractMatrix}(m::EdgeMap{G,T,D}, e::AEdge, x) =
    get(m.data, (src(e), dst(e)), x)

# matrix interface
getindex{G<:AGraphOrDiGraph,T,D<:AbstractMatrix}(m::EdgeMap{G,T,D}, i::Integer, j::Integer) =
    getindex(m.data, i, j)
setindex!{G<:AGraphOrDiGraph,T,D<:AbstractMatrix}(m::EdgeMap{G,T,D}, x, i::Integer, j::Integer) =
    setindex!(m.data, x, i, j)

### VECTOR DATA (only indexed edges)
# Associative interface
getindex{G<:AGraphOrDiGraph,T,D<:AbstractVector}(m::EdgeMap{G,T,D}, e::AIndexedEdge) =
    getindex(m.data, idx(e))

setindex!{G<:AGraphOrDiGraph,T,D<:AbstractVector}(m::EdgeMap{G,T,D}, x, e::AIndexedEdge) =
    setindex!(m.data, x, idx(e))

# TODO allow one dimensional indexing?
# it can be bugprone
getindex{G<:AGraphOrDiGraph,T,D<:AbstractVector}(m::EdgeMap{G,T,D}, idx::Integer) =
    getindex(m.data, idx)
setindex!{G<:AGraphOrDiGraph,T,D<:AbstractVector}(m::EdgeMap{G,T,D}, x, idx::Integer) =
    setindex!(m.data, x, idx)

### Dict{Int,T} DATA
# Associative interface
getindex{G<:AGraphOrDiGraph,T}(m::EdgeMap{G,T,Dict{Int,T}}, e::AIndexedEdge) = getindex(m.data, idx(e))
setindex!{G<:AGraphOrDiGraph,T}(m::EdgeMap{G,T,Dict{Int,T}}, x, e::AIndexedEdge) = setindex!(m.data, x, idx(e))
get{G<:AGraphOrDiGraph,T}(m::EdgeMap{G,T,Dict{Int,T}}, e::AIndexedEdge, x) = get(m.data, idx(e), x)

### Dict{E,T} DATA
# Associative interface
getindex{G<:AGraphOrDiGraph,T,E}(m::EdgeMap{G,T,Dict{E,T}}, e::E) = getindex(m.data, e)
setindex!{G<:AGraphOrDiGraph,T,E}(m::EdgeMap{G,T,Dict{E,T}}, x, e::E) = setindex!(m.data, x, e)
get{G,T,E}(m::EdgeMap{G,T,Dict{E,T}}, e::E, x) = get(m.data, e, x)


####
values{G,T,D<:Dict}(m::EdgeMap{G,T,D}) = values(m.data)
values{G,T,D<:Matrix}(m::EdgeMap{G,T,D}) = m.data
values{G,T,D<:AbstractSparseMatrix}(m::EdgeMap{G,T,D}) = nonzeros(m.data)

==(m1::EdgeMap, m2::EdgeMap) = m1.data == m2.data

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

ConstEdgeMap(g::AGraphOrDiGraph, x) = ConstEdgeMap(x)

length(m::ConstEdgeMap) = typemax(Int)
getindex(m::ConstEdgeMap, e::AEdge) = m.val

setindex!(m::ConstEdgeMap, x, i::Integer) = nothing
getindex(m::ConstEdgeMap, i::Integer) = m.val
setindex!(m::ConstEdgeMap, x, i::Integer, j::Integer) = nothing
getindex(m::ConstEdgeMap, i::Integer, j::Integer) = m.val
setindex!(m::ConstEdgeMap, x, e::AEdge) = nothing
get(m::ConstEdgeMap, e::AEdge, x) = m.val
size(m::ConstEdgeMap) = (typemax(Int),)

values(m::ConstEdgeMap) = [m.val]
