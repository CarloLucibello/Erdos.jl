"""
    abstract type AEdge end

An abstract edge type.
"""
abstract type AEdge end

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
    abstract type AGraph end

Abstract undirected graph type
"""
abstract type AGraph end

"""
    abstract ADiGraph

Abstract directed graph type
"""
abstract type ADiGraph end

"""
    const AGraphOrDiGraph = Union{AGraph, ADiGraph}

Union of [`AGraph`](@ref) and [`ADiGraph`](@ref).
"""
const AGraphOrDiGraph = Union{AGraph, ADiGraph}

####### Required interface for concrete types ########################

"""
    nv(g)

The number of vertices in `g`.
"""
nv(g::AGraphOrDiGraph) = error("Method not defined")

"""
    ne(g)

The number of edges in `g`.

Time Complexity: O(1)
"""
ne(g::AGraphOrDiGraph) = error("Method not defined")

"""
    add_edge!(g, e) -> (ok, new_edge)

Add to `g` the edge `e`.

    add_edge!(g, u, v) -> (ok, new_edge)

Add to `g` an edge from `u` to `v`.

`ok=false` if add fails (e.g. if vertices are not in the graph or the edge
is already present) and `true` otherwise.
`new_edge` is the descriptor of the new edge.
"""
add_edge!(g::AGraphOrDiGraph, u, v) = error("Method not defined")


"""
    rem_edge!(g, e)

Remove the edge `e`.

    rem_edge!(g, u, v)

Remove the edge from `u` to `v`.

Returns false if edge removal fails (e.g., if the edge does not exist) and true otherwise.
"""
rem_edge!(g::AGraphOrDiGraph, u, v) = error("Method not defined")


"""
    add_vertex!(g)

Add a new vertex to the graph `g`.
"""
add_vertex!(g::AGraphOrDiGraph) = error("Method not defined")

# length() has to be appliable to the result
"""
    in_neighbors(g, v)

Returns an iterable to all neighbors connected to vertex `v` by an incoming edge.

NOTE: it may return a reference, not a copy. Do not modify result.
"""
in_neighbors(g::ADiGraph, v) = error("Method not defined")

# length() has to be appliable to the result
"""
    out_neighbors(g::AGraphOrDiGraph, v)

Returns an iterable to all neighbors connected to vertex `v` by an outgoing edge.

NOTE: it may return a reference, not a copy. Do not modify result.
"""
out_neighbors(g::AGraphOrDiGraph, v) = error("Method not defined")

"""
    edge(g, u, v)

Returns an edge from 'u' to 'v'. The edge doesn't necessarily exists
in `g`.
"""
edge(g::AGraphOrDiGraph, u, v) = Edge{Int}(u, v)

#TODO check consistency
"""
    edgetype(g)
    edgetype(G)

Returns the type of edges of graph `g` (or graph type `G`), i. e.
the element type returned of the iterator `edges(g)`.
"""
edgetype(::Type{G}) where {G<:AGraphOrDiGraph} = Edge{Int}


"""
    vertextype(g)
    vertextype(G)

Returns the integer type of vertices of graph `g` (or graph type `G`).
"""
vertextype(::Type{G}) where {G<:AGraphOrDiGraph} = Int

"""
    graphtype{G<:AGraphOrDiGraph}(::Type{G})

The graph type corresponding to `G`. If `G<:AGraph` returns `G`,
if `G<:ADiGraph` returns a type `H<:AGraph`.
"""
graphtype(::Type{G}) where {G<:AGraphOrDiGraph} = error("Method not defined")

"""
    digraphtype{G<:AGraphOrDiGraph}(::Type{G})

The digraph type corresponding to `G`. If `G<:ADiGraph` returns `G`,
if `G<:AGraph` returns a type `H<:ADiGraph`.
"""
digraphtype(::Type{G}) where {G<:AGraphOrDiGraph} = error("Method not defined")

"""
    pop_vertex!(g)

Remove the last vertex of `g`. Equivalent to rem_vertex!(g, nv(g)).
"""
pop_vertex!(g::AGraphOrDiGraph) = error("Method not defined")

"""
    swap_vertices!(g, u, v)

Swap the labels of vertices `u` and `v`.
In the new graph all old neighbors of vertex `u` will be neighbors of `v` and
viceversa.
"""
swap_vertices!(g::AGraphOrDiGraph, u::Integer, v::Integer) = error("Method not defined")
