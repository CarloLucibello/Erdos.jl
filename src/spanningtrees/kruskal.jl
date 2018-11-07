struct KruskalHeapEntry{E, T<:Real}
    edge::E
    dist::T
end

isless(e1::KruskalHeapEntry, e2::KruskalHeapEntry) = e1.dist < e2.dist

""" Performs [Quick-Find algorithm](https://en.wikipedia.org/wiki/Disjoint-set_data_structure)
on a given pair of nodes `p`and `q`, and makes a connection between them
in the vector `nodes`.
"""
function quick_find!(nodes::Vector, p, q)
    pid = nodes[p]
    qid = nodes[q]
    for i in 1:length(nodes)
        if nodes[i] == pid
            nodes[i] = qid
        end
    end
end

"""
    minimum_spanning_tree{T<:Real}(
        g, distmx::AbstractMatrix{T} = weights(g)
    )

Performs [Kruskal's algorithm](https://en.wikipedia.org/wiki/Kruskal%27s_algorithm)
on a connected, undirected graph `g`, having adjacency matrix `distmx`,
and computes minimum spanning tree. Returns a `Vector{KruskalHeapEntry}`,
that contains the containing edges and its weights.
"""
function minimum_spanning_tree(
    g::AGraph,
    distmx::AbstractMatrix{T} = weights(g)
) where T<:Real
    E = edgetype(g)
    V = vertextype(g)
    edge_list = Vector{KruskalHeapEntry{E,T}}()
    mst = Vector{E}()
    connected_nodes = Vector{V}(1:nv(g))

    sizehint!(edge_list, ne(g))
    sizehint!(mst, ne(g))

    for e in edges(g)
        heappush!(edge_list, KruskalHeapEntry(e, distmx[src(e),dst(e)]))
    end

    while !isempty(edge_list) && length(mst) < nv(g) - 1
        heap_entry = heappop!(edge_list)
        v = src(heap_entry.edge)
        w = dst(heap_entry.edge)

        if connected_nodes[v] != connected_nodes[w]
            quick_find!(connected_nodes, v, w)
            push!(mst, heap_entry.edge)
        end
    end

    return mst
end
