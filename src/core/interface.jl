"""
    abstract AGraph

Abstract undirected graph type
"""
abstract AGraph

"""
    abstract ADiGraph

Abstract directed graph type
"""
abstract ADiGraph

"""
Union of `AGraph` and `ADiGraph`
"""
typealias ASimpleGraph Union{AGraph, ADiGraph}

####### Required interface for concrete types ########################

"""
    nv(g)

The number of vertices in `g`.
"""
nv(g::ASimpleGraph) = error("Method not defined")

"""
    ne(g)

The number of edges in `g`.

Time Complexity: O(1)
"""
ne(g::ASimpleGraph) = error("Method not defined")

"""
    add_edge!(g, e)

Add to `g` the edge `e`.

    add_edge!(g, u, v)

Add to `g` an edge from `u` to `v`.

Will return false if add fails (e.g., if vertices are not in the graph or the edge
is already present) and true otherwise.
"""
add_edge!(g::ASimpleGraph, u, v) = error("Method not defined")


"""
    rem_edge!(g, e)

Remove the edge `e`.

    rem_edge!(g, u, v)

Remove the edge from `u` to `v`.

Returns false if edge removal fails (e.g., if the edge does not exist) and true otherwise.
"""
rem_edge!(g::ASimpleGraph, u, v) = error("Method not defined")


"""
    add_vertex!(g)

Add a new vertex to the graph `g`.
"""
add_vertex!(g::ASimpleGraph) = error("Method not defined")

# length() has to be appliable to the result
"""
    in_neighbors(g, v)

Returns an iterable to all neighbors connected to vertex `v` by an incoming edge.

NOTE: it may return a reference, not a copy. Do not modify result.
"""
in_neighbors(g::ADiGraph, v) = error("Method not defined")

# length() has to be appliable to the result
"""
    out_neighbors(g::ASimpleGraph, v)

Returns an iterable to all neighbors connected to vertex `v` by an outgoing edge.

NOTE: it may return a reference, not a copy. Do not modify result.
"""
out_neighbors(g::ASimpleGraph, v) = error("Method not defined")

"""
    edge(g, u, v)

Returns an edge from 'u' to 'v'. The edge doesn't necessarily exists
in `g`.
"""
edge(g::ASimpleGraph, u, v) = Edge{Int}(u, v)

"""
    edgetype(g)
    edgetype(G)

Returns the type of edges of graph `g` (or graph type `G`).
"""
edgetype{G<:ASimpleGraph}(::Type{G}) = Edge{Int}


"""
    vertextype(g)
    vertextype(G)

Returns the integer type of vertices of graph `g` (or graph type `G`).
"""
vertextype{G<:ASimpleGraph}(::Type{G}) = Int

graphtype{G<:ASimpleGraph}(::Type{G}) = error("Method not defined")
digraphtype{G<:ASimpleGraph}(::Type{G}) = error("Method not defined")

"""
    abstract AEdge

An abstract edge type.
"""
abstract AEdge

"""
    src(e)

Returns the source of an edge.
"""
src(e::AEdge) = error("Method not defined")

"""
    dst(e)

Returns the destination of an edge.
"""
dst(e::AEdge) = error("Method not defined")

"""
    reverse(e)

Returns an edge with swapped `src(e)` and `dst(e)`.
"""
reverse(e::AEdge) = error("Method not defined")

"""
    pop_vertex!(g)

Remove the last vertex of `g`. Equivalent to rem_vertex!(g, nv(g)).
"""
pop_vertex!(g::ASimpleGraph) = error("Method not defined")
