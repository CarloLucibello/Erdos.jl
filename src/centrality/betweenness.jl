# Betweenness centrality measures
# TODO - weighted, separate unweighted, edge betweenness

"""
    betweenness_centrality(g; normalize=true, endpoints=false, approx=-1)

Calculates the [betweenness centrality](https://en.wikipedia.org/wiki/Centrality#Betweenness_centrality) of the vertices
of graph `g`.

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
of possible distinct paths between all pairs in the graph. For an undirected graph,
this number if `((n-1)*(n-2))/2` and for a directed graph, `(n-1)*(n-2)`
where `n` is the number of vertices in the graph.

If  an integer argument `approx > 0` is given, returns an approximation of
the betweenness centrality of each vertex of the graph involving `approx`
randomly chosen vertices.

**References**

[1] Brandes 2001 & Brandes 2008
"""function betweenness_centrality(
    g::ASimpleGraph;
    approx::Int=-1,
    normalize::Bool=true,
    endpoints::Bool=false)

    n_v = nv(g)
    betweenness = zeros(n_v)
    if approx <= 0
        nodes = [1:n_v;]
    else
        nodes = sample!([1:n_v;], approx)   #112
    end
    for s in nodes
        if degree(g,s) > 0  # this might be 1?
            state = dijkstra_shortest_paths(g, s; allpaths=true)
            if endpoints
                _accumulate_endpoints!(betweenness, state, g, s)
            else
                _accumulate_basic!(betweenness, state, g, s)
            end
        end
    end

    _rescale!(betweenness, n_v, normalize, is_directed(g), length(nodes))

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
        scale = scale * n / k
        betweenness .*= scale
    end
end
