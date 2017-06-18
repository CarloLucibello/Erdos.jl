# AVertexMap{T} defined in newtwork_interface.jl
valtype{T}(m::AVertexMap{T}) = T

"""
    type VertexMap{G <: AGraphOrDiGraph, T, D} <: AVertexMap{T}
        g::G
        vtype::Type{T}
        data::D
    end

Type implementing an edge map. The underlying container `data` can be a
dictionary or a vector.

    VertexMap{T}(g, ::Type{T})

Returns a map that associates values of type `T`
to the vertices of  graph `g`. The underlying storage structures is chosen
accordingly.

    VertexMap(g, data)

Construct a VertexMap with `data` as underlying storage.

    VertexMap(g, f)

Construct a vertex map with value `f(u)` for each `u=1:nv(g)`.
"""
type VertexMap{G<:AGraphOrDiGraph, T, D} <: AVertexMap{T}
    g::G
    vtype::Type{T}
    data::D
end
show{G,T,D}(io::IO, m::VertexMap{G,T,D}) = print(io, "VertexMap: $(m.data)")

VertexMap{T}(g::AGraphOrDiGraph, d::AbstractVector{T}) = VertexMap(g, T, d)
VertexMap{T}(g::AGraphOrDiGraph, d::Dict{Int, T}) = VertexMap(g, T, d)

function VertexMap{T}(g::AGraphOrDiGraph, ::Type{T})
    V = vertextype(g)
    return VertexMap(g, T, Dict{Int,T}())
end

function VertexMap(g::AGraphOrDiGraph, f::Function)
    V = vertextype(g)
    T = Base.return_types(f, (V,))[1]
    data = T[f(i) for i=1:nv(g)]
    return VertexMap(g, T, data)
end


length(m::VertexMap) = length(m.data)
getindex(m::VertexMap, i::Integer) = getindex(m.data, i)
setindex!(m::VertexMap, x, i::Integer) = setindex!(m.data, x, i)
haskey{G,T,D<:AbstractVector}(m::VertexMap{G,T,D}, i::Integer) =
    1 <= i <= length(m)
haskey{G,T,D<:Dict}(m::VertexMap{G,T,D}, i::Integer) =
    haskey(m.data, i)
get(m::VertexMap, i::Integer, x) = get(m.data, i, x)

==(m1::VertexMap, m2::VertexMap) = m1.data == m2.data

Base.Vector(vmap::VertexMap) = [vmap[i] for i=1:nv(vmap.g)]

"""
    immutable ConstVertexMap{T} <: AVertexMap{T}
        val::T
    end

A type representing a constant vector map.
Any attempt to change the internal value, e.g. `vm[1] = 4`, will
fail silently.
"""
immutable ConstVertexMap{T} <: AVertexMap{T}
    val::T
end

length(d::ConstVertexMap) = typemax(Int)
getindex(d::ConstVertexMap, i::Integer) = d.val
setindex!(d::ConstVertexMap, x, i::Integer) = nothing
get(d::ConstVertexMap, i::Integer, x) = d.val
haskey(v::ConstVertexMap, i::Integer) = true
