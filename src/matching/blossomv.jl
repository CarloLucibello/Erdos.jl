"""
    minimum_weight_perfect_matching{T}(g, weights::AEdgeMap{T}, cutoff=typemax{T})

Given a graph `g` and an edgemap `weights` containing non-negative weights associated
to edges, returns a matching with the mimimum total weight among the ones containing
exactly `nv(g)/2` edges.

Edges in `g` not present in `weights` will not be considered for the matching.
The returned object is of type `MatchingResult`.

To reduce computational time, a `cutoff` argument can be given. Only edges
with weight lower than `cutoff` will be considered for the matching.

This function relies on the BlossomV.jl package, a julia wrapper
around Kolmogorov's BlossomV algorithm.
"""
function minimum_weight_perfect_matching{T<:Real}(
        g::AGraph,
        w::AEdgeMap{T},
        cutoff = typemax(T))

    m = BlossomV.Matching(T, nv(g))
    for e in edges(g)
        c = get(w, e, cutoff)
        if c < cutoff
            BlossomV.add_edge(m, src(e)-1, dst(e)-1, c)
        end
    end
    BlossomV.solve(m)

    mate = fill(-1, nv(g))
    totweight = T(0)
    for i=1:nv(g)
        j = BlossomV.get_match(m, i-1) + 1
        mate[i] = j <= 0 ? -1 : j
        if i < j
            totweight += w[i, j]
        end
    end
    return MatchingResult(totweight, mate)
end
