
"""
    mutable struct Graph{T<:Integer} <: AGraph
        ne::Int
        fadjlist::Vector{Vector{T}}
    end

A simple graph type based on an adjacency list.

The constructors

    Graph{T}(n=0)
    Graph(n=0) = Graph{Int}(n)

return a `Graph` with `n` vertices and no edges.


    Graph{T}(adjmx::AbstractMatrix; upper=false, selfedges=true)

Construct a `Graph{T}` from the adjacency matrix `adjmx`, placing an edge in
correspondence to each nonzero element of `adjmx`.
If `selfedges=false` the diagonal elements of `adjmx` are ignored.
If `upper=true` only the upper triangular part of `adjmx` is considered.
"""
mutable struct Graph{T<:Integer} <: AGraph
    ne::Int
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)
                                # fadjlist is sorted
end

function Graph{T}(n::Integer = 0) where T<:Integer
    fadjlist = [Vector{T}() for _=1:n]
    return Graph{T}(0, fadjlist)
end

Graph{T}(n::Integer, m::Integer; seed = -1) where {T<:Integer} =
    erdos_renyi(n, m, Graph{T}; seed=seed)
Graph(n::T, m::T; kws...) where {T<:Integer} = Graph{T}(n, m; kws...)
Graph(n::T) where {T<:Integer} = Graph{T}(n)
Graph(g::AGraph) = Graph{Int}(g)
Graph() = Graph{Int}()

"""
    mutable struct DiGraph{T<:Integer} <: ADiGraph
        ne::Int
        fadjlist::Vector{Vector{T}}
        badjlist::Vector{Vector{T}}
    end

A simple digraph type based on two adjacency lists (forward and backward).

    DiGraph{T}(n=0)
    DiGraph(n=0) = DiGraph{Int}(n)

Construct a `DiGraph` with `n` vertices and no edges.

    DiGraph{T}(adjmx::AbstractMatrix; selfedges=true)

Construct a `DiGraph{T}` from the adjacency matrix `adjmx`, placing an edge in
correspondence to each nonzero element of `adjmx`.
If `selfedges=false` the diagonal elements of `adjmx` are ignored.
"""
mutable struct DiGraph{T<:Integer} <: ADiGraph
    ne
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{T}} # [dst]: (src, src, src)
                                # fadjlist and badjlist are sorted
end

function DiGraph{T}(n::Integer = 0) where T<:Integer
    fadjlist = [Vector{T}() for _=1:n]
    badjlist = [Vector{T}() for _=1:n]
    return DiGraph{T}(0, fadjlist, badjlist)
end

DiGraph{T}(n::Integer, m::Integer; seed = -1) where {T<:Integer} =
    erdos_renyi(n, m, DiGraph{T}; seed=seed)
DiGraph(n::T, m::T; kws...) where {T<:Integer} = DiGraph{T}(n, m; kws...)
DiGraph(n::T) where {T<:Integer} = DiGraph{T}(n)
DiGraph() = DiGraph{Int}()
DiGraph(g::ADiGraph) = DiGraph{Int}(g)

const GraphOrDiGraph{T} = Union{Graph{T}, DiGraph{T}}

edgetype(::Type{DiGraph{T}}) where {T} = Edge{T}
edgetype(::Type{Graph{T}}) where {T} = Edge{T}
graphtype(::Type{DiGraph{T}}) where {T} = Graph{T}
graphtype(::Type{DiGraph}) = Graph{Int}
graphtype(::Type{Graph}) = Graph{Int}
digraphtype(::Type{DiGraph}) = DiGraph{Int}
digraphtype(::Type{Graph}) = DiGraph{Int}
digraphtype(::Type{Graph{T}}) where {T} = DiGraph{T}
vertextype(::Type{Graph{T}}) where {T} = T
vertextype(::Type{DiGraph{T}}) where {T} = T

nv(g::GraphOrDiGraph{T}) where {T} = T(length(g.fadjlist))
ne(g::GraphOrDiGraph) = g.ne

pop_vertex!(g::Graph) = (clean_vertex!(g, nv(g)); pop!(g.fadjlist); nv(g)+1)
pop_vertex!(g::DiGraph) = (clean_vertex!(g, nv(g)); pop!(g.fadjlist); pop!(g.badjlist); nv(g)+1)

function add_edge!(g::Graph, s::Integer, d::Integer)
    E = edgetype(g)
    e = s <= d ? E(s, d) : E(d, s)
    (s in vertices(g) && d in vertices(g)) || return (false, e)
    inserted = _insert_and_dedup!(g.fadjlist[s], d)
    if inserted
        g.ne += 1
    end
    if s != d
        inserted = _insert_and_dedup!(g.fadjlist[d], s)
    end
    return (inserted, e)
end

function rem_edge!(g::Graph, u, v)
    i = searchsorted(g.fadjlist[u], v)
    length(i) > 0 || return false   # edge not in graph
    deleteat!(g.fadjlist[u], i[1])
    if u != v     # not a self loop
        i2 = searchsorted(g.fadjlist[v], u)[1]
        deleteat!(g.fadjlist[v], i2)
    end
    g.ne -= 1
    return true # edge successfully removed
end

function add_vertex!(g::Graph{T}) where T
    push!(g.fadjlist, Vector{T}())
    return nv(g)
end

function copy(g::DiGraph{T}) where T
    return DiGraph{T}(g.ne, deepcopy(g.fadjlist), deepcopy(g.badjlist))
end

