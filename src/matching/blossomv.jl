"""
    minimum_weight_perfect_matching{T<:Real, E}(g, w::Dict{E,T} [,cutoff])

Given a graph `g` and an edgemap `w` containing weights associated to edges,
returns a matching with the mimimum total weight among the ones containing
exactly `nv(g)/2` edges.

Edges in `g` not present in `w` will not be considered for the matching.

This function relies on the BlossomV.jl package, a julia wrapper
around Kolmogorov's BlossomV algorithm.

Eventually a `cutoff` argument can be given, to the reduce computational time
excluding edges with weights higher than the cutoff.

The returned object is of type `MatchingResult`.

In case of error try to change the optional argument `tmaxscale` (default is `tmaxscale=10`).
"""
function minimum_weight_perfect_matching end

function minimum_weight_perfect_matching{T<:AbstractFloat, E}(g::AGraph, w::Dict{E,T}
        , cutoff = typemax(T); tmaxscale=10.)
    cmax = convert(T, min(maximum(values(w)), cutoff))
    cmin = minimum(values(w))
    tmax = typemax(Int32)  / tmaxscale # /10 is kinda arbitrary,
                                # hopefully high enough to not incurr in overflow problems
    wnew = Dict{E, Int32}()
    for (e, c) in w
        if c < cutoff
            wnew[e] = round(Int32, (c-cmin) / (cmax-cmin) * tmax)
        end
    end
    match = minimum_weight_perfect_matching(g, wnew)
    weight = T(0)
    for i=1:nv(g)
        j = match.mate[i]
        if j > i
            weight += w[E(g, i, j)]
        end
    end
    return MatchingResult(weight, match.mate)
end

function minimum_weight_perfect_matching{T<:Integer, E}(g::AGraph, w::Dict{E,T}, cutoff = typemax(T))
    m = BlossomV.Matching(nv(g))
    for (e, c) in w
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
            totweight += w[E(i,j)]
        end
    end
    return MatchingResult(totweight, mate)
end
