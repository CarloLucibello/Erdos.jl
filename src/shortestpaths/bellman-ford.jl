# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# The Bellman Ford algorithm for single-source shortest path

###################################################################
#
#   The type that capsulates the state of Bellman Ford algorithm
#
###################################################################

struct NegativeCycleError <: Exception end

# AbstractPathState is defined in core
mutable struct BellmanFordState{V,T<:Real} <: AbstractPathState
    parents::Vector{V}
    dists::Vector{T}
end


"""
    bellman_ford_shortest_paths(g, s, distmx=ConstEdgeMap(g,1))
    bellman_ford_shortest_paths(g, sources, distmx=ConstEdgeMap(g,1))

Uses the [Bellman-Ford algorithm](http://en.wikipedia.org/wiki/Bellman–Ford_algorithm)
to compute shortest paths of all vertices of a `g` from a source vertex `s` (or a set of source
vertices `sources`). Returns a `BellmanFordState` with relevant traversal information.
"""
function bellman_ford_shortest_paths(
        g::AGraphOrDiGraph,
        sources::AbstractVector{Int},
        distmx::AEdgeMap{T},
    ) where T<:Real
    state = BellmanFordState(zeros(Int,nv(g)), fill(typemax(T), nv(g)))
    V = vertextype(g)
    active = Set{V}()
    for v in sources
        state.dists[v] = 0
        state.parents[v] = 0
        push!(active, v)
    end
    no_changes = false
    for i in 1:nv(g)
        no_changes = true
        new_active = Set{V}()
        for u in active
            for e in out_edges(g, u)
                v = dst(e)
                edist = distmx[e]
                if state.dists[v] > state.dists[u] + edist
                    state.dists[v] = state.dists[u] + edist
                    state.parents[v] = u
                    no_changes = false
                    push!(new_active, v)
                end
            end
        end
        if no_changes
            break
        end
        active = new_active
    end
    no_changes || throw(NegativeCycleError())
    return state
end

function bellman_ford_shortest_paths(
        g::AGraphOrDiGraph,
        sources::AbstractVector{Int})

    bellman_ford_shortest_paths(g, sources, ConstEdgeMap(g,1))
end

bellman_ford_shortest_paths(
    g::AGraphOrDiGraph,
    v::Int,
    distmx::AEdgeMap=ConstEdgeMap(g,1)
) = bellman_ford_shortest_paths(g, [v], distmx)

function has_negative_edge_cycle(g::AGraphOrDiGraph)
    try
        bellman_ford_shortest_paths(g, vertices(g))
    catch e
        isa(e, NegativeCycleError) && return true
    end
    return false
end
