# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# The concept and trivial implementation of graph visitors

abstract SimpleGraphVisitor

# trivial implementation

# invoked when a vertex v is encountered for the first time
# this function returns whether to continue search
discover_vertex!(vis::SimpleGraphVisitor, v) = true

# invoked when the algorithm is about to examine v's neighbors
open_vertex!(vis::SimpleGraphVisitor, v) = true

# invoked when a neighbor is discovered & examined
examine_neighbor!(vis::SimpleGraphVisitor, u, v, ucolor, vcolor, ecolor) = true

# invoked when all of v's neighbors have been examined
close_vertex!(vis::SimpleGraphVisitor, v) = true


type TrivialGraphVisitor <: SimpleGraphVisitor
end


# This is the common base for BreadthFirst and DepthFirst
abstract SimpleGraphVisitAlgorithm

###########################################################
#
#   General algorithms based on graph traversal
#
###########################################################

# List vertices by the order of being discovered

type VertexListVisitor <: SimpleGraphVisitor
    vertices::Vector{Int}

    function VertexListVisitor(n::Integer=0)
        vs = Vector{Int}()
        sizehint!(vs, n)
        new(vs)
    end
end

function discover_vertex!(visitor::VertexListVisitor, v)
    push!(visitor.vertices, v)
    return true
end

function visited_vertices(
    g::ASimpleGraph,
    alg::SimpleGraphVisitAlgorithm,
    sources)

    visitor = VertexListVisitor(nv(g))
    traverse_graph!(g, alg, sources, visitor)
    return visitor.vertices
end


# Print visit log

type LogGraphVisitor{S<:IO} <: SimpleGraphVisitor
    io::S
end

function discover_vertex!(vis::LogGraphVisitor, v)
    println(vis.io, "discover vertex: $v")
    return true
end

function open_vertex!(vis::LogGraphVisitor, v)
    println(vis.io, "open vertex: $v")
    return true
end

function close_vertex!(vis::LogGraphVisitor, v)
    println(vis.io, "close vertex: $v")
    return true
end

function examine_neighbor!(vis::LogGraphVisitor, u, v, ucolor, vcolor, ecolor)
    println(vis.io, "examine neighbor: $u -> $v (ucolor = $ucolor, vcolor = $vcolor, edgecolor= $ecolor)")
    return true
end

function traverse_graph_withlog(
    g::ASimpleGraph,
    alg::SimpleGraphVisitAlgorithm,
    sources,
    io::IO = STDOUT
)
    visitor = LogGraphVisitor(io)
    return traverse_graph!(g, alg, sources, visitor)
end
