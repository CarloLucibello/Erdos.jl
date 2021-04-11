"""
    Network

A type representing a graph with indexed edges and the possibility to store 
graph/vertex/edge properties.

    Network(n=0)

Construct a `Network` with `n` vertices and no edges.

    Network(adjmx::AbstractMatrix; selfedges=true, upper=false)

Construct a `Network` from the adjacency matrix `adjmx`, placing an edge in
correspondence to each nonzero element of `adjmx`.
If `selfedges=false` the diagonal elements of `adjmx` are ignored.
If `upper=true` only the upper triangular part of `adjmx` is considered.
"""
mutable struct Network <: ANetwork
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

function Network(n::Integer = 0)
    out_edges = [Vector{Pair{Int,Int}}() for _=1:n]
    epos = Vector{Pair{Int,Int}}()
    free_indexes = Vector{Int}()
    return Network(0, 0, out_edges, epos, free_indexes, PropertyStore())
end


"""
    DiNetwork


A type representing a directed graph with indexed edges and the possibility to store 
graph/vertex/edge properties.

    DiNetwork(n=0)

Construct a `DiNetwork` with `n` vertices and no edges.

    DiNetwork(adjmx::AbstractMatrix; selfedges=true)

Construct a `DiNetwork` from the adjacency matrix `adjmx`.
If `selfedges=false` the diagonal elements of `adjmx` are ignored.
"""
mutable struct DiNetwork <: ADiNetwork
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

function DiNetwork(n::Integer = 0)
    out_edges = [Vector{Pair{Int,Int}}() for _=1:n]
    in_edges = [Vector{Pair{Int,Int}}() for _=1:n]

    epos = Vector{Pair{Int,Int}}()
    free_indexes = Vector{Int}()
    return DiNetwork(0, 0, out_edges, in_edges, epos, free_indexes, PropertyStore())
end


const NetOrDiNet = Union{Network, DiNetwork}

edgetype(::Type{G}) where {G<:NetOrDiNet} = IndexedEdge
graphtype(::Type{DiNetwork}) = Network
digraphtype(::Type{Network}) = DiNetwork
vertextype(::Type{G}) where {G<:NetOrDiNet} = Int

nv(g::NetOrDiNet) = length(g.out_edges)
ne(g::NetOrDiNet) = g.ne

function add_vertex!(g::DiNetwork)
    push!(g.in_edges, Vector{Pair{Int,Int}}())
    push!(g.out_edges, Vector{Pair{Int,Int}}())
    return nv(g)
end

function add_edge!(g::DiNetwork, u::Integer, v::Integer)
    (u in vertices(g) && v in vertices(g)) || return (false, IndexedEdge(u,v,-1))
    has_edge(g, u, v) && return (false, IndexedEdge(u,v,-1))
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

rem_edge!(g::NetOrDiNet, s::Integer, t::Integer) = rem_edge!(g, edge(g, s, t))

function rem_edge!(g::DiNetwork, e::IndexedEdge)
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
function edge(g::NetOrDiNet, i::Integer, j::Integer)
    (i > nv(g) || j > nv(g)) && return IndexedEdge(i, j, -1)
    oes = g.out_edges[i]
    pos = findfirst(e->e.first==j, oes)
    if pos !== nothing
        return IndexedEdge(i, j, oes[pos].second)
    else
        return IndexedEdge(i, j, -1)
    end
end

function out_edges(g::NetOrDiNet, i::Integer)
    oes = g.out_edges[i]
    return (IndexedEdge(i, j, idx) for (j, idx) in oes)
end

function out_neighbors(g::NetOrDiNet, i::Integer)
    oes = g.out_edges[i]
    return (j for (j, idx) in oes)
end

function in_edges(g::DiNetwork, i::Integer)
    ies = g.in_edges[i]
    return (IndexedEdge(j, i, idx) for (j, idx) in ies)
end


function in_neighbors(g::DiNetwork, i::Integer)
    ies = g.in_edges[i]
    return (j for (j, idx) in ies)
end

pop_vertex!(g::Network) = (clean_vertex!(g, nv(g)); pop!(g.out_edges); nv(g)+1)
pop_vertex!(g::DiNetwork) = (clean_vertex!(g, nv(g)); pop!(g.out_edges);
                          pop!(g.in_edges); nv(g)+1)

