"""
    type Net <: ANetwork
        ne::Int
        edge_index_range::Int
        out_edges::Vector{Vector{Pair{Int,Int}}}  #unordered adjlist
        epos::Vector{Pair{Int,Int}}    # position of the edge in out_edges
        free_indexes::Vector{Int}       # indexes of deleted edges to be used up
                                        # for new edges to avoid very large
                                        # indexes, and unnecessary property map
                                        # memory used
        props::PropertyStore
    end

A type representing a directed graph with indexed edges.

    DiNet(n=0)

Construct a `DiNet` with `n` vertices and no edges.

    DiNet(adjmx::AbstractMatrix)

Construct a `DiNet` from the adjacency matrix `adjmx`.
"""
type Net <: ANetwork
    ne::Int
    edge_index_range::Int
    out_edges::Vector{Vector{Pair{Int,Int}}}  #unordered adjlist
    epos::Vector{Pair{Int,Int}}    # position of the edge in out_edges
    free_indexes::Vector{Int}       # indexes of deleted edges to be used up
                                    # for new edges to avoid very large
                                    # indexes, and unnecessary property map
                                    # memory use

    props::PropertyStore
end

"""
    type DiNet <: ADiGraph
        ne::Int
        edge_index_range::Int
        out_edges::Vector{Vector{Pair{Int,Int}}}  #unordered out_adjlist
        in_edges::Vector{Vector{Pair{Int,Int}}}  #unordered in_adjlist
        epos::Vector{Pair{Int,Int}}    # position of the edge in out_edges
        free_indexes::Vector{Int}       # indexes of deleted edges to be used up
                                        # for new edges to avoid very large
                                        # indexes, and unnecessary property map
                                        # memory use
        props::PropertyStore
    end


A type representing an directed graph with indexed edges.

    DiNet(n=0)

Construct a `DiNet` with `n` vertices and no edges.

    DiNet(adjmx::AbstractMatrix)

Construct a `DiNet` from the adjacency matrix `adjmx`.
"""
type DiNet <: ADiNetwork
    ne::Int
    edge_index_range::Int
    out_edges::Vector{Vector{Pair{Int,Int}}}  #unordered out_adjlist
    in_edges::Vector{Vector{Pair{Int,Int}}}  #unordered in_adjlist
    epos::Vector{Pair{Int,Int}}    # position of the edge in out_edges
    free_indexes::Vector{Int}       # indexes of deleted edges to be used up
                                    # for new edges to avoid very large
                                    # indexes, and unnecessary property map
                                    # memory use

    props::PropertyStore
end

const SimpleNet = Union{Net, DiNet}

edgetype{G<:SimpleNet}(::Type{G}) = IndexedEdge
graphtype(::Type{DiNet}) = Net
digraphtype(::Type{Net}) = DiNet
vertextype{G<:SimpleNet}(::Type{G}) = Int

#### GRAPH CONSTRUCTORS
function DiNet(n::Integer = 0)
    out_edges = [Vector{Pair{Int,Int}}() for _=1:n]
    in_edges = [Vector{Pair{Int,Int}}() for _=1:n]

    epos = Vector{Pair{Int,Int}}()
    free_indexes = Vector{Int}()
    return DiNet(0, 0, out_edges, in_edges, epos, free_indexes, PropertyStore())
end

function DiNet{T<:Real}(adjmx::AbstractMatrix{T})
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = DiNet(dima)
    for i in find(adjmx)
        ind = ind2sub((dima,dimb),i)
        add_edge!(g,ind...)
    end
    return g
end


DiNet(n::Integer, m::Integer; seed::Integer=-1) = erdos_renyi(n, m, DiNet; seed=seed)

nv(g::SimpleNet) = length(g.out_edges)
ne(g::SimpleNet) = g.ne

function add_vertex!(g::DiNet)
    push!(g.in_edges, Vector{Pair{Int,Int}}())
    push!(g.out_edges, Vector{Pair{Int,Int}}())
    return nv(g)
end

