# abstract SimpleEdgeMap{T}

typealias AEdgeMap{E,T} Associative{E, T}

type EdgeMap{E,T,D} <: AEdgeMap{E,T}
    data::D

    etype::Type{E}
    vtype::Type{T}
end

EdgeMap{T}(g::ASimpleGraph, d::AbstractMatrix{T}) = EdgeMap(d, edgetype(g), T)
length(m::EdgeMap) = length(m.data)

getindex{E,T,D<:AbstractMatrix}(m::EdgeMap{E,T,D}, e::AEdge) =
    getindex(m.data, src(e), dst(e))
setindex!{E,T,D<:AbstractMatrix}(m::EdgeMap{E,T,D}, x, e::AEdge) =
    setindex!(m.data, x, src(e), dst(e))
get{E,T,D<:AbstractMatrix}(m::EdgeMap{E,T,D}, e::AEdge, x) =
    get(m.data, (src(e), dst(e)), x)

# matrix interface
getindex{E,T,D<:AbstractMatrix}(m::EdgeMap{E,T,D}, i::Integer, j::Integer) =
    getindex(m.data, i, j)
setindex!{E,T,D<:AbstractMatrix}(m::EdgeMap{E,T,D}, x, i::Integer, j::Integer) =
    setindex!(m.data, x, i, j)


"""
    immutable ConstEdgeMap{T} <: SimpleEdgeMap{T}
        val::T
    end

A type representing a constant vector map.
Any attempt to change the internal value, e.g. `vm[1] = 4`, will
fail silently.
"""
immutable ConstEdgeMap{E,T} <: AEdgeMap{E,T}
    val::T
    etype::Type{E}
end

ConstEdgeMap(g::ASimpleGraph, x) = ConstEdgeMap(x, edgetype(g))

length(m::ConstEdgeMap) = typemax(Int)
getindex(m::ConstEdgeMap, e::AEdge) = m.val
setindex!(m::ConstEdgeMap, x, i::Integer, j::Integer) = nothing
getindex(m::ConstEdgeMap, i::Integer, j::Integer) = m.val
setindex!(m::ConstEdgeMap, x, e::AEdge) = nothing
get(m::ConstEdgeMap, e::AEdge, x) = m.val
size(m::ConstEdgeMap) = (typemax(Int),)
