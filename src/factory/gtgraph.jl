type GTEdge <: AbstractEdge
    src::Int
    dst::Int
    idx::Int
end


"""A type representing an undirected graph."""
type GTGraph <: AbstractGraph
    ne::Int
    edge_index_range::Int
    epos::Vector{Pair{Int,Int}}
    fadjlist::Vector{Vector{Pair{Int,Int}}} # [src]: (dst, dst, dst)
end

"""A type representing an undirected graph."""
type GTDiGraph <: AbstractDiGraph
    ne::Int
    edge_index_range::Int
    epos::Vector{Pair{Int,Int}}
    fadjlist::Vector{Vector{Pair{Int,Int}}} # [src]: (dst, dst, dst)
    badjlist::Vector{Vector{Pair{Int,Int}}} # [src]: (dst, dst, dst)
end

typealias SimpleGTGraph Union{GTGraph, GTDiGraph}

#### GRAPH CONSTRUCTORS
"""
    GTGraph(n=0)

Construct an empty graph with `n` vertices.
"""
function GTGraph(n::Int = 0)
    fadjlist = Vector{Vector{Pair{Int,Int}}}()
    sizehint!(fadjlist,n)
    for i = 1:n
        push!(fadjlist, Vector{Int}())
    end
    epos = Vector{Int}()
    return GTGraph(0, 0, epos, fadjlist)
end


GTGraph(n::Int, m::Int; seed::Int = -1) = erdos_renyi_undir(n, m; seed=seed)

###################
nv(g::SimpleGTGraph) = length(g.fadjlist)
ne(g::SimpleGTGraph) = g.ne

function rem_vertex!(g::SimpleGTGraph, v::Int)
    v in vertices(g) || return false
    n = nv(g)

    edgs = collect(in_edges(g, v))
    for e in edgs
        rem_edge!(g, e)
    end
    neigs = collect(in_neighbors(g, n))
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
        neigs = collect(out_neighbors(g, n))
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

function copy(g::GTGraph)
    return GTGraph(g.ne, g.edge_index_range, deepcopy(epos), deepcopy(g.fadjlist))
end

function add_edge!(g::GTGraph, u::Int, v::Int)
    (u in vertices(g) && v in vertices(g)) || return false
    has_edge(g, u, v) || return false
    idx = (g.edge_index_range += 1)
    resize!(g.epos)
    g.ne += 1
    GTEdge(u, v, idx)
    push!(g.fadjlist[u], Pair(v, idx))
    inserted = _insert_and_dedup!(g.fadjlist[s], d)
    if s != d
        inserted = _insert_and_dedup!(g.fadjlist[d], s)
    end
    return true
end

function rem_edge!(g::GTGraph, e::Edge)
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


function add_vertex!(g::GTGraph)
    push!(g.fadjlist, Vector{Int}())
    return nv(g)
end


##### DIGRAPH CONSTRUCTORS  #############
"""
    GTDiGraph(n=0)

Construct an empty GTDiGraph with `n` vertices.
"""
function GTDiGraph(n::Int = 0)
    fadjlist = Vector{Vector{Int}}()
    badjlist = Vector{Vector{Int}}()
    for i = 1:n
        push!(badjlist, Vector{Int}())
        push!(fadjlist, Vector{Int}())
    end
    return GTDiGraph(0, badjlist, fadjlist)
end


function GTDiGraph{T<:Real}(adjmx::SparseMatrixCSC{T})
    dima, dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = GTDiGraph(dima)
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
    GTDiGraph{T<:Real}(adjmx::AbstractMatrix{T})

Construct a `GTDiGraph` from the adjacency matrix `adjmx`.
"""
function GTDiGraph{T<:Real}(adjmx::AbstractMatrix{T})
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = GTDiGraph(dima)
    for i in find(adjmx)
        ind = ind2sub((dima,dimb),i)
        add_edge!(g,ind...)
    end
    return g
end


GTDiGraph(nv::Integer, ne::Integer; seed::Int = -1) = erdos_renyi_dir(nv, ne, seed=seed)
#########



function copy(g::GTDiGraph)
    return GTDiGraph(g.ne, deepcopy(g.fadjlist), deepcopy(g.badjlist))
end

function add_edge!(g::GTDiGraph, e::Edge)
    s, d = e
    (s in vertices(g) && d in vertices(g)) || return false
    inserted = _insert_and_dedup!(g.fadjlist[s], d)
    if inserted
        g.ne += 1
    end
    return inserted && _insert_and_dedup!(g.badjlist[d], s)
end


function rem_edge!(g::GTDiGraph, e::Edge)
    has_edge(g,e) || return false
    i = searchsorted(g.fadjlist[src(e)], dst(e))[1]
    deleteat!(g.fadjlist[src(e)], i)
    i = searchsorted(g.badjlist[dst(e)], src(e))[1]
    deleteat!(g.badjlist[dst(e)], i)
    g.ne -= 1
    return true
end

function add_vertex!(g::GTDiGraph)
    push!(g.badjlist, Vector{Int}())
    push!(g.fadjlist, Vector{Int}())
    return nv(g)
end

#TODO define for abstract types
"""
    reverse(g::GTDiGraph)

Produces a graph where all edges are reversed from the
original.
"""
function reverse(g::GTDiGraph)
    gnv = nv(g)
    gne = ne(g)
    h = GTDiGraph(gnv)
    h.fadjlist = deepcopy(g.badjlist)
    h.badjlist = deepcopy(g.fadjlist)
    h.ne = gne

    return h
end


#TODO define for abstract types
"""
    reverse!(g::GTDiGraph)

In-place reverse (modifies the original graph).
"""
function reverse!(g::GTDiGraph)
    g.fadjlist, g.badjlist = g.badjlist, g.fadjlist
    return g
end


out_neighbors(g::SimpleGTGraph,v::Int) = g.fadjlist[v]
in_neighbors(g::GTDiGraph,v::Int) = g.badjlist[v]


function digraph(g::GTGraph)
    h = GTDiGraph(nv(g))
    h.ne = ne(g) * 2 - num_self_loops(g)
    h.fadjlist = deepcopy(g.fadjlist)
    h.badjlist = deepcopy(g.fadjlist)
    return h
end

graph(g::GTGraph) = g


digraph(g::GTDiGraph) = g

function graph(g::GTDiGraph)
    gnv = nv(g)

    edgect = 0
    newfadj = deepcopy(g.fadjlist)
    for i in 1:gnv
        for j in in_neighbors(g,i)
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
    return GTGraph(edgect ÷ 2, newfadj)
end

#### fallbaks override #######
out_adjlist(g::SimpleGTGraph) = g.fadjlist
in_adjlist(g::GTDiGraph) = g.badjlist

=={G<:SimpleGTGraph}(g::G, h::G) = nv(g) == nv(h) &&
                ne(g) == ne(h) && g.fadjlist == h.fadjlist


function has_edge(g::GTGraph, e::Edge)
    u, v = e
    u > nv(g) || v > nv(g) && return false
    if degree(g,u) > degree(g,v)
        u, v = v, u
    end
    return length(searchsorted(neighbors(g,u), v)) > 0
end

function has_edge(g::GTDiGraph, e::Edge) = has_edge(g, src(e), dst(e))
function has_edge(g::GTDiGraph, u::Int, v::Int)
    u > nv(g) || v > nv(g) && return false
    if degree(g,u) < degree(g,v)
        return length(searchsorted(out_neighbors(g,u), v)) > 0
    else
        return length(searchsorted(in_neighbors(g,v), u)) > 0
    end
end
