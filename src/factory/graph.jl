
"""
    type Graph <: AGraph
        ne
        fadjlist::Vector{Vector{Int}}
    end

A simple graph type based on an adjacency list.


    Graph(n=0)

Construct an empty Graph with `n` vertices.

    Graph(adjmx::AbstractMatrix)

Construct a `Graph` from the adjacency matrix `adjmx`.
"""
type Graph{T<:Integer} <: AGraph
    ne::Int
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)

    function Graph(n = 0)
        fadjlist = [Vector{T}() for _=1:n]
        return new(0, fadjlist)
    end

    Graph(ne, fadj::Vector{Vector{T}}) = new(Int(ne), fadj)

    Graph(n, m; seed = -1) = erdos_renyi(n, m, Graph{T}; seed=seed)

    function Graph{S}(adjmx::AbstractMatrix{S})
        dima,dimb = size(adjmx)
        isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

        g = Graph{T}(dima)
        for i in find(adjmx)
            ind = ind2sub((dima,dimb), i)
            add_edge!(g, ind...)
        end
        return g
    end
end

Graph{T}(n::T, m::T; kws...) = Graph{T}(n, m; kws...)
Graph{T}(n::T) = Graph{T}(n)
Graph(adjmx::AbstractMatrix) = Graph{Int}(adjmx)
Graph() = Graph{Int}()


"""
    type DiGraph <: ADiGraph
        ne
        fadjlist::Vector{Vector{Int}}
        badjlist::Vector{Vector{Int}}
    end

A simple digraph type based on two adjacency lists (forward and backward).


    DiGraph(n=0)

Construct an empty DiGraph with `n` vertices.

    DiGraph{T<:Real}(adjmx::AbstractMatrix{T})

Construct a `DiGraph` from the adjacency matrix `adjmx`.
"""
type DiGraph{T<:Integer} <: ADiGraph
    ne
    fadjlist::Vector{Vector{T}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{T}} # [dst]: (src, src, src)

    function DiGraph(n=0)
        fadjlist = [Vector{T}() for _=1:n]
        badjlist = [Vector{T}() for _=1:n]
        return new(0, badjlist, fadjlist)
    end

    DiGraph(ne, fadj::Vector{Vector{T}}, badj::Vector{Vector{T}}) = new(ne, fadj, badj)
    DiGraph(nv, ne; seed = -1) = erdos_renyi(nv, ne, DiGraph{T}, seed=seed)

    function DiGraph{S}(adjmx::AbstractMatrix{S})
        dima,dimb = size(adjmx)
        isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

        g = DiGraph{T}(dima)
        for i in find(adjmx)
            ind = ind2sub((dima,dimb),i)
            add_edge!(g,ind...)
        end
        return g
    end
end

DiGraph{T}(n::T, m::T; kws...) = DiGraph{T}(n, m; kws...)
DiGraph{T}(n::T) = DiGraph{T}(n)
DiGraph(adjmx::AbstractMatrix) = DiGraph{Int}(adjmx)
DiGraph() = DiGraph{Int}()

typealias SimpleGraph{T} Union{Graph{T}, DiGraph{T}}

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

function add_edge!(g::Graph, s, d)
    (s in vertices(g) && d in vertices(g)) || return false
    inserted = _insert_and_dedup!(g.fadjlist[s], d)
    if inserted
        g.ne += 1
    end
    if s != d
        inserted = _insert_and_dedup!(g.fadjlist[d], s)
    end
    return inserted
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

function add_edge!(g::DiGraph, s, d)
    (s in vertices(g) && d in vertices(g)) || return false
    inserted = _insert_and_dedup!(g.fadjlist[s], d)
    g.ne = ifelse(inserted, g.ne+1, g.ne)
    return inserted && _insert_and_dedup!(g.badjlist[d], s)
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
