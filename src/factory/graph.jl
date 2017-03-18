
"""
    type Graph{T<:Integer} <: AGraph
        ne::Int
        fadjlist::Vector{Vector{T}}
    end

A simple graph type based on an adjacency list.

    Graph{T}(n=0)
    Graph(n=0) = Graph{Int}(n)

Construct a `Graph` with `n` vertices and no edges.

    Graph{T}(adjmx::AbstractMatrix)
    Graph(adjmx::AbstractMatrix) = Graph{Int}(adjmx)

Construct a `Graph{T}` from the adjacency matrix `adjmx`.
"""
type Graph{T<:Integer} <: AGraph
    ne::Int
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)
end

function (::Type{Graph{T}}){T<:Integer}(n::Integer = 0)
    fadjlist = [Vector{T}() for _=1:n]
    return Graph{T}(0, fadjlist)
end

(::Type{Graph{T}}){T<:Integer}(n::Integer, m::Integer; seed = -1) = erdos_renyi(n, m, Graph{T}; seed=seed)

function (::Type{Graph{T}}){T<:Integer}(adjmx::AbstractMatrix)
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = Graph{T}(dima)
    for i in find(adjmx)
        ind = ind2sub((dima,dimb), i)
        add_edge!(g, ind...)
    end
    return g
end

Graph{T<:Integer}(n::T, m::T; kws...) = Graph{T}(n, m; kws...)
Graph{T<:Integer}(n::T) = Graph{T}(n)
Graph(adjmx::AbstractMatrix) = Graph{Int}(adjmx)
Graph() = Graph{Int}()


"""
    type DiGraph{T<:Integer} <: ADiGraph
        ne::Int
        fadjlist::Vector{Vector{T}}
        badjlist::Vector{Vector{T}}
    end

A simple digraph type based on two adjacency lists (forward and backward).

    DiGraph{T}(n=0)
    DiGraph(n=0) = DiGraph{Int}(n)

Construct a `DiGraph` with `n` vertices and no edges.

    DiGraph{T}(adjmx::AbstractMatrix)
    DiGraph(adjmx::AbstractMatrix) = DiGraph{Int}(adjmx)

Construct a `DiGraph` from the adjacency matrix `adjmx`.
"""
type DiGraph{T<:Integer} <: ADiGraph
    ne
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{T}} # [dst]: (src, src, src)
end

function (::Type{DiGraph{T}}){T<:Integer}(n::Integer = 0)
    fadjlist = [Vector{T}() for _=1:n]
    badjlist = [Vector{T}() for _=1:n]
    return DiGraph{T}(0, fadjlist, badjlist)
end

(::Type{DiGraph{T}}){T<:Integer}(n::Integer, m::Integer; seed = -1) = erdos_renyi(n, m, DiGraph{T}; seed=seed)

function (::Type{DiGraph{T}}){T<:Integer}(adjmx::AbstractMatrix)
    dima, dimb = size(adjmx)
    dima == dimb || error("Adjacency / distance matrices must be square")

    g = DiGraph{T}(dima)
    for i in find(adjmx)
        ind = ind2sub((dima,dimb), i)
        add_edge!(g, ind...)
    end
    return g
end

DiGraph{T<:Integer}(n::T, m::T; kws...) = DiGraph{T}(n, m; kws...)
DiGraph{T<:Integer}(n::T) = DiGraph{T}(n)
DiGraph(adjmx::AbstractMatrix) = DiGraph{Int}(adjmx)
DiGraph() = Graph{Int}()


@compat const SimpleGraph{T} = Union{Graph{T}, DiGraph{T}}

edgetype{T}(::Type{DiGraph{T}}) = Edge{T}
edgetype{T}(::Type{Graph{T}}) = Edge{T}
graphtype{T}(::Type{DiGraph{T}}) = Graph{T}
graphtype(::Type{DiGraph}) = Graph{Int}
graphtype(::Type{Graph}) = Graph{Int}
digraphtype(::Type{DiGraph}) = DiGraph{Int}
digraphtype(::Type{Graph}) = DiGraph{Int}
digraphtype{T}(::Type{Graph{T}}) = DiGraph{T}
vertextype{T}(::Type{Graph{T}}) = T
vertextype{T}(::Type{DiGraph{T}}) = T

nv{T}(g::SimpleGraph{T}) = T(length(g.fadjlist))
ne(g::SimpleGraph) = g.ne

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

function add_vertex!{T}(g::Graph{T})
    push!(g.fadjlist, Vector{T}())
    return nv(g)
end

##### DIGRAPH CONSTRUCTORS  #############


function DiGraph{T<:Real}(adjmx::SparseMatrixCSC{T})
    dima, dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = DiGraph(dima)
    maxc = length(adjmx.colptr)
    for c = 1:(maxc-1)
        for rind = adjmx.colptr[c]:adjmx.colptr[c+1]-1
            isnz = (adjmx.nzval[rind] != zero(T))
            if isnz
                r = adjmx.rowval[rind]
                add_edge!(g,r,c)
            end
        end
    end
    return g
end


#########



function copy{T}(g::DiGraph{T})
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

function add_vertex!{T}(g::DiGraph{T})
    push!(g.badjlist, Vector{T}())
    push!(g.fadjlist, Vector{T}())
    return nv(g)
end

function reverse{T}(g::DiGraph{T})
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


out_neighbors(g::SimpleGraph,v) = g.fadjlist[v]
in_neighbors(g::DiGraph,v) = g.badjlist[v]

edge{T}(g::DiGraph{T}, u, v) = Edge{T}(u, v)
edge{T}(g::Graph{T}, u, v) = Edge{T}(u, v)
# edge(g::Graph, u, v) = u <= v ? Edge(u, v) : Edge(v, u)

#### fallbaks override #######

digraph{T}(g::Graph{T}) = DiGraph{T}(2ne(g), deepcopy(g.fadjlist), deepcopy(g.fadjlist))

out_adjlist(g::SimpleGraph) = g.fadjlist
in_adjlist(g::DiGraph) = g.badjlist

=={G<:SimpleGraph}(g::G, h::G) = nv(g) == nv(h) &&
                ne(g) == ne(h) && g.fadjlist == h.fadjlist

function has_edge(g::Graph, u, v)
    u > nv(g) || v > nv(g) && return false
    if degree(g, u) > degree(g, v)
        u, v = v, u
    end
    return length(searchsorted(neighbors(g,u), v)) > 0
end

function has_edge(g::DiGraph, u, v)
    u > nv(g) || v > nv(g) && return false
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
