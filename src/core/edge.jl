
show(io::IO, e::AEdge) = print(io, "$(src(e))=>$(dst(e))")

==(e1::AEdge, e2::AEdge) = (src(e1) == src(e2) && dst(e1) == dst(e2))

"""
    struct Edge
        src::Int
        dst::Int
    end

A type representing an edge between two vertices of a graph.
"""
struct Edge{T} <: AEdge
    src::T
    dst::T
end

Edge(::Type{G},u,v) where {G<:ADiGraph} = Edge(u,v)
Edge(::Type{G},u,v) where {G<:AGraph} =  v > u ? Edge(u,v) : Edge(v,u)

function Edge(u::T, v::S) where {T,S}
    V = promote_type(T,S)
    return Edge{V}(promote(u, v)...)
end

src(e::Edge) = e.src
dst(e::Edge) = e.dst
iterate(e::AEdge, i=0) = (i+=1; i>2 ? nothing : (getfield(e,i), i))   
reverse(e::Edge) = Edge(dst(e), src(e))

show(io::IO, e::AIndexedEdge) = print(io, "($(src(e))=>$(dst(e)), $(idx(e)))")

"""
    struct IndexedEdge <: AIndexedEdge
        src::Int
        dst::Int
        idx::Int
    end

An indexed edge type

    IndexedEdge(u, v) = IndexedEdge(u,v,-1)

Creates an edge with invalid index.
"""
struct IndexedEdge <: AIndexedEdge
    src::Int
    dst::Int
    idx::Int
end

IndexedEdge(u, v) = IndexedEdge(u,v,-1)

src(e::IndexedEdge) = e.src
dst(e::IndexedEdge) = e.dst
idx(e::IndexedEdge) = e.idx
reverse(e::IndexedEdge) = IndexedEdge(e.dst, e.src, e.idx)

Base.sort(e::AEdge) = src(e) <= dst(e) ? e : reverse(e)
