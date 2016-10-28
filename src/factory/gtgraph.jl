immutable GTEdge <: AbstractEdge
    src::Int
    dst::Int
    idx::Int
end


"""A type representing an undirected graph."""
type GTDiGraph <: AbstractGraph
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
    keep_epos = false
    epos = Vector{Pair{Int,Int}}()
    return GTDiGraph(0, 0, in_edges, out_edges, keep_epos, epos)
end


GTDiGraph(n::Int, m::Int; seed::Int=-1) = erdos_renyi(n, m, GTDiGraph; seed=seed)

nv(g::GTDiGraph) = length(g.out_edges)
ne(g::GTDiGraph) = g.ne

function add_vertex!(g::GTDiGraph)
    push!(g.in_edges, Vector{Pair{Int,Int}}())
    push!(g.out_edges, Vector{Pair{Int,Int}}())
    return nv(g)
end

function add_edge!(g::GTDiGraph, i::Int, j::Int)
    (u in vertices(g) && v in vertices(g)) || return false
    has_edge(g, u, v) || return false # could be removed for multigraphs
    if isempty(g.free_indexes)
        g.edge_index_range += 1
        idx = g.edge_index_range
    else
        idx = pop!(g.free_indexes)
    end
    oes = g.out_edges[i]
    ies = g.in_edges[j]
    push!(oes, Pair(j, idx))
    push!(ies, Pair(i, idx))
    g.ne += 1

    if g.keep_epos
        lenght(epos) < idx && resize!(epos, idx)
        ei = epos[idx]
        ei.first = length(oes)
        ei.second = length(ies)
    end

    return true
end

function rem_edge!(g::GTDiGraph, s::Int, t::Int)
    if !g.keep_epos
        oes = g.out_edges[s]
        po = findfirst(e->e.first==t, oes)

        po == 0 && return false
        push!(g.free_indexes, oes[po]->second)
        deleteat!(oes, po)
        g.ne -= 1

        ies = g.in_edges[t];
        pi = findfirst(e->e.first==s, ies)
        pi == 0 && error("rem_edge")
        deleteat!(ies, pi)
    else
        return rem_edge(g, edge(s, t, g));
    end
    return true
end

function rem_edge!(g::GTDiGraph, e::GTEdge)
    s = e.src
    t = e.dst
    idx = e.idx
    oes = g.out_edges[s]
    ies = g.in_edges[t]
    if !g._keep_epos # O(k_s + k_t)

        po = findfirst(e->e.first==s && e.second==idx, oes)
        po == 0 && return false
        deleteat!(oes, po)

        ies = g.in_edges[t]
        pi = findfirst(e->e.first==s && e.second==idx, ies)
        pi == 0 && error("rem_edge")
        deleteat!(ies, pi)

    else # O(1)
        if idx <= length(g.epos)

                back = last(oes)
                pindex = g.epos[idx].first
                g.epos[back.idx].first = pindex
                oes[pindex] = back
                pop!(oes)

                back = last(ies)
                pindex = g.epos[idx].second
                g.epos[back.idx].second = pindex
                ies[pindex] = back
                pop!(ies)
        else
            return false
        end
    end

    g.ne -= 1
    push!(g.free_indexes, idx)
    return true
end

function edge(g::GTDiGraph, i::Int, j::Int)
    oes = g.out_edges[i]
    pos = findfirst(e->e.first==j, oes)
    if pos != 0
        return GTEdge(i, j, oes[pos]->second)
    else
        return GTEdge(i, j, -1)
    end
end

function out_edges(g::GTDiGraph, i::Int)
    oes = g.out_edges[i]
    return (GTEdge(i, j, idx) for (j, idx) in oes)
end

function out_neighbors(g::GTDiGraph, i::Int)
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

# O(k + k_last)
function rem_vertex!(g::GTDiGraph, v::Int)
    back = length(g.out_edges)

    if v <= back
        clear_vertex!(g, v)
        g.out_edges[back], g.out_edges[v] = (g.out_edges[v], g.out_edges[back])
        g.in_edges[back], g.in_edges[v] = (g.in_edges[v], g.in_edges[back])
        pop!(g.out_edges)
        pop!(g.in_edges)

        auto rename_v = [&] (auto& out_edges, auto& in_edges,
                             const auto& get_pos)
            {
                for (auto& eu : out_edges[v])
                {
                    Vertex u = eu.first;
                    if (u == back)
                    {
                        eu.first = v;
                    }
                    else
                    {
                        if (!g._keep_epos)
                        {
                            for (auto& e : in_edges[u])
                            {
                                if (e.first == back)
                                    e.first = v;
                            }
                        }
                        else
                        {
                            size_t idx = eu.second;
                            auto pos = get_pos(idx);
                            in_edges[u][pos].first = v;
                        }
                    }
                }
            };

        rename_v(g._out_edges, g._in_edges,
                 [&](size_t idx) -> auto {return g._epos[idx].second;});
        rename_v(g._in_edges, g._out_edges,
                 [&](size_t idx) -> auto {return g._epos[idx].first;});

    else
        clear_vertex!(g, v)
        pop!(g.out_edges)
        pop!(g.in_edges)
    end
end


function clear_vertex(g::GTDiGraph, v::Int)
    if !g.keep_epos
        function remove_es(out_edges, in_edges)
            oes = out_edges[v]
            for oe in oes
                t = oe.first
                ies = in_edges[t]
                filter!(ei-> begin
                               if ei.first == v
                                   push!(g.free_indexes, ei.second)
                                   return false
                               else
                                   return true
                               end
                            end
                        , ies)
            end
            g.ne -= length(oes)
        end
        remove_es(g.out_edges, g.in_edges)
        remove_es(g.in_edges, g.out_edges)
    else
        auto remove_es = [&] (auto& out_edges, auto& in_edges,
                              const auto& get_pos)
        {
            auto& oes = out_edges[v];
            for (const auto& ei : oes)
            {
                Vertex t = ei.first;
                size_t idx = ei.second;
                auto& ies = in_edges[t];
                auto& back = ies.back();
                auto& pos = get_pos(idx);
                auto& bpos = get_pos(back.second);
                bpos = pos;
                ies[pos] = back;
                ies.pop_back();
                g._free_indexes.push_back(idx);
            }
            g._n_edges -= oes.size();
            oes.clear();
        };
        remove_es(g._out_edges, g._in_edges,
                  [&](size_t idx) -> auto& {return g._epos[idx].second;});
        remove_es(g._in_edges, g._out_edges,
                  [&](size_t idx) -> auto& {return g._epos[idx].first;});
    end
end
