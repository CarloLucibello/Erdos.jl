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
    sorted  forward and backward adjacency list members (Vector{Vector{Int}})

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

typealias AG AbstractGraph
typealias AD AbstractDiGraph
typealias AS AbstractSimpleGraph

####### Required interface for concrete types ########################
ne(g::AS) = nothing
fadj(g::AS) = nothing
badj(g::AD) = nothing
add_edge!(g::AS, e::Edge) = nothing
rem_edge!(g::AS, e::Edge) = nothing
add_vertex!(g::AS) = nothing
rem_vertex!(g::AS, i::Int) = nothing
copy(g::AS) = nothing
