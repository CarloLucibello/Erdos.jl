# Betweenness centrality measures
# TODO - weighted, separate unweighted, edge betweenness

"""
    betweenness_centrality(g, vlist=1:nv(g); normalize=true, endpoints=false)

Calculates the [betweenness centrality](https://en.wikipedia.org/wiki/Centrality#Betweenness_centrality) of the vertices
in graph `g`.

Betweenness centrality for vertex `v` is defined as:
```math
bc(v) = \\frac{1}{\\mathcal{N}} \\sum_{s \\neq t \\neq v}
        \\frac{\\sigma_{st}(v)}{\\sigma_{st}},
```
where ``\\sigma _{st}} \\sigma_{st}`` is the total number of shortest paths from
node `s` to node `t` and ``\\sigma_{st}(v)``
is the number of those paths that pass through `v`.

If `endpoints=true`, endpoints are included in the shortest path count.

If `normalize=true`, the betweenness values are normalized by the total number
of possible distinct paths between all pairs in the graphs. For an undirected graph,
this number if `((n-1)*(n-2))/2` and for a directed graph, `(n-1)*(n-2)`
where `n` is the number of vertices in the graph.

**References**

[1] Brandes 2001 & Brandes 2008
"""
function betweenness_centrality(
    g::ASimpleGraph,
    normalize=true,
    endpoints=false)

    n_v = nv(g)
    isdir = is_directed(g)

    betweenness = zeros(n_v)
    vlist = 1:nv(g)
    for s in vlist
        if degree(g,s) > 0  # this might be 1?
            state = dijkstra_shortest_paths(g, s; allpaths=true)
            if endpoints
                _accumulate_endpoints!(betweenness, state, g, s)
            else
                _accumulate_basic!(betweenness, state, g, s)
            end
        end
    end

    _rescale!(betweenness, n_v, normalize, isdir, length(vlist))

    return betweenness
end


function _accumulate_basic!(
        betweenness::Vector{Float64},
        state::DijkstraState,
        g::ASimpleGraph,
        si::Integer
    )

    n_v = length(state.parents) # this is the ttl number of vertices
    δ = zeros(n_v)
    σ = state.pathcounts
    P = state.predecessors

    # make sure the source index has no parents.
    P[si] = []
    # we need to order the source nodes by decreasing distance for this to work.
    S = sortperm(state.dists, rev=true)
    for w in S
        coeff = (1.0 + δ[w]) / σ[w]
        for v in P[w]
            if v > 0
                δ[v] += (σ[v] * coeff)
            end
        end
        if w != si
            betweenness[w] += δ[w]
        end
    end
end



function _accumulate_endpoints!(
        betweenness::Vector{Float64},
        state::DijkstraState,
        g::ASimpleGraph,
        si::Integer
    )

    n_v = nv(g) # this is the ttl number of vertices
    δ = zeros(n_v)
    σ = state.pathcounts
    P = state.predecessors
    v1 = [1:n_v;]
    v2 = state.dists
    S = sortperm(state.dists, rev=true)
    s = si
    betweenness[s] += length(S) - 1    # 289

    for w in S
        coeff = (1.0 + δ[w]) / σ[w]
        for v in P[w]
            δ[v] += σ[v] * coeff
        end
        if w != si
            betweenness[w] += (δ[w] + 1)
        end
    end
end

function _rescale!(betweenness::Vector{Float64}, n::Integer, normalize::Bool, directed::Bool, k::Integer)
    if normalize
        if n <= 2
            do_scale = false
        else
            do_scale = true
            scale = 1.0 / ((n - 1) * (n - 2))
        end
    else
        if !directed
            do_scale = true
            scale = 1.0 / 2.0
        else
            do_scale = false
        end
    end
    if do_scale
        if k > 0
            scale = scale * n / k
        end
        betweenness .*= scale
    end
end
