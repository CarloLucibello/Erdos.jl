# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# A* shortest-path algorithm

function a_star_impl!{T<:Number}(
    graph::ASimpleGraph,# the graph
    t::Int, # the end vertex
    frontier,               # an initialized heap containing the active vertices
    colormap::Vector{Int},  # an (initialized) color-map to indicate status of vertices
    distmx::AbstractArray{T, 2},
    heuristic::Function    # heuristic fn (under)estimating distance to target
    )

    while !isempty(frontier)
        (cost_so_far, path, u) = dequeue!(frontier)
        if u == t
            return path
        end

        for v in out_neighbors(graph, u)

            if colormap[v] < 2
                dist = distmx[u, v]

                colormap[v] = 1
                new_path = cat(1, path, Edge(u,v))
                path_cost = cost_so_far + dist
                enqueue!(frontier,
                        (path_cost, new_path, v),
                        path_cost + heuristic(v))
            end
        end
        colormap[u] = 2
    end
    nothing
end

"""Computes the shortest path between vertices `s` and `t` using the
[A\* search algorithm](http://en.wikipedia.org/wiki/A%2A_search_algorithm). An
optional heuristic function and edge distance matrix may be supplied.
"""
function a_star{T<:Number}(
    graph::ASimpleGraph,  # the graph

    s::Int,                       # the start vertex
    t::Int,                       # the end vertex
    distmx::AbstractArray{T, 2} = FatGraphs.DefaultDistance(),
    heuristic::Function = n -> 0
    )
            # heuristic (under)estimating distance to target
    frontier = PriorityQueue(Tuple{T,Array{Edge,1},Int},T)
    frontier[(zero(T), Vector{Edge}(), s)] = zero(T)
    colormap = zeros(Int, nv(graph))
    colormap[s] = 1
    a_star_impl!(graph, t, frontier, colormap, distmx, heuristic)
end
