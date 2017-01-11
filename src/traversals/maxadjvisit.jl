# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# Maximum adjacency visit / traversal


#################################################
#
#  Maximum adjacency visit
#
#################################################

type MaximumAdjacency <: SimpleGraphVisitAlgorithm
end

abstract AbstractMASVisitor <: SimpleGraphVisitor

function maximum_adjacency_visit_impl!{T}(
    graph::ASimpleGraph,	                      # the graph
    pq::PriorityQueue{Int, T},               # priority queue
    visitor::AbstractMASVisitor,                      # the visitor
    colormap::Vector{Int})                            # traversal status

    while !isempty(pq)
        u = dequeue!(pq)
        discover_vertex!(visitor, u)
        for v in out_neighbors(graph, u)
            examine_neighbor!(visitor, u, v, 0, 0, 0)

            if haskey(pq,v)
                ed = visitor.distmx[u, v]
                pq[v] += ed
            end
        end
        close_vertex!(visitor, u)
    end

end

function traverse_graph!(
    graph::ASimpleGraph,
    T::DataType,
    alg::MaximumAdjacency,
    s,
    visitor::AbstractMASVisitor,
    colormap::Vector{Int})


    pq = PriorityQueue(Int,T,Base.Order.Reverse)

    # Set number of visited neighbors for all vertices to 0
    for v in vertices(graph)
        pq[v] = zero(T)
    end

    @assert haskey(pq,s)
    @assert nv(graph) >= 2

    #Give the starting vertex high priority
    pq[s] = one(T)

    #start traversing the graph
    maximum_adjacency_visit_impl!(graph, pq, visitor, colormap)
end


#################################################
#
#  Visitors
#
#################################################


#################################################
#
#  Minimum Cut Visitor
#
#################################################

type MinCutVisitor{T} <: AbstractMASVisitor
    graph::ASimpleGraph
    parities::AbstractArray{Bool,1}
    colormap::Vector{Int}
    bestweight::T
    cutweight::T
    visited::Integer
    distmx::AbstractArray{T, 2}
    vertices::Vector{Int}
end

function MinCutVisitor{T}(graph::ASimpleGraph, distmx::AbstractArray{T, 2})
    n = nv(graph)
    parities = falses(n)
    return MinCutVisitor(
        graph,
        falses(n),
        zeros(Int,n),
        typemax(T),
        zero(T),
        zero(Int),
        distmx,
        Vector{Int}()
    )
end

function discover_vertex!(vis::MinCutVisitor, v)
    vis.parities[v] = false
    vis.colormap[v] = 1
    push!(vis.vertices,v)
    return true
end

function examine_neighbor!(vis::MinCutVisitor, u, v, ucolor, vcolor, ecolor)
    ew = vis.distmx[u, v]

    # if the target of e is already marked then decrease cutweight
    # otherwise, increase it

    if vis.colormap[v] != vcolor # here vcolor is 0
        vis.cutweight -= ew
    else
        vis.cutweight += ew
    end
    return true
end

function close_vertex!(vis::MinCutVisitor, v)
    vis.colormap[v] = 2
    vis.visited += 1

    if vis.cutweight < vis.bestweight && vis.visited < nv(vis.graph)
        vis.bestweight = vis.cutweight
        for u in vertices(vis.graph)
            vis.parities[u] = ( vis.colormap[u] == 2)
        end
    end
    return true
end

#################################################
#
#  MAS Visitor
#
#################################################

type MASVisitor{T} <: AbstractMASVisitor
    io::IO
    vertices::Vector{Int}
    distmx::AbstractArray{T, 2}
    log::Bool
end

function discover_vertex!{T}(visitor::MASVisitor{T}, v)
    push!(visitor.vertices,v)
    visitor.log ? println(visitor.io, "discover vertex: $v") : nothing
    return true
end

function examine_neighbor!(visitor::MASVisitor, u, v, ucolor, vcolor, ecolor)
    visitor.log ? println(visitor.io, " -- examine neighbor from $u to $v") : nothing
    return true
end

function close_vertex!(visitor::MASVisitor, v)
    visitor.log ? println(visitor.io, "close vertex: $v") : nothing
    return true
end

#################################################
#
#  Minimum Cut
#
#################################################



"""
    minimum_cut(g, dist_matrix=DefaultDistance())

Finds the `cut` of minimum total weight.

Returns a tuple `(f, cut, labels)`, where `f` is the weight of the cut,
`cut` is a vector of the edges in the cut, and `labels` gives a partitioning
of the vertices in two sets, according to the cut.
An optional `dist_matrix` matrix maybe specified; if omitted, edge distances are assumed to be 1.
"""
function minimum_cut{T}(
        g::ASimpleGraph,
        distmx::AbstractMatrix{T}
    )
    visitor = MinCutVisitor(g, distmx)
    colormap = zeros(Int, nv(g))
    traverse_graph!(g, T, MaximumAdjacency(), 1, visitor, colormap)
    labels = visitor.parities + 1
    E = edgetype(g)
    cut = Vector{E}()
    for e in edges(g)
        if labels[src(e)] != labels[dst(e)]
            push!(cut, e)
        end
    end
    return visitor.bestweight, cut, labels
end

minimum_cut(graph::ASimpleGraph) = minimum_cut(graph, DefaultDistance())

"""Returns the vertices in `g` traversed by maximum adjacency search. An optional
`distmx` matrix may be specified; if omitted, edge distances are assumed to
be 1. If `log` (default `false`) is `true`, visitor events will be printed to
`io`, which defaults to `STDOUT`; otherwise, no event information will be
displayed.
"""
function maximum_adjacency_visit{T}(
    graph::ASimpleGraph,
    distmx::AbstractArray{T, 2},
    log::Bool,
    io::IO
)
    visitor = MASVisitor(io, Vector{Int}(), distmx, log)
    traverse_graph!(graph, T, MaximumAdjacency(), 1, visitor, zeros(Int, nv(graph)))
    return visitor.vertices
end

maximum_adjacency_visit(graph::ASimpleGraph) = maximum_adjacency_visit(
    graph,
    DefaultDistance(),
    false,
    STDOUT
)
