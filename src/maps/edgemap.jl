# AEdgeMap{T} defined in newtwork_sinterface.jl
valtype(m::AEdgeMap{T}) where {T} = T

"""
    mutable struct EdgeMap{G <: AGraphOrDiGraph, T, D} <: AEdgeMap{T}
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

    EdgeMap(g, data)

Construct a EdgeMap with `data` as underlying storage.
The storage type can be a matrix or an associative `edg => val` type or
a vector for graph with indexed edges.

    EdgeMap(g, f)

Construct an edge map with value `f(e)` for each `e` in `edges(g)`.
"""
mutable struct EdgeMap{G<:AGraphOrDiGraph, T, D} <: AEdgeMap{T}
    g::G
    vtype::Type{T}
    data::D
end

EdgeMap(g::AGraphOrDiGraph, d::AbstractMatrix{T}) where {T} = EdgeMap(g, T, d)
EdgeMap(g::AGraphOrDiGraph, d::AbstractVector{T}) where {T} = EdgeMap(g, T, d)
EdgeMap(g::AGraphOrDiGraph, d::Dict{Int, T}) where {T} = EdgeMap(g, T, d)
EdgeMap(g::AGraphOrDiGraph, d::Dict{E, T}) where {T,E<:AEdge} = EdgeMap(g, T, d)

function EdgeMap(g::AGraphOrDiGraph, ::Type{T}) where T
    E = edgetype(g)
    if E <: AIndexedEdge
        # data = Vector{T}(ne(g))
        data = Dict{Int,T}()
    else
        data = Dict{E,T}()
    end
    return EdgeMap(g, T, data)
end


function EdgeMap(g::AGraphOrDiGraph, f::Function)
    E = edgetype(g)
    if E <: AIndexedEdge
        data_ = [f(e) for e in edges(g)]
        # since edges(g) doesn't iterate according to index
        # have to permute after
        data = similar(data_)
        for (i, e) in enumerate(edges(g))
            data[idx(e)] = data_[i]
        end
        T = eltype(data)
    else
        data = Dict(e => f(e) for e in edges(g))
        T = valtype(data)
    end
    return EdgeMap(g, T, data)
end

length(m::EdgeMap) = length(m.data)

### ALL DATA
# matrix interface
getindex(m::EdgeMap, i::Integer, j::Integer) = getindex(m, edge(m.g, i, j))
setindex!(m::EdgeMap, x, i::Integer, j::Integer) = setindex!(m, x, edge(m.g, i, j))
haskey(m::EdgeMap, i::Integer, j::Integer) = haskey(m, edge(m.g, i, j))
size(m::EdgeMap) = (nv(m.g), nv(m.g))
size(m::EdgeMap, i::Integer)::Int = 1 <= i <= 2 ? nv(m.g) : error("wrong dimension")


### MATRIX DATA
_sort(i, j) = i <= j ? (i, j) : (j , i)
# Associative interface
getindex(m::EdgeMap{G,T,D}, e::AEdge) where {G<:AGraphOrDiGraph,T,D<:AbstractMatrix} =
    getindex(m, src(e), dst(e))
setindex!(m::EdgeMap{G,T,D}, x, e::AEdge) where {G<:AGraphOrDiGraph,T,D<:AbstractMatrix} =
    setindex!(m, x, src(e), dst(e))
get(m::EdgeMap{G,T,D}, e::AEdge, x) where {G<:AGraph,T,D<:AbstractMatrix} =
    get(m.data, _sort(Int(src(e)), Int(dst(e))), x)
get(m::EdgeMap{G,T,D}, e::AEdge, x) where {G<:ADiGraph,T,D<:AbstractMatrix} =
    get(m.data, (Int(src(e)), Int(dst(e))), x)
haskey(m::EdgeMap{G,T,D}, e::AEdge) where {G<:AGraphOrDiGraph,T,D<:AbstractMatrix} =
     haskey(m, src(e), dst(e))
haskey(m::EdgeMap{G,T,D}, i::Integer, j::Integer) where {G<:AGraphOrDiGraph,T,D<:AbstractMatrix} =
  (1 <= i <= size(m.data, 1)) && (1 <= j <= size(m.data, 1))

# matrix interface
getindex(m::EdgeMap{G,T,D}, i::Integer, j::Integer) where {G<:AGraph,T,D<:AbstractMatrix} =
    getindex(m.data, _sort(i, j)...)
getindex(m::EdgeMap{G,T,D}, i::Integer, j::Integer) where {G<:ADiGraph,T,D<:AbstractMatrix} =
    getindex(m.data, i, j)
setindex!(m::EdgeMap{G,T,D}, x, i::Integer, j::Integer) where {G<:AGraph,T,D<:AbstractMatrix} =
    setindex!(m.data, x, _sort(i, j)...)
setindex!(m::EdgeMap{G,T,D}, x, i::Integer, j::Integer) where {G<:ADiGraph,T,D<:AbstractMatrix} =
    setindex!(m.data, x, i, j)

### VECTOR DATA (only indexed edges)
# Associative interface
getindex(m::EdgeMap{G,T,D}, e::AIndexedEdge) where {G<:AGraphOrDiGraph,T,D<:AbstractVector} =
    getindex(m.data, idx(e))
setindex!(m::EdgeMap{G,T,D}, x, e::AIndexedEdge) where {G<:AGraphOrDiGraph,T,D<:AbstractVector} =
    setindex!(m.data, x, idx(e))
haskey(m::EdgeMap{G,T,D}, e::AIndexedEdge) where {G<:AGraphOrDiGraph,T,D<:AbstractVector} =
    1 <= idx(e) <= length(m.data)
