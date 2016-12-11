"""
    type Graph <: AGraph
        ne::Int
        fadjlist::Vector{Vector{Int}}
    end

A simple graph type based on an adjacency list.


    Graph(n=0)

Construct an empty Graph with `n` vertices.

    Graph(adjmx::AbstractMatrix)

Construct a `Graph` from the adjacency matrix `adjmx`.
"""
type Graph <: AGraph
    ne::Int
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
end

"""
    type DiGraph <: ADiGraph
        ne::Int
        fadjlist::Vector{Vector{Int}}
        badjlist::Vector{Vector{Int}}
    end

A simple digraph type based on two adjacency lists (forward and backward).


    DiGraph(n=0)

Construct an empty DiGraph with `n` vertices.

    DiGraph{T<:Real}(adjmx::AbstractMatrix{T})

Construct a `DiGraph` from the adjacency matrix `adjmx`.
"""
type DiGraph <: ADiGraph
    ne::Int
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{Int}} # [dst]: (src, src, src)
end

typealias SimpleGraph Union{Graph, DiGraph}


#### GRAPH CONSTRUCTORS
function Graph(n::Int = 0)
    fadjlist = Vector{Vector{Int}}()
    sizehint!(fadjlist,n)
    for i = 1:n
        push!(fadjlist, Vector{Int}())
    end
    return Graph(0, fadjlist)
end

function Graph{T<:Real}(adjmx::AbstractMatrix{T})
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")
    issymmetric(adjmx) || error("Adjacency / distance matrices must be symmetric")

    g = Graph(dima)
    for i in find(triu(adjmx))
        ind = ind2sub((dima,dimb),i)
        add_edge!(g,ind...)
    end
    return g
end

Graph(n::Int, m::Int; seed::Int = -1) = erdos_renyi(n, m, Graph; seed=seed)

###################
nv(g::SimpleGraph) = length(g.fadjlist)
ne(g::SimpleGraph) = g.ne

#=
    rem_vertex!(g, v)

Remove the vertex `v` from graph `g`.
This operation has to be performed carefully if one keeps external data structures indexed by
edges or vertices in the graph, since internally the removal is performed swapping the vertices `v`  and `n=nv(g)`,
and removing the vertex `n` from the graph.
After removal the vertices in the ` g` will be indexed by 1:n-1.
This is an O(k^2) operation, where `k` is the max of the degrees of vertices `v` and `n`.
Returns false if removal fails (e.g., if vertex is not in the graph); true otherwise.
=#
function rem_vertex!(g::SimpleGraph, v::Int)
    v in vertices(g) || return false
    n = nv(g)

    clean_vertex!(g, v)

    if v != n
        neigs = collect(out_neighbors(g, n))
        for u in neigs
            rem_edge!(g, n, u)
            add_edge!(g, v, u)
        end
        if is_directed(g)
            neigs = collect(in_neighbors(g, n))
            for u in neigs
                rem_edge!(g, u, n)
                add_edge!(g, u, v)
            end
        end
    end

    pop!(g.fadjlist)
    if is_directed(g)
        pop!(g.badjlist)
    end
    return true
end

function add_edge!(g::Graph, s::Int, d::Int)
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

function rem_edge!(g::Graph, u::Int, v::Int)
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


function add_vertex!(g::Graph)
    push!(g.fadjlist, Vector{Int}())
    return nv(g)
end


##### DIGRAPH CONSTRUCTORS  #############
function DiGraph(n::Int = 0)
    fadjlist = Vector{Vector{Int}}()
    badjlist = Vector{Vector{Int}}()
    for i = 1:n
        push!(badjlist, Vector{Int}())
        push!(fadjlist, Vector{Int}())
    end
    return DiGraph(0, badjlist, fadjlist)
end


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

function DiGraph{T<:Real}(adjmx::AbstractMatrix{T})
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = DiGraph(dima)
    for i in find(adjmx)
        ind = ind2sub((dima,dimb),i)
        add_edge!(g,ind...)
    end
    return g
end


DiGraph(nv::Int, ne::Int; seed::Int = -1) = erdos_renyi(nv, ne, DiGraph, seed=seed)
#########



function copy(g::DiGraph)
    return DiGraph(g.ne, deepcopy(g.fadjlist), deepcopy(g.badjlist))
end

function add_edge!(g::DiGraph, s::Int, d::Int)
    (s in vertices(g) && d in vertices(g)) || return false
    inserted = _insert_and_dedup!(g.fadjlist[s], d)
    if inserted
        g.ne += 1
    end
    return inserted && _insert_and_dedup!(g.badjlist[d], s)
end

function rem_edge!(g::DiGraph, u::Int, v::Int)
    has_edge(g,u,v) || return false
    i = searchsorted(g.fadjlist[u],v)[1]
    deleteat!(g.fadjlist[u], i)
    i = searchsorted(g.badjlist[v], u)[1]
    deleteat!(g.badjlist[v], i)
    g.ne -= 1
    return true
end

function add_vertex!(g::DiGraph)
    push!(g.badjlist, Vector{Int}())
    push!(g.fadjlist, Vector{Int}())
    return nv(g)
end

function reverse(g::DiGraph)
    gnv = nv(g)
    gne = ne(g)
    h = DiGraph(gnv)
    h.fadjlist = deepcopy(g.badjlist)
    h.badjlist = deepcopy(g.fadjlist)
    h.ne = gne

    return h
end

function reverse!(g::DiGraph)
    g.fadjlist, g.badjlist = g.badjlist, g.fadjlist
    return g
end


out_neighbors(g::SimpleGraph,v::Int) = g.fadjlist[v]
in_neighbors(g::DiGraph,v::Int) = g.badjlist[v]

graphtype(g::DiGraph) = Graph
digraphtype(g::Graph) = DiGraph

edge(g::DiGraph, u::Int, v::Int) = Edge(u, v)
edge(g::Graph, u::Int, v::Int) = Edge(u, v)
# edge(g::Graph, u::Int, v::Int) = u <= v ? Edge(u, v) : Edge(v, u)

#### fallbaks override #######
out_adjlist(g::SimpleGraph) = g.fadjlist
in_adjlist(g::DiGraph) = g.badjlist

=={G<:SimpleGraph}(g::G, h::G) = nv(g) == nv(h) &&
                ne(g) == ne(h) && g.fadjlist == h.fadjlist


function has_edge(g::Graph, u::Int, v::Int)
    u > nv(g) || v > nv(g) && return false
    if degree(g,u) > degree(g,v)
        u, v = v, u
    end
    return length(searchsorted(neighbors(g,u), v)) > 0
end

function has_edge(g::DiGraph, u::Int, v::Int)
    u > nv(g) || v > nv(g) && return false
    if outdegree(g,u) < indegree(g,v)
        return length(searchsorted(out_neighbors(g,u), v)) > 0
    else
        return length(searchsorted(in_neighbors(g,v), u)) > 0
    end
end
