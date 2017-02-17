"""
    AEdgeMap{E,T}

Type representing an abstract vertex map.
"""
abstract AEdgeMap{E,T}

valtype{E,T}(m::AEdgeMap{E,T}) = T

"""
    type EdgeMap{E,T,D} <: AEdgeMap{E,T}
        data::D
        etype::Type{E}
        vtype::Type{T}
    end

Type implementing an edge map. The underlying container `data` can be a `Dict`
or an `AbstractMatrix`.
"""
type EdgeMap{E,T,D} <: AEdgeMap{E,T}
    data::D
    etype::Type{E}
    vtype::Type{T}
end
show{E,T}(io::IO, m::EdgeMap{E,T}) = print(io, "EdgeMap{$T} -> $(m.data)")

EdgeMap{T}(g::ASimpleGraph, d::AbstractMatrix{T}) = EdgeMap(d, edgetype(g), T)


"""
    EdgeMap{T}(g, ::Type{T})

Returns a map that associates values of type `T`
to the vertices of  graph `g`.
"""
function EdgeMap{T}(g::ASimpleGraph, ::Type{T})
    V = vertextype(g)
    E = Edge{V}
    return EdgeMap(Dict{E,T}(), E, T)
end

length(m::EdgeMap) = length(m.data)

### MATRIX DATA
# Associative interface
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

### Dict{Edge{V},T} DATA
# Associative interface
getindex{E,T,V}(m::EdgeMap{E,T,Dict{Edge{V},T}}, e::Edge{V}) =
    getindex(m.data, e)
setindex!{E,T,V}(m::EdgeMap{E,T,Dict{Edge{V},T}}, x, e::Edge{V}) =
    setindex!(m.data, x, e)
get{E,T,V}(m::EdgeMap{E,T,Dict{Edge{V},T}}, e::Edge{V}, x) =
    get(m.data, e, x)

getindex{E,T,V}(m::EdgeMap{E,T,Dict{Edge{V},T}}, e::AEdge) =
    getindex(m.data, Edge{V}(src(e), dst(e)))
setindex!{E,T,V}(m::EdgeMap{E,T,Dict{Edge{V},T}}, x, e::AEdge) =
    setindex!(m.data, x, Edge{V}(src(e), dst(e)))
get{E,T,V}(m::EdgeMap{E,T,Dict{Edge{V},T}}, e::AEdge, x) =
    get(m.data, Edge{V}(src(e), dst(e)), x)

# matrix interface
getindex{E,T,V}(m::EdgeMap{E,T,Dict{Edge{V},T}}, i::Integer, j::Integer) =
    getindex(m.data, Edge{V}(i, j))
setindex!{E,T,V}(m::EdgeMap{E,T,Dict{Edge{V},T}}, x, i::Integer, j::Integer) =
    setindex!(m.data, x, Edge{V}(i, j))

####
values{E,T,D<:Dict}(m::EdgeMap{E,T,D}) = values(m.data)
values{E,T,D<:Matrix}(m::EdgeMap{E,T,D}) = m.data
values{E,T,D<:AbstractSparseMatrix}(m::EdgeMap{E,T,D}) = nonzeros(m.data)

###
"""
    immutable ConstEdgeMap{T} <: SimpleEdgeMap{T}
        val::T
    end

A type representing a constant vector map.
Any attempt to change the internal value, e.g. `emap[u,v] = 4`, will
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

values(m::ConstEdgeMap) = [m.val]
