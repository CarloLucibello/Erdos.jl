"""A type representing an undirected graph."""
type Graph <: AbstractGraph
    ne::Int
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
end

"""A type representing a directed graph."""
type DiGraph <: AbstractDiGraph
    ne::Int
    fadjlist::Vector{Vector{Int}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{Int}} # [dst]: (src, src, src)
end

typealias SimpleGraph Union{Graph, DiGraph}

"""
    Graph(n=0)

Construct an empty graph with `n` vertices.
"""
function Graph(n::Int = 0)
    fadjlist = Vector{Vector{Int}}()
    sizehint!(fadjlist,n)
    for i = 1:n
        push!(fadjlist, Vector{Int}())
    end
    return Graph(0, fadjlist)
end

"""
    Graph{T<:Real}(adjmx::AbstractMatrix{T})

Construct a `Graph` from the adjacency matrix `adjmx`.
"""
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

function Graph(g::DiGraph)
    gnv = nv(g)

    edgect = 0
    newfadj = deepcopy(g.fadjlist)
    for i in 1:gnv
        for j in badj(g,i)
            if (_insert_and_dedup!(newfadj[i], j))
                edgect += 2     # this is a new edge only in badjlist
            else
                edgect += 1     # this is an existing edge - we already have it
                if i == j
                    edgect += 1 # need to count self loops
                end
            end
        end
    end
    iseven(edgect) || throw(AssertionError("invalid edgect in graph creation - please file bug report"))
    return Graph(edgect ÷ 2, newfadj)
end


fadj(g::SimpleGraph) = g.fadjlist
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

    edgs = collect(in_edges(g, v))
    for e in edgs
        rem_edge!(g, e)
    end
    neigs = copy(in_neighbors(g, n))
    for i in neigs
        rem_edge!(g, Edge(i, n))
    end
    if v != n
        for i in neigs
            add_edge!(g, Edge(i, v))
        end
    end

    if is_directed(g)
        edgs = collect(out_edges(g, v))
        for e in edgs
            rem_edge!(g, e)
        end
        neigs = copy(out_neighbors(g, n))
        for i in neigs
            rem_edge!(g, Edge(n, i))
        end
        if v != n
            for i in neigs
                add_edge!(g, Edge(v, i))
            end
        end
    end

    pop!(g.fadjlist)
    if is_directed(g)
        pop!(g.badjlist)
    end
    return true
end

function copy(g::Graph)
    return Graph(g.ne, deepcopy(g.fadjlist))
end

function add_edge!(g::Graph, e::Edge)

    s, d = e
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

function rem_edge!(g::Graph, e::Edge)
    i = searchsorted(g.fadjlist[src(e)], dst(e))
    length(i) > 0 || return false   # edge not in graph
    i = i[1]
    deleteat!(g.fadjlist[src(e)], i)
    if src(e) != dst(e)     # not a self loop
        i = searchsorted(g.fadjlist[dst(e)], src(e))[1]
        deleteat!(g.fadjlist[dst(e)], i)
    end
    g.ne -= 1
    return true # edge successfully removed
end


function add_vertex!(g::Graph)
    push!(g.fadjlist, Vector{Int}())
    return nv(g)
end


"""
    DiGraph(n=0)

Construct an empty DiGraph with `n` vertices.
"""
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


"""
    DiGraph{T<:Real}(adjmx::AbstractMatrix{T})

Construct a `DiGraph` from the adjacency matrix `adjmx`.
"""
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

function DiGraph(g::Graph)
    h = DiGraph(nv(g))
    h.ne = ne(g) * 2 - num_self_loops(g)
    h.fadjlist = deepcopy(fadj(g))
    h.badjlist = deepcopy(badj(g))
    return h
end

badj(g::DiGraph) = g.badjlist


function copy(g::DiGraph)
    return DiGraph(g.ne, deepcopy(g.fadjlist), deepcopy(g.badjlist))
end

function add_edge!(g::DiGraph, e::Edge)
    s, d = e
    (s in vertices(g) && d in vertices(g)) || return false
    inserted = _insert_and_dedup!(g.fadjlist[s], d)
    if inserted
        g.ne += 1
    end
    return inserted && _insert_and_dedup!(g.badjlist[d], s)
end


function rem_edge!(g::DiGraph, e::Edge)
    has_edge(g,e) || return false
    i = searchsorted(g.fadjlist[src(e)], dst(e))[1]
    deleteat!(g.fadjlist[src(e)], i)
    i = searchsorted(g.badjlist[dst(e)], src(e))[1]
    deleteat!(g.badjlist[dst(e)], i)
    g.ne -= 1
    return true
end

function add_vertex!(g::DiGraph)
    push!(g.badjlist, Vector{Int}())
    push!(g.fadjlist, Vector{Int}())
    return nv(g)
end
