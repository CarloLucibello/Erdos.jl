immutable GTEdge <: AEdge
    src::Int
    dst::Int
    idx::Int

    GTEdge(u, v, idx=-1) = new(u,v,idx)
end

src(e::GTEdge) = e.src
dst(e::GTEdge) = e.dst
id(e::GTEdge) = e.idx
show(io::IO, e::GTEdge) = print(io, "($(e.src)=>$(e.dst),$(e.idx))")
reverse(e::GTEdge) = GTEdge(e.dst, e.src, e.idx)

"""A type representing an undirected graph with indexed edges."""
type GTDiGraph <: ADiGraph
    ne::Int
    edge_index_range::Int

    out_edges::Vector{Vector{Pair{Int,Int}}}
    in_edges::Vector{Vector{Pair{Int,Int}}}

    keep_epos::Bool
    epos::Vector{Pair{Int,Int}}    #position of the edge in out_edges and in_edges

    free_indexes::Vector{Int}       # indexes of deleted edges to be used up
                                    # for new edges to avoid very large
                                    # indexes, and unnecessary property map
                                    # memory use
end

"""A type representing an undirected graph with indexed edges."""
type GTGraph <: AGraph
    ne::Int
    edge_index_range::Int

    out_edges::Vector{Vector{Pair{Int,Int}}}  #unordered adjlist

    keep_epos::Bool                # keep updated epos
    epos::Vector{Pair{Int,Int}}    # position of the edge in out_edges

    free_indexes::Vector{Int}       # indexes of deleted edges to be used up
                                    # for new edges to avoid very large
                                    # indexes, and unnecessary property map
                                    # memory use
end

typealias SimpleGTGraph Union{GTGraph, GTDiGraph}

edgetype(g::SimpleGTGraph) = GTEdge
graphtype(g::GTDiGraph) = GTGraph
digraphtype(g::GTGraph) = GTDiGraph



#### GRAPH CONSTRUCTORS
"""
    GTDiGraph(n=0)

Construct an empty graph with `n` vertices.
"""
function GTDiGraph(n::Int = 0)
    out_edges = Vector{Vector{Pair{Int,Int}}}()
    in_edges = Vector{Vector{Pair{Int,Int}}}()
    sizehint!(out_edges,n)
    sizehint!(in_edges,n)
    for i=1:n
        push!(out_edges, Vector{Pair{Int,Int}}())
        push!(in_edges, Vector{Pair{Int,Int}}())
    end
    keep_epos = true
    epos = Vector{Pair{Int,Int}}()
    free_indexes = Vector{Int}()
    return GTDiGraph(0, 0, out_edges, in_edges, keep_epos, epos, free_indexes)
end

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


GTDiGraph(n::Int, m::Int; seed::Int=-1) = erdos_renyi(n, m, GTDiGraph; seed=seed)

nv(g::SimpleGTGraph) = length(g.out_edges)
ne(g::SimpleGTGraph) = g.ne

function add_vertex!(g::GTDiGraph)
    push!(g.in_edges, Vector{Pair{Int,Int}}())
    push!(g.out_edges, Vector{Pair{Int,Int}}())
    return nv(g)
end

function add_edge!(g::GTDiGraph, u::Int, v::Int)
    (u in vertices(g) && v in vertices(g)) || return false
    has_edge(g, u, v) && return false # could be removed for multigraphs
    if isempty(g.free_indexes)
        g.edge_index_range += 1
        idx = g.edge_index_range
    else
        idx = pop!(g.free_indexes)
    end
    oes = g.out_edges[u]
    ies = g.in_edges[v]
    push!(oes, Pair(v, idx))
    push!(ies, Pair(u, idx))
    g.ne += 1

    if g.keep_epos
        length(g.epos) < idx && resize!(g.epos, idx)
        g.epos[idx] = Pair(length(oes), length(ies))
    end

    return true
end

function rem_edge!(g::GTDiGraph, s::Int, t::Int)
    if !g.keep_epos
        oes = g.out_edges[s]
        po = findfirst(e->e.first==t, oes)

        po == 0 && return false
        push!(g.free_indexes, oes[po].second)
        deleteat!(oes, po)
        g.ne -= 1

        ies = g.in_edges[t];
        pi = findfirst(e->e.first==s, ies)
        pi == 0 && error("rem_edge")
        deleteat!(ies, pi)
    else
        return rem_edge!(g, edge(g, s, t));
    end
    return true
