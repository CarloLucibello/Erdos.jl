"""
    vertices(g)

Returns an iterator to the vertices of a graph (i.e. 1:nv(g))
"""
vertices(g::AS) = 1:nv(g)

"""
    edges(g)

Returns an iterator to the edges of a graph.
The returned iterator is valid for one pass over the edges, and is invalidated by changes to `g`.
"""
edges(g::AS) = EdgeIter(g)

fadj(g::AS, v::Int) = fadj(g)[v]
badj(g::AS, v::Int) = badj(g)[v]

badj(g::AG) = fadj(g)


"""
Returns the adjacency list of a graph.
For each vertex the Array of `dst` for each edge eminating from that vertex.

NOTE: returns a reference, not a copy. Do not modify result.
"""
adj(g::AG) = fadj(g)
adj(g::AG, v::Int) = fadj(g, v)

"""
    issubset(g, h)

Returns true if all of the vertices and edges of `g` are contained in `h`.
"""
function issubset{T<:AS}(g::T, h::T)
    return nv(g) < nv(h) && issubset(edges(g), edges(h))
end


"""
    add_vertices!(g, n)

Add `n` new vertices to the graph `g`. Returns the final number
of vertices.
"""
function add_vertices!(g::AS, n::Integer)
    added = true
    for i = 1:n
        add_vertex!(g)
    end
    return nv(g)
end


"""
    in_edges(g, v)

Returns an iterable of the edges in `g` that arrive at vertex `v`.
`v = dst(e)` for each returned edge `e`.
"""
in_edges(g::AS, v::Int) = (Edge(x,v) for x in badj(g, v))

"""
    out_edges(g, v)

Returns an Array of the edges in `g` that depart from vertex `v`.
`v = src(e)` for each returned edge `e`.
"""
out_edges(g::AS, v::Int) = (Edge(v,x) for x in fadj(g,v))


"""Return true if `v` is a vertex of `g`."""
has_vertex(g::AS, v::Int) = v in vertices(g)

"""
    nv(g)

The number of vertices in `g`.
"""
nv(g::AS) = length(fadj(g))

add_edge!(g::AS, u::Int, v::Int) = add_edge!(g, Edge(u, v))

rem_edge!(g::AS, u::Int, v::Int) = rem_edge!(g, Edge(u, v))

function show(io::IO, g::AG)
    if nv(g) == 0
        print(io, "empty undirected graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} undirected graph")
    end
end
function show(io::IO, g::AD)
    if nv(g) == 0
        print(io, "empty directed graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} directed graph")
    end
end

==(g::AG, h::AG) =
    vertices(g) == vertices(h) &&
    ne(g) == ne(h) &&
    fadj(g) == fadj(h)

==(g::AD, h::AD) =
    vertices(g) == vertices(h) &&
    ne(g) == ne(h) &&
    fadj(g) == fadj(h) &&
    badj(g) == badj(h)



"""
    is_directed(g)

Check if `g` a graph with directed edges.
"""
is_directed(g::AG) = false
is_directed(g::AD) = true


"""
    has_edge(g, e::Edge)
    has_edge(g, u, v)

Returns true if the graph `g` has an edge `e` (from `u` to `v`).
"""
has_edge(g::AS, u::Int, v::Int) = has_edge(g, Edge(u, v))

function has_edge(g::AG, e::Edge)
    u, v = e
    u > nv(g) || v > nv(g) && return false
    if degree(g,u) > degree(g,v)
        u, v = v, u
    end
    return length(searchsorted(fadj(g,u), v)) > 0
end

function has_edge(g::AD, e::Edge)
    u, v = e
    u > nv(g) || v > nv(g) && return false
    if degree(g,u) < degree(g,v)
        return length(searchsorted(fadj(g,u), v)) > 0
    else
        return length(searchsorted(badj(g,v), u)) > 0
    end
end

"""Return the number of edges which start at vertex `v`."""
indegree(g::AS, v::Int) = length(badj(g,v))
"""Return the number of edges which end at vertex `v`."""
outdegree(g::AS, v::Int) = length(fadj(g,v))

"""
    degree(g, v)

Return the number of edges (both ingoing and outgoing) from the vertex `v`.
"""
degree(g::AG, v::Int) = indegree(g, v)
degree(g::AD, v::Int) = indegree(g, v) + outdegree(g, v)

indegree(g::AS, v::AbstractArray{Int,1} = vertices(g)) = [indegree(g,x) for x in v]
outdegree(g::AS, v::AbstractArray{Int,1} = vertices(g)) = [outdegree(g,x) for x in v]
degree(g::AS, v::AbstractArray{Int,1} = vertices(g)) = [degree(g,x) for x in v]


"""Returns a list of all neighbors connected to vertex `v` by an incoming edge.

NOTE: returns a reference, not a copy. Do not modify result.
"""
in_neighbors(g::AS, v::Int) = badj(g,v)
"""Returns a list of all neighbors connected to vertex `v` by an outgoing edge.

NOTE: returns a reference, not a copy. Do not modify result.
"""
out_neighbors(g::AS, v::Int) = fadj(g,v)

"""Returns a list of all neighbors of vertex `v` in `g`.

For DiGraphs, this is equivalent to `[in_neighbors(g, v); out_neighbors(g, v)]`.

NOTE: returns a reference, not a copy. Do not modify result.
"""
neighbors(g::AG, v::Int) = out_neighbors(g, v)
neighbors(g::AD, v::Int) = [in_neighbors(g, v); out_neighbors(g, v)]


"""
    density(g)

Density is defined as the ratio of the number of actual edges to the
number of possible edges. This is ``|v| |v-1|`` for directed graphs and
``(|v| |v-1|) / 2`` for undirected graphs.
"""
density(g::AG) = (2*ne(g)) / (nv(g) * (nv(g)-1))
density(g::AD) = ne(g) / (nv(g) * (nv(g)-1))