function add_edge!(g::DiNet, u::Integer, v::Integer)
    (u in vertices(g) && v in vertices(g)) || return (false, IndexedEdge(u,v,-1))
    has_edge(g, u, v) && return (false, IndexedEdge(u,v,-1)
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

    length(g.epos) < idx && resize!(g.epos, idx)
    g.epos[idx] = Pair(length(oes), length(ies))

    return (true, IndexedEdge(u,v,idx))
end

rem_edge!(g::SimpleNet, s::Integer, t::Integer) = rem_edge!(g, edge(g, s, t))

function rem_edge!(g::DiNet, e::IndexedEdge)
    s = e.src
    t = e.dst
    idx = e.idx
    idx <= 0 && return false
    oes = g.out_edges[s]
    ies = g.in_edges[t]

    idx > length(g.epos) && return false
    length(oes) == 0 && return false
    p1 = g.epos[idx].first
    p1 < 0 && return false
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

    g.epos[idx] = Pair(-1,-1)

    g.ne -= 1
    push!(g.free_indexes, idx)
    return true
end

# TODO can be improved (see graph/digraph)
function edge(g::SimpleNet, i::Integer, j::Integer)
    (i > nv(g) || j > nv(g)) && return IndexedEdge(i, j, -1)
    oes = g.out_edges[i]
    pos = findfirst(e->e.first==j, oes)
    if pos != 0
        return IndexedEdge(i, j, oes[pos].second)
    else
        return IndexedEdge(i, j, -1)
    end
end

function out_edges(g::SimpleNet, i::Integer)
    oes = g.out_edges[i]
    return (IndexedEdge(i, j, idx) for (j, idx) in oes)
end

function out_neighbors(g::SimpleNet, i::Integer)
    oes = g.out_edges[i]
    return (j for (j, idx) in oes)
end

function in_edges(g::DiNet, i::Integer)
    ies = g.in_edges[i]
    return (IndexedEdge(j, i, idx) for (j, idx) in ies)
end


function in_neighbors(g::DiNet, i::Integer)
    ies = g.in_edges[i]
    return (j for (j, idx) in ies)
end

pop_vertex!(g::Net) = (clean_vertex!(g, nv(g)); pop!(g.out_edges); nv(g)+1)
pop_vertex!(g::DiNet) = (clean_vertex!(g, nv(g)); pop!(g.out_edges);
                          pop!(g.in_edges); nv(g)+1)

function reverse!(g::DiNet)
    g.out_edges, g.in_edges = g.in_edges, g.out_edges
    for i=1:length(g.epos)
        g.epos[i] = reverse(g.epos[i])
    end
    return g
end

## GRAPH

function Net(n::Integer = 0)
    out_edges = [Vector{Pair{Int,Int}}() for _=1:n]
    epos = Vector{Pair{Int,Int}}()
    free_indexes = Vector{Int}()
    return Net(0, 0, out_edges, epos, free_indexes, PropertyStore())
end

function Net{T<:Real}(adjmx::AbstractMatrix{T})
    dima,dimb = size(adjmx)
    isequal(dima,dimb) || error("Adjacency / distance matrices must be square")

    g = Net(dima)
    for i in find(adjmx)
        ind = ind2sub((dima,dimb),i)
        add_edge!(g,ind...)
    end
    return g
end

Net(n::Integer, m::Integer; seed::Integer=-1) = erdos_renyi(n, m, Net; seed=seed)

function add_vertex!(g::Net)
    push!(g.out_edges, Vector{Pair{Int,Int}}())
    return nv(g)
end

function add_edge!(g::Net, u::Integer, v::Integer)
    u, v = u <= v ? (u, v) : (v, u)
    (u in vertices(g) && v in vertices(g)) || return (false, IndexedEdge(u,v,-1))
    has_edge(g, u, v) && return (false, IndexedEdge(u,v,-1)) # could be removed for multigraphs

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

    length(g.epos) < idx && resize!(g.epos, idx)
    g.epos[idx] = Pair(length(oes), length(ies))

    return (true, IndexedEdge(u,v,idx))
end

function rem_edge!(g::Net, e::IndexedEdge)
    s = e.src
    t = e.dst
    if s > t
        s,t = t,s
    end
    idx = e.idx
    idx <= 0 && return false
    oes = g.out_edges[s]
    ies = g.out_edges[t]
    idx > length(g.epos) && return false
    length(oes) == 0 && return false
    p1 = g.epos[idx].first
    p1 < 0 && return false

    back = last(oes)
    if back.first > s
        p2 = g.epos[back.second].second
        g.epos[back.second] = Pair(p1 , p2)
    elseif back.first == s #fix self-edges
        g.epos[back.second] = Pair(p1, p1)
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
        elseif back.first == t #fix self-edges
            g.epos[back.second] = Pair(p1 , p1)
        else
            p2 = g.epos[back.second].first
            g.epos[back.second] = Pair(p2 , p1)
        end
        ies[p1] = back
        pop!(ies)
    end

    g.epos[idx] = Pair(-1,-1)

    g.ne -= 1
    push!(g.free_indexes, idx)
    return true
end

function in_edges(g::Net, i::Integer)
    ies = g.out_edges[i]
    return (IndexedEdge(j, i, idx) for (j, idx) in ies)
end

function test_consistency(g::Net)
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

function test_consistency(g::DiNet)
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
