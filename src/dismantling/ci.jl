"""
    dismantle_ci(g::AGraph, l::Integer, nrem = -1)

Applies the CI heuristic distance with distance parameter `l` (tipically `l=3,4`),
to remove `nrem` vertices from `g` while trying to minimize the size of the
maximum connected component of the resulting graph.
If `nrem < 0` stops when the maximum influence is zero.

Returns `gnew, remlist`.
"""
function dismantle_ci(g::AGraph, l::Integer, nrem = -1)
    gnew, heap, lneigs = dismantle_ci_init(g, l)
    remlist = Int[]
    for it=1:nrem
        irem = dismantle_ci_oneiter!(gnew, heap, lneigs, l)
        irem <= 0 && break
        push!(remlist, irem)
    end
    return gnew, remlist
end

function dismantle_ci_init(g::AGraph, l::Integer)
    lneigs = [neighborhood(g, i, l) for i=1:nv(g)]
    h = MutableBinaryHeap{Pair{Int,Int},GreaterThan2}(GreaterThan2())
    for i=1:nv(g)
         j = push!(h, i=>ci(g, lneigs[i], i))
    end
    return deepcopy(g), h, lneigs
end

function dismantle_ci_oneiter!(g::AGraph, h, lneigs::Vector{Vector}, l::Integer)
    itop, citop = top(h)
    citop <= 0 && return -1
    clean_vertex!(g, itop)
    neigstop = collect(lneigs[itop])
    for j in neigstop
        lneigs[j] = neighborhood(g, j, l)
        update!(h, j, j=>ci(g, lneigs[j], j))
    end
    return itop
end

function ci(g::AGraph, neigs::Vector, i::Integer)
    return (sum(degree(g, j) - 1  for j in neigs) - (degree(g, i) - 1))* (degree(g, i) - 1)
end