get(m::EdgeMap{G,T,D}, e::AEdge, x) where {G<:AGraphOrDiGraph,T,D<:AbstractVector} =
    get(m.data, idx(e), x)

# TODO allow one dimensional indexing?
# it can be bugprone
# getindex{G<:AGraphOrDiGraph,T,D<:AbstractVector}(m::EdgeMap{G,T,D}, idx::Integer) =
#     getindex(m.data, idx)
# setindex!{G<:AGraphOrDiGraph,T,D<:AbstractVector}(m::EdgeMap{G,T,D}, x, idx::Integer) =
#     setindex!(m.data, x, idx)

### Dict{Int,T} DATA
# Associative interface
getindex(m::EdgeMap{G,T,Dict{Int,T}}, e::AIndexedEdge) where {G<:AGraphOrDiGraph,T} = getindex(m.data, idx(e))
setindex!(m::EdgeMap{G,T,Dict{Int,T}}, x, e::AIndexedEdge) where {G<:AGraphOrDiGraph,T} = setindex!(m.data, x, idx(e))
get(m::EdgeMap{G,T,Dict{Int,T}}, e::AIndexedEdge, x) where {G<:AGraphOrDiGraph,T} = get(m.data, idx(e), x)
haskey(m::EdgeMap{G,T,Dict{Int,T}}, e::AIndexedEdge) where {G<:AGraphOrDiGraph,T} = haskey(m.data, idx(e))

### Dict{E,T} DATA
# Associative interface
getindex(m::EdgeMap{G,T,Dict{E,T}}, e::E) where {G<:AGraphOrDiGraph,T,E<:AEdge} = getindex(m.data, e)
setindex!(m::EdgeMap{G,T,Dict{E,T}}, x, e::E) where {G<:AGraphOrDiGraph,T,E<:AEdge} = setindex!(m.data, x, e)
get(m::EdgeMap{G,T,Dict{E,T}}, e::E, x) where {G<:AGraphOrDiGraph,T,E<:AEdge} = get(m.data, e, x)
haskey(m::EdgeMap{G,T,Dict{E,T}}, e::E) where {G<:AGraphOrDiGraph,T,E<:AEdge} = haskey(m.data, e)

getindex(m::EdgeMap{G,T,Dict{E,T}}, e::AEdge) where {G<:AGraphOrDiGraph,T,E<:AEdge} = getindex(m.data, E(src(e),dst(e)))
setindex!(m::EdgeMap{G,T,Dict{E,T}}, x, e::AEdge) where {G<:AGraphOrDiGraph,T,E<:AEdge} = setindex!(m.data, x, E(src(e),dst(e)))
get(m::EdgeMap{G,T,Dict{E,T}}, e::AEdge, x) where {G<:AGraphOrDiGraph,T,E<:AEdge} = get(m.data, E(src(e),dst(e)), x)
haskey(m::EdgeMap{G,T,Dict{E,T}}, e::AEdge) where {G<:AGraphOrDiGraph,T,E<:AEdge} = haskey(m.data, E(src(e),dst(e)))
####
values(m::EdgeMap{G,T,D}) where {G,T,D<:Dict} = values(m.data)
values(m::EdgeMap{G,T,D}) where {G,T,D<:Array} = m.data
values(m::EdgeMap{G,T,D}) where {G,T,D<:AbstractSparseMatrix} = nonzeros(m.data)

==(m1::EdgeMap, m2::EdgeMap) = m1.data == m2.data

"""
    struct ConstEdgeMap{T} <: SimpleEdgeMap{T}
        val::T
    end

A type representing a constant vector map.
Any attempt to change the internal value, e.g. `emap[u,v] = 4`, will
fail silently.
"""
struct ConstEdgeMap{T} <: AEdgeMap{T}
    val::T
end

ConstEdgeMap(g::AGraphOrDiGraph, x) = ConstEdgeMap(x)

length(m::ConstEdgeMap) = typemax(Int)
getindex(m::ConstEdgeMap, e::AEdge) = m.val

setindex!(m::ConstEdgeMap, x, i::Integer, j::Integer) = nothing #TODO not throwin since it is used as
                                                                # a dummy map
# setindex!(m::ConstEdgeMap, x, i::Integer, j::Integer) = error("Cannot assign to ConstEdgeMap")
getindex(m::ConstEdgeMap, i::Integer, j::Integer) = m.val
setindex!(m::ConstEdgeMap, x, e::AEdge) = nothing
# setindex!(m::ConstEdgeMap, x, e::AEdge) = error("Cannot assign to ConstEdgeMap")
get(m::ConstEdgeMap, e::AEdge, x) = m.val

values(m::ConstEdgeMap) = [m.val]

"""
    edgemap2adjlist(emap)

Returns a vector of vectors containing the values of the edge map `emap` on graph `g`
following the same ordering of [`adjacency_list`](@ref)`(g)`.
"""
edgemap2adjlist(m::AEdgeMap) = [[m[e] for e in out_edges(m.g, i)] for i=1:nv(m.g)]

function Base.Matrix(emap::EdgeMap)
    g = emap.g
    M = zeros(valtype(emap), nv(g), nv(g))
    return fill_mat_from_map!(M, g, emap)
end

function sparse(emap::EdgeMap)
    g = emap.g
    M = spzeros(valtype(emap), nv(g), nv(g))
    return fill_mat_from_map!(M, g, emap)
end

function fill_mat_from_map!(M, g::ADiGraph, emap::AEdgeMap)
    for e in edges(g)
        u, v = src(e), dst(e)
        M[u,v] = emap[e]
    end
    return M
end

function fill_mat_from_map!(M, g::AGraph, emap::AEdgeMap)
    for e in edges(g)
        u, v = src(e), dst(e)
        M[u,v] = M[v,u] = emap[e]
    end
    return M
end
