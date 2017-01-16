typealias AVertexMap{T,V} Union{AbstractVector{T}, Dict{V,T}}

hasindex(v::AbstractVector, i::Integer) = 0 <= i <= length(v)
hasindex(v::Dict, i::Integer) = haskey(v, i)

function VertexMap{T}(g::ASimpleGraph, ::Type{T})
    V = vertextype(g)
    return Dict{V,T}()
end

immutable ConstVertexMap{T} <: AbstractVector{T}
    v::T
end

length(d::ConstVertexMap, i) = typemax(Int)
getindex(d::ConstVertexMap, i) = d.v
setindex!(d::ConstVertexMap, x, i) = nothing
get(d::ConstVertexMap, i, x) = d.v