function reverse!(g::DiNetwork)
    g.out_edges, g.in_edges = g.in_edges, g.out_edges
    for i=1:length(g.epos)
        g.epos[i] = reverse(g.epos[i])
    end
    return g
end

## GRAPH

function add_vertex!(g::Network)
    push!(g.out_edges, Vector{Pair{Int,Int}}())
    return nv(g)
end

function add_edge!(g::Network, u::Integer, v::Integer)
    u, v = u <= v ? (u, v) : (v, u)
    (u in vertices(g) && v in vertices(g)) || return (false, IndexedEdge(u,v,-1))
    has_edge(g, u, v) && return (false, IndexedEdge(u,v,-1)) # could be removed for multigraphs

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

function rem_edge!(g::Network, e::IndexedEdge)
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

function in_edges(g::Network, i::Integer)
    ies = g.out_edges[i]
    return (IndexedEdge(j, i, idx) for (j, idx) in ies)
end

function swap_vertices!(g::Network, u::Integer, v::Integer)
    if u != v
        #TODO copying to avoid problems with self edges
        # maybe can copy only one of the two
        neigu = deepcopy(g.out_edges[u])
        neigv = deepcopy(g.out_edges[v])

        for (k,p) in enumerate(neigu)
            j, idx = p
            kj = j <= u ? g.epos[idx].first : g.epos[idx].second
            g.out_edges[j][kj] = Pair(v, idx)
            g.epos[idx] = j <= v ? Pair(kj, k) : Pair(k, kj)
        end

        for (k,p) in enumerate(neigv)
            j, idx = p
            kj = j <= v ? g.epos[idx].first : g.epos[idx].second
            g.out_edges[j][kj] = Pair(u, idx)
            g.epos[idx] = j <= u ? Pair(kj, k) : Pair(k, kj)
        end

        g.out_edges[u], g.out_edges[v] = g.out_edges[v], g.out_edges[u]

        swap_vertices!(g.props, u, v)
    end
end

function swap_vertices!(g::DiNetwork, u::Integer, v::Integer)
    if u != v
        #TODO copying to avoid problems with self edges
        # maybe can copy only one of the two
        neigu = deepcopy(g.out_edges[u])
        neigv = deepcopy(g.out_edges[v])
        neiguin = deepcopy(g.in_edges[u])
        neigvin = deepcopy(g.in_edges[v])

        for (k,p) in enumerate(neigu)
            j, idx = p
            kj = g.epos[idx].second
            g.in_edges[j][kj] = Pair(v, idx)
        end

        for (k,p) in enumerate(neigv)
            j, idx = p
            kj = g.epos[idx].second
            g.in_edges[j][kj] = Pair(u, idx)
        end

        for (k,p) in enumerate(neiguin)
            j, idx = p
            kj = g.epos[idx].first
            g.out_edges[j][kj] = Pair(v, idx)
        end

        for (k,p) in enumerate(neigvin)
            j, idx = p
            kj = g.epos[idx].first
            g.out_edges[j][kj] = Pair(u, idx)
        end

        g.out_edges[u], g.out_edges[v] = g.out_edges[v], g.out_edges[u]
        g.in_edges[u], g.in_edges[v] = g.in_edges[v], g.in_edges[u]

        swap_vertices!(g.props, u, v)
    end
end

# function test_consistency(g::Network)
#     for i=1:nv(g)
#         for (k, p) in  enumerate(g.out_edges[i])
#             j = p.first
#             id = p.second
#             if i < j
#                 @assert g.epos[id].first == k "$id $i $j $(g.epos[id]) $(g.out_edges[i])"
#             else
#                 @assert g.epos[id].second == k
#             end
#             @assert findfirst(e->e.first==i, g.out_edges[j]) > 0
#         end
#     end
# end
#
# function test_consistency(g::DiNetwork)
#     for i=1:nv(g)
#         for (k, p) in  enumerate(g.out_edges[i])
#             j = p.first
#             id = p.second
#             @assert g.epos[id].first == k "$id $i $j $(g.epos[id]) $(g.out_edges[i])"
#             posin = findfirst(e->e.first==i, g.in_edges[j])
#             @assert posin > 0
#             @assert g.in_edges[j][posin].second == id
#         end
#     end
# end
