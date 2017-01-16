abstract SimpleEdgeMap{T}

typealias AEdgeMap{E,T} Union{Associative{E,T}, SimpleEdgeMap{T}}

"""
    immutable ConstEdgeMap{T} <: SimpleEdgeMap{T}
        val::T
    end

A type representing a constant vector map.
Any attempt to change the internal value, e.g. `vm[1] = 4`, will
fail silently.
"""
immutable ConstEdgeMap{T} <: SimpleEdgeMap{T}
    val::T
end

length(d::ConstEdgeMap) = typemax(Int)
getindex(d::ConstEdgeMap, e::AEdge) = d.val
setindex!(d::ConstEdgeMap, x, e::AEdge) = nothing
get(d::ConstEdgeMap, e::AEdge, x) = d.val
size(d::ConstEdgeMap) = (typemax(Int),)
hasindex(v::ConstEdgeMap, e::AEdge) = true
