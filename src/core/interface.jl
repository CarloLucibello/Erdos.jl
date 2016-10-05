"""
Abstract Graph type

Guarantees:
    vertices are integers in 1:nv(g)
    edges are pair of vertices
    sorted adjacency list member (Vector{Vector{Int}})

Functions to implement:
    ne(g)
    fadj(g)
    add_edge!(g, e)
    rem_edge!(g, e)
    add_vertex!(g)
    rem_vertex!(g, v)
    copy(g)
"""
abstract AbstractGraph

"""
Abstract Directed Graph type

Guarantees:
    vertices are integers in 1:nv(g)
    edges are pair of vertices
    sorted forward and backward adjacency list members (Vector{Vector{Int}})

Functions to implement:
    basic constructors
    ne(g)
    fadj(g)
    badj(g)
    add_edge!(g, e)
    rem_edge!(g, e)
    add_vertex!(g)
    rem_vertex!(g, v)
    copy(g)
"""
abstract AbstractDiGraph

"""
Union of `AbstractGraph` and `AbstractDiGraph`
"""
typealias AbstractSimpleGraph Union{AbstractGraph, AbstractDiGraph}

typealias AGraph AbstractGraph
typealias ADiGraph AbstractDiGraph
typealias ASimpleGraph AbstractSimpleGraph

####### Required interface for concrete types ########################
"""
    ne(g)

The number of edges in `g`.

Time Complexity: O(1)
"""
ne(g::ASimpleGraph) = nothing

"""
    fadj(g)
    fadj(g, v)

Returns the forward adjacency list of a graph, i.e. a vector of vectors
containing for each vertex the neighbors though outgoing edges.
The adjacency list is sorted:

    fadj(g) == [sort(collect(out_neighbors(i))) for i=1:nv(g)]

The adjacency list has to be pre-calculated for any user-defined graph.
It is the same as [`adj`](@ref) and [`badj`](@ref) for
undirected graphs.

The second form is defined as

    fadj(g, v::Int) = fadj(g)[v]

NOTE: returns a reference, not a copy. Do not modify result.

Time Complexity: O(1)
"""
fadj(g::ASimpleGraph) = nothing


"""
    badj(g)
    badj(g, v)

Returns the backward adjacency list of a graph.
For each vertex the vector of neighbors though incoming edges.
It is the same as [`adj`](@ref) and [`fadj`](@ref) for
undirected graphs.

The second form is defined as

    badj(g, v::Int) = badj(g)[v]


NOTE: returns a reference, not a copy. Do not modify result.
"""
badj(g::ADiGraph) = nothing

"""
    add_edge!(g, e::Edge)
    add_edge!(g, u, v)

Add to `g` the edge `e` (from `u` to `v`).
Will return false if add fails (e.g., if vertices are not in the graph or the edge
is already present) and true otherwise.
"""
add_edge!(g::ASimpleGraph, e::Edge) = nothing


"""
    rem_edge!(g, e::Edge)
    rem_edge!(g, u, v)

Remove the edge from `u` to `v`.

Returns false if edge removal fails (e.g., if the edge does not exist) and true otherwise.
"""
rem_edge!(g::ASimpleGraph, e::Edge) = nothing


"""
    add_vertex!(g)

Add a new vertex to the graph `g`.
"""
add_vertex!(g::ASimpleGraph) = nothing


"""
    rem_vertex!(g, v)

Remove the vertex `v` from graph `g`.
It may change the index of other vertices (usually of the last one).
"""
rem_vertex!(g::ASimpleGraph, i::Int) = nothing

copy(g::ASimpleGraph) = nothing
