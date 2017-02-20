"""
    const AVertexMap{V,T} = Union{AbstractVector{T}, Dict{V,T}}

Type representing an abstract vertex map.
"""
const AVertexMap{V,T} = Union{AbstractVector{T}, Dict{V,T}}

"""
    hasindex(v, i::Integer)

Check if collection `v` is indexable by `i`
"""
hasindex(v::AbstractVector, i::Integer) = 0 <= i <= length(v)
hasindex(v::Dict, i::Integer) = haskey(v, i)

"""
    VertexMap{T}(g, ::Type{T})

Returns a map that associates values of type `T`
to the vertices of  graph `g`.
"""
function VertexMap{T}(g::ASimpleGraph, ::Type{T})
    V = vertextype(g)
    return Dict{V,T}()
end

"""
    struct ConstVertexMap{T} <: AbstractVector{T}
        val::T
    end

A type representing a constant vector map.
Any attempt to change the internal value, e.g. `vm[1] = 4`, will
fail silently.
"""
struct ConstVertexMap{T} <: AbstractVector{T}
    val::T
end

length(d::ConstVertexMap) = typemax(Int)
getindex(d::ConstVertexMap, i::Integer) = d.val
setindex!(d::ConstVertexMap, x, i::Integer) = nothing
get(d::ConstVertexMap, i::Integer, x) = d.val
size(d::ConstVertexMap) = (typemax(Int),)
hasindex(v::ConstVertexMap, i::Integer) = true