end

function rem_edge!(g::GTDiGraph, e::GTEdge)
    s = e.src
    t = e.dst
    idx = e.idx
    idx <= 0 && return false
    oes = g.out_edges[s]
    ies = g.in_edges[t]
    if !g.keep_epos # O(k_s + k_t)
        po = findfirst(e->e.first==t && e.second==idx, oes)
        po == 0 && return false
        deleteat!(oes, po)

        ies = g.in_edges[t]
        pi = findfirst(e->e.first==s && e.second==idx, ies)
        pi == 0 && error("rem_edge")
        deleteat!(ies, pi)

    else # O(1)
        idx > length(g.epos) && return false

        back = last(oes)
        p1 = g.epos[idx].first
        p2 = g.epos[back.second].second
        g.epos[back.second] = Pair(p1, p2)
        oes[p1] = back
        pop!(oes)

        back = last(ies)
        p1 = g.epos[back.second].first
        p2 = g.epos[idx].second
        g.epos[back.second] = Pair(p1, p2)
        ies[p2] = back
        pop!(ies)
    end

    g.ne -= 1
    push!(g.free_indexes, idx)
    return true
end

# TODO can be improved (see graph/digraph)
function edge(g::SimpleGTGraph, i::Int, j::Int)
    (i > nv(g) || j > nv(g)) && return GTEdge(i, j, -1)
    oes = g.out_edges[i]
    pos = findfirst(e->e.first==j, oes)
    if pos != 0
        return GTEdge(i, j, oes[pos].second)
    else
        return GTEdge(i, j, -1)
    end
end

function out_edges(g::SimpleGTGraph, i::Int)
    oes = g.out_edges[i]
    return (GTEdge(i, j, idx) for (j, idx) in oes)
end

function out_neighbors(g::SimpleGTGraph, i::Int)
    oes = g.out_edges[i]
    return (j for (j, idx) in oes)
end

function in_edges(g::GTDiGraph, i::Int)
    ies = g.in_edges[i]
    return (GTEdge(j, i, idx) for (j, idx) in ies)
end


function in_neighbors(g::GTDiGraph, i::Int)
    ies = g.in_edges[i]
    return (j for (j, idx) in ies)
end

function rem_vertex!(g::SimpleGTGraph, v::Int)
    v in vertices(g) || return false
    n = nv(g)
    clean_vertex!(g, v)

    if v != n
        edgs = collect(out_edges(g, n))
        for e in edgs
            rem_edge!(g, e)
            add_edge!(g, v, dst(e))
        end
        if is_directed(g)
            edgs = collect(in_edges(g, n))
            for e in edgs
                rem_edge!(g, e)
                add_edge!(g, src(e), v)
            end
        end
    end

    pop!(g.out_edges)
    if is_directed(g)
        pop!(g.in_edges)
    end
    return true
end

function reverse!(g::GTDiGraph)
    g.out_edges, g.in_edges = g.in_edges, g.out_edges
    for i=1:length(g.epos)
        g.epos[i] = reverse(g.epos[i])
    end
    return g
end

## GRAPH

"""
    GTGraph(n=0)

Construct an empty graph with `n` vertices.
"""
function GTGraph(n::Int = 0)
    out_edges = Vector{Vector{Pair{Int,Int}}}()
    sizehint!(out_edges,n)
    for i=1:n
        push!(out_edges, Vector{Pair{Int,Int}}())
    end
    keep_epos = true
    epos = Vector{Pair{Int,Int}}()
    free_indexes = Vector{Int}()
    return GTGraph(0, 0, out_edges, keep_epos, epos, free_indexes)
end

function GTGraph{T<:Real}(adjmx::AbstractMatrix{T})
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = GTGraph(dima)
    for i in find(adjmx)
        ind = ind2sub((dima,dimb),i)
        add_edge!(g,ind...)
    end
    return g
end