function add_edge!(g::DiGraph, s::Integer, d::Integer)
    E = edgetype(g)
    e = E(s, d)
    (s in vertices(g) && d in vertices(g)) || return (false, e)
    inserted = _insert_and_dedup!(g.fadjlist[s], d)
    g.ne = ifelse(inserted, g.ne+1, g.ne)
    inserted && !_insert_and_dedup!(g.badjlist[d], s)
    return (inserted, e)
end

function rem_edge!(g::DiGraph, u, v)
    has_edge(g,u,v) || return false
    i = searchsorted(g.fadjlist[u],v)[1]
    deleteat!(g.fadjlist[u], i)
    i = searchsorted(g.badjlist[v], u)[1]
    deleteat!(g.badjlist[v], i)
    g.ne -= 1
    return true
end

function add_vertex!(g::DiGraph{T}) where T
    push!(g.badjlist, Vector{T}())
    push!(g.fadjlist, Vector{T}())
    return nv(g)
end

function reverse(g::DiGraph{T}) where T
    gnv = nv(g)
    gne = ne(g)
    h = DiGraph{T}(gnv)
    h.fadjlist = deepcopy(g.badjlist)
    h.badjlist = deepcopy(g.fadjlist)
    h.ne = gne

    return h
end

function reverse!(g::DiGraph)
    g.fadjlist, g.badjlist = g.badjlist, g.fadjlist
    return g
end


out_neighbors(g::GraphOrDiGraph,v) = g.fadjlist[v]
in_neighbors(g::DiGraph,v) = g.badjlist[v]

edge(g::DiGraph{T}, u, v) where {T} = Edge{T}(u, v)
edge(g::Graph{T}, u, v) where {T} = Edge{T}(u, v)
# edge(g::Graph, u, v) = u <= v ? Edge(u, v) : Edge(v, u)

#### fallbaks override #######

digraph(g::Graph{T}) where {T} = DiGraph{T}(2ne(g), deepcopy(g.fadjlist), deepcopy(g.fadjlist))

out_adjlist(g::GraphOrDiGraph) = g.fadjlist
in_adjlist(g::DiGraph) = g.badjlist

==(g::G, h::G) where {G<:GraphOrDiGraph} = nv(g) == nv(h) &&
                ne(g) == ne(h) && g.fadjlist == h.fadjlist

function has_edge(g::Graph, u, v)
    (u > nv(g) || v > nv(g)) && return false
    if degree(g, u) > degree(g, v)
        u, v = v, u
    end
    return length(searchsorted(neighbors(g,u), v)) > 0
end

function has_edge(g::DiGraph, u, v)
    (u > nv(g) || v > nv(g)) && return false
    if out_degree(g,u) < in_degree(g,v)
        return length(searchsorted(out_neighbors(g,u), v)) > 0
    else
        return length(searchsorted(in_neighbors(g,v), u)) > 0
    end
end

# UNSAFE METHODS

function unsafe_add_edge!(g::Graph, s, d)
    push!(g.fadjlist[s], d)
    s != d && push!(g.fadjlist[d], s)
    g.ne += 1
end

#TODO should check for duplicate edges.
## sort!(union!(x)) ??
# shold verify i~j  => j~i
function rebuild!(g::Graph)
    for neigs in g.fadjlist
        sort!(neigs)
    end
end

function unsafe_add_edge!(g::DiGraph, s, d)
    push!(g.fadjlist[s], d)
    push!(g.badjlist[d], s)
    g.ne += 1
end

function rebuild!(g::DiGraph)
    for neigs in g.fadjlist
        sort!(neigs)
    end
    for neigs in g.badjlist
        sort!(neigs)
    end
end

function swap_vertices!(g::Graph, u::Integer, v::Integer)
    if u != v
        #TODO copying to avoid problems with self edges
        # maybe can copy only one of the two
        neigu = deepcopy(g.fadjlist[u])
        neigv = deepcopy(g.fadjlist[v])

        for j in neigu
            adj = g.fadjlist[j]
            kj = searchsortedfirst(adj, u)
            adj[kj] = v
            sort!(adj)
        end
        for j in neigv
            adj = g.fadjlist[j]
            kj = searchsortedfirst(adj, v)
            adj[kj] = u
            sort!(adj)
        end

        g.fadjlist[u], g.fadjlist[v] = g.fadjlist[v], g.fadjlist[u]
    end
end

function swap_vertices!(g::DiGraph, u::Integer, v::Integer)
    if u != v
        #TODO copying to avoid problems with self edges
        # maybe can copy only one of the two
        neigu = deepcopy(g.fadjlist[u])
        neigv = deepcopy(g.fadjlist[v])
        neiguin = deepcopy(g.badjlist[u])
        neigvin = deepcopy(g.badjlist[v])

        for j in neigu
            adj = g.badjlist[j]
            kj = searchsortedfirst(adj, u)
            adj[kj] = v
            sort!(adj)
        end

        for j in neigv
            adj = g.badjlist[j]
            kj = searchsortedfirst(adj, v)
            adj[kj] = u
            sort!(adj)
        end

        for j in neiguin
            adj = g.fadjlist[j]
            kj = searchsortedfirst(adj, u)
            adj[kj] = v
            sort!(adj)
        end

        for j in neigvin
            adj = g.fadjlist[j]
            kj = searchsortedfirst(adj, v)
            adj[kj] = u
            sort!(adj)
        end

        g.fadjlist[u], g.fadjlist[v] = g.fadjlist[v], g.fadjlist[u]
        g.badjlist[u], g.badjlist[v] = g.badjlist[v], g.badjlist[u]
    end
end
