abstract AbstractPathState

include("astar.jl")
include("bellman-ford.jl")
include("dijkstra.jl")
include("floyd-warshall.jl")

"""
    shortest_paths(g, x...; kws...)

Computes shortest paths using Dijkstra's algorithm.
See [`dijkstra_shortest_paths`](ref).
"""
shortest_paths(g::ASimpleGraph, x...; kws...) = dijkstra_shortest_paths(g, x...; kws...)

"""
    enumerate_paths(state::AbstractPathState)
    enumerate_paths(state::AbstractPathState, dest)

Given a path state `state` of type `AbstractPathState` (see below), returns a
vector (indexed by vertex) of the paths between the source vertex used to
compute the path state and a destination vertex `v`, a set of destination
vertices `vs`, or the entire graph. For multiple destination vertices, each
path is represented by a vector of vertices on the path between the source and
the destination. Nonexistent paths will be indicated by an empty vector. For
single destinations, the path is represented by a single vector of vertices,
and will be length 0 if the path does not exist.

For Floyd-Warshall path states, please note that the output is a bit different,
since this algorithm calculates all shortest paths for all pairs of vertices:
`enumerate_paths(state)` will return a vector (indexed by source vertex) of
vectors (indexed by destination vertex) of paths. `enumerate_paths(state, v)`
will return a vector (indexed by destination vertex) of paths from source `v`
to all other vertices. In addition, `enumerate_paths(state, v, d)` will return
a vector representing the path from vertex `v` to vertex `d`.
"""
enumerate_paths(state::AbstractPathState, dest) = enumerate_paths(state, [dest])[1]
enumerate_paths(state::AbstractPathState) = enumerate_paths(state, [1:length(state.parents);])

function enumerate_paths{V}(state::AbstractPathState, dest::Vector{V})
    parents = state.parents

    num_dest = length(dest)
    all_paths = Vector{Vector{V}}(num_dest)
    for i=1:num_dest
        all_paths[i] = Vector{V}()
        index = dest[i]
        if parents[index] != 0 || parents[index] == index
            while parents[index] != 0
                push!(all_paths[i], index)
                index = parents[index]
            end
            push!(all_paths[i], index)
            reverse!(all_paths[i])
        end
    end
    return all_paths
end
