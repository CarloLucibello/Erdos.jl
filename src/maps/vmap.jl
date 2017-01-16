typealias AVertexMap{T,V} Union{AbstractVector{T}, Dict{V,T}}

hasindex(v::AbstractVector, i::Integer) = 0 <= i <= length(v)
hasindex(v::Dict, i::Integer) = haskey(v, i)

function VMap{T}(g::ASimpleGraph, ::Type{T})
    V = vertextype(g)
    return Dict{V,T}()
end

immutable ConstVMap{T} <: AbstractVector{T}
    v::T
end

length(d::ConstVMap, i) = typemax(Int)
getindex(d::ConstVMap, i) = d.v
setindex!(d::ConstVMap, x, i) = nothing
get(d::ConstVMap, i, x) = d.v