GTGraph(n::Int, m::Int; seed::Int=-1) = erdos_renyi(n, m, GTGraph; seed=seed)

function add_vertex!(g::GTGraph)
    push!(g.out_edges, Vector{Pair{Int,Int}}())
    return nv(g)
end

function add_edge!(g::GTGraph, u::Int, v::Int)
    (u in vertices(g) && v in vertices(g)) || return false
    has_edge(g, u, v) && return false # could be removed for multigraphs

    if u > v
        u,v = v,u
    end
    if isempty(g.free_indexes)
        g.edge_index_range += 1
        idx = g.edge_index_range
    else
        idx = pop!(g.free_indexes)
    end
    oes = g.out_edges[u]
    ies = g.out_edges[v]
    push!(oes, Pair(v, idx))
    if u != v
        push!(ies, Pair(u, idx))
    end
    g.ne += 1

    if g.keep_epos
        length(g.epos) < idx && resize!(g.epos, idx)
        g.epos[idx] = Pair(length(oes), length(ies))
    end

    return true
end

function rem_edge!(g::GTGraph, s::Int, t::Int)
    if !g.keep_epos
        oes = g.out_edges[s]
        po = findfirst(e->e.first==t, oes)

        po == 0 && return false
        push!(g.free_indexes, oes[po].second)
        deleteat!(oes, po)
        g.ne -= 1
        if s != t
            ies = g.out_edges[t];
            pi = findfirst(e->e.first==s, ies)
            pi == 0 && error("rem_edge")
            deleteat!(ies, pi)
        end
    else
        return rem_edge!(g, edge(g, s, t));
    end
    return true
end

function rem_edge!(g::GTGraph, e::GTEdge)
    s = e.src
    t = e.dst
    if s > t
        s,t = t,s
    end
    idx = e.idx
    idx <= 0 && return false
    oes = g.out_edges[s]
    ies = g.out_edges[t]
    if !g.keep_epos # O(k_s + k_t)
        po = findfirst(e->e.first==t && e.second==idx, oes)
        po == 0 && return false
        deleteat!(oes, po)

        if s != t
            pi = findfirst(e->e.first==s && e.second==idx, ies)
            pi == 0 && error("rem_edge")
            deleteat!(ies, pi)
        end
    else # O(1)

        idx > length(g.epos) && return false
        back = last(oes)
        p1 = g.epos[idx].first
        if back.first > s
            p2 = g.epos[back.second].second
            g.epos[back.second] = Pair(p1 , p2)
        else
            p2 = g.epos[back.second].first
            g.epos[back.second] = Pair(p2 , p1)
        end
        oes[p1] = back
        pop!(oes)

        if s != t
            back = last(ies)
            p1 = g.epos[idx].second
            if back.first > t
                p2 = g.epos[back.second].second
                g.epos[back.second] = Pair(p1 , p2)
            else
                p2 = g.epos[back.second].first
                g.epos[back.second] = Pair(p2 , p1)
            end
            ies[p1] = back
            pop!(ies)
        end
    end

    g.ne -= 1
    push!(g.free_indexes, idx)
    return true
end

function in_edges(g::GTGraph, i::Int)
    ies = g.out_edges[i]
    return (GTEdge(j, i, idx) for (j, idx) in ies)
end

function test_consistency(g::GTGraph)
    if g.keep_epos
        for i=1:nv(g)
            for (k, p) in  enumerate(g.out_edges[i])
                j = p.first
                id = p.second
                if i < j
                    @assert g.epos[id].first == k "$id $i $j $(g.epos[id]) $(g.out_edges[i])"
                else
                    @assert g.epos[id].second == k
                end
                @assert findfirst(e->e.first==i, g.out_edges[j]) > 0
            end
        end
    end
end

function test_consistency(g::GTDiGraph)
    if g.keep_epos
        for i=1:nv(g)
            for (k, p) in  enumerate(g.out_edges[i])
                j = p.first
                id = p.second
                @assert g.epos[id].first == k "$id $i $j $(g.epos[id]) $(g.out_edges[i])"
                posin = findfirst(e->e.first==i, g.in_edges[j])
                @assert posin > 0
                @assert g.in_edges[j][posin].second == id
            end
        end
    end
end
