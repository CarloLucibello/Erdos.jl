# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# Maximum adjacency visit / traversal


#################################################
#
#  Maximum adjacency visit
#
#################################################

struct MaximumAdjacency <: SimpleGraphVisitAlgorithm end

abstract type AbstractMASVisitor <: SimpleGraphVisitor end

function maximum_adjacency_visit_impl!(
    g::AGraphOrDiGraph,	                      # the graph
    pq::PriorityQueue{Int, T},               # priority queue
    visitor::AbstractMASVisitor,                      # the visitor
    colormap::Vector{Int}) where T                            # traversal status

    while !isempty(pq)
        u = dequeue!(pq)
        discover_vertex!(visitor, u)
        for v in out_neighbors(g, u)
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
    g::AGraphOrDiGraph,
    T::DataType,
    alg::MaximumAdjacency,
    s,
    visitor::AbstractMASVisitor,
    colormap::Vector{Int})

    pq = PriorityQueue{Int,T,typeof(Base.Order.Reverse)}(Base.Order.Reverse)

    # Set number of visited neighbors for all vertices to 0
    for v in vertices(g)
        pq[v] = zero(T)
    end

    @assert haskey(pq,s)
    @assert nv(g) >= 2

    #Give the starting vertex high priority
    pq[s] = one(T)

    #start traversing the graph
    maximum_adjacency_visit_impl!(g, pq, visitor, colormap)
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

mutable struct MinCutVisitor{G,T,EM} <: AbstractMASVisitor
    g::G
    parities::BitVector
    colormap::Vector{Int}
    bestweight::T
    cutweight::T
    visited::Int
    distmx::EM
    vertices::Vector{Int}
end

function MinCutVisitor(g::AGraphOrDiGraph, distmx::AEdgeMap)
    n = nv(g)
    parities = falses(n)
    T = valtype(distmx)
    return MinCutVisitor(
        g,
        falses(n),
        zeros(Int,n),
        typemax(T),
        zero(T),
        0,
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

    if vis.cutweight < vis.bestweight && vis.visited < nv(vis.g)
        vis.bestweight = vis.cutweight
        for u in vertices(vis.g)
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

mutable struct MASVisitor{EM,I<:IO} <: AbstractMASVisitor
    io::I
    vertices::Vector{Int}
    distmx::EM
    log::Bool
end

function discover_vertex!(visitor::MASVisitor{T}, v) where T
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
    minimum_cut(g, dist_edge map=ConstEdgeMap(g,1))

Finds the `cut` of minimum total weight.

Returns a tuple `(f, cut, labels)`, where `f` is the weight of the cut,
`cut` is a vector of the edges in the cut, and `labels` gives a partitioning
of the vertices in two sets, according to the cut.
An optional `dist_matrix` edge map maybe specified; if omitted, edge distances are assumed to be 1.
"""
function minimum_cut(
        g::AGraphOrDiGraph,
        distmx::AEdgeMap
    )
    T = valtype(distmx)
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

minimum_cut(g::AGraphOrDiGraph) = minimum_cut(g, ConstEdgeMap(g,1))

"""
    maximum_adjacency_visit(
        g,
        distmx::AEdgeMap=ConstEdgeMap(g,1);
        log::Bool=false,
        io::IO=STDOUT
    )

Returns the vertices in `g` traversed by maximum adjacency search. An optional
`distmx` edge map may be specified; if omitted, edge distances are assumed to
be 1. If `log` (default `false`) is `true`, visitor events will be printed to
`io`, which defaults to `STDOUT`; otherwise, no event information will be
displayed.
"""
function maximum_adjacency_visit(
        g::AGraphOrDiGraph,
        distmx::AEdgeMap=ConstEdgeMap(g,1);
        log::Bool=false,
        io::IO=stdout
    )
    visitor = MASVisitor(io, Vector{Int}(), distmx, log)
    traverse_graph!(g, valtype(distmx), MaximumAdjacency(), 1, visitor, zeros(Int, nv(g)))
    return visitor.vertices
end
