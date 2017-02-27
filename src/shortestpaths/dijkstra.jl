@compat abstract type AbstractDijkstraState <: AbstractPathState end

immutable DijkstraHeapEntry{T}
    vertex::Int
    dist::T
end

isless(e1::DijkstraHeapEntry, e2::DijkstraHeapEntry) = e1.dist < e2.dist

type DijkstraState{T}<: AbstractDijkstraState
    parents::Vector{Int}
    dists::Vector{T}
    predecessors::Vector{Vector{Int}}
    pathcounts::Vector{Int}
end

"""
    dijkstra_shortest_paths(g, s, distmx=ConstEdgeMap(g,1); allpaths=false)
    dijkstra_shortest_paths(g, sources, distmx=ConstEdgeMap(g,1); allpaths=false)

Performs [Dijkstra's algorithm](http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm)
on a graph, computing shortest distances between a source vertex `s` (or a vector
`sources`)  and all other veritces.
Returns a `DijkstraState` that contains various traversal information.

With `allpaths=true`, returns a `DijkstraState` that keeps track of all
predecessors of a given vertex.
"""
function dijkstra_shortest_paths(
        g::ASimpleGraph,
        srcs::Vector{Int},
        distmx::AEdgeMap=ConstEdgeMap(g,1);
        allpaths=false
    )
    T = valtype(distmx)
    nvg = nv(g)
    dists = fill(typemax(T), nvg)
    parents = zeros(Int, nvg)
    preds = fill(Vector{Int}(),nvg)
    visited = zeros(Bool, nvg)
    pathcounts = zeros(Int, nvg)
    H = Vector{DijkstraHeapEntry{T}}()  # this should be Vector{T}() in 0.4, I think.
    dists[srcs] = zero(T)
    pathcounts[srcs] = 1

    sizehint!(H, nvg)

    for v in srcs
        heappush!(H, DijkstraHeapEntry{T}(v, dists[v]))
    end

    while !isempty(H)
        hentry = heappop!(H)
        # info("Popped H - got $(hentry.vertex)")
        u = hentry.vertex
        for e in out_edges(g,u)
            v = dst(e)
            alt = (dists[u] == typemax(T))? typemax(T) : dists[u] + distmx[e]

            if !visited[v]
                dists[v] = alt
                parents[v] = u
                pathcounts[v] += pathcounts[u]
                visited[v] = true
                if allpaths
                    preds[v] = [u;]
                end
                heappush!(H, DijkstraHeapEntry{T}(v, alt))
                # info("Pushed $v")
            else
                if alt < dists[v]
                    dists[v] = alt
                    parents[v] = u
                    heappush!(H, DijkstraHeapEntry{T}(v, alt))
                end
                if alt == dists[v]
                    pathcounts[v] += pathcounts[u]
                    if allpaths
                        push!(preds[v], u)
                    end
                end
            end
        end
    end

    dists[srcs] = zero(T)
    pathcounts[srcs] = 1
    parents[srcs] = 0
    for src in srcs
        preds[src] = []
    end

    return DijkstraState{T}(parents, dists, preds, pathcounts)
end

dijkstra_shortest_paths(g::ASimpleGraph, src::Int, distmx::AEdgeMap=ConstEdgeMap(g,1); allpaths=false) =
  dijkstra_shortest_paths(g, [src;], distmx; allpaths=allpaths)
