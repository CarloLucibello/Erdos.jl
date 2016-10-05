"""
    minimum_weight_perfect_matching{T<:Real}(g, w::Dict{Edge,T})
    minimum_weight_perfect_matching{T<:Real}(g, w::Dict{Edge,T}, cutoff)

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

function minimum_weight_perfect_matching{T<:Real}(g::AGraph, w::Dict{Edge,T}, cutoff, kws...)
    wnew = Dict{Edge, T}()
    for (e, c) in w
        if c <= cutoff
            wnew[e] = c
        end
    end
    return minimum_weight_perfect_matching(g, wnew; kws...)
end

function minimum_weight_perfect_matching{T<:AbstractFloat}(g::AGraph, w::Dict{Edge,T}; tmaxscale=10.)
    wnew = Dict{Edge, Int32}()
    cmax = maximum(values(w))
    cmin = minimum(values(w))
    tmax = typemax(Int32)  / tmaxscale # /10 is kinda arbitrary,
                                # hopefully high enough to not incurr in overflow problems
    for (e, c) in w
        wnew[e] = round(Int32, (c-cmin) / (cmax-cmin) * tmax)
    end
    match = minimum_weight_perfect_matching(g, wnew)
    weight = T(0)
    for i=1:nv(g)
        j = match.mate[i]
        if j > i
            weight += w[Edge(i,j)]
        end
    end
    return MatchingResult(weight, match.mate)
end

function minimum_weight_perfect_matching{T<:Integer}(g::AGraph, w::Dict{Edge,T})
    m = BlossomV.Matching(nv(g))
    for (e, c) in w
        BlossomV.add_edge(m, src(e)-1, dst(e)-1, c)
    end
    BlossomV.solve(m)

    mate = fill(-1, nv(g))
    totweight = T(0)
    for i=1:nv(g)
        j = BlossomV.get_match(m, i-1) + 1
        mate[i] = j <= 0 ? -1 : j
        if i < j
            totweight += w[Edge(i,j)]
        end
    end
    return MatchingResult(totweight, mate)
end
