"""
    dismantle_ci(g::AGraph, l::Integer, nrem; verbose=false)

Applies the Collective Influence (CI) heuristic of Ref. [1]  with distance parameter `l` (tipically `l=3,4`).
Removes a maximum of `nrem` vertices from `g`, trying to minimize the size of the
maximum connected component of the resulting graph. It stops earlier
if the maximum CI goes to zero.

Set `verbose` to `true` for info printing in each iteration.

Returns `(gnew, vmap, remlist)`, where `gnew` is the reduced graph, `vmap`
is a vertex map of the vertices of `gnew` to the old ones (see also [`rem_vertices!`](@ref))
and `remlist` contains the removed vertices by removal order.

For more fine grained control see [`dismantle_ci_init`](@ref) and
[`dismantle_ci_oneiter!`](@ref).

**Usage**
```julia
g = Graph(100, 1000)
l=3
nrem=10
gnew, vmap, remlist = dismantle_ci(g, l, nrem)

# or equivalently
gnew, heap, lneigs = dismantle_ci_init(g, l)

for it=1:nrem
    irem = dismantle_ci_oneiter!(gnew, heap, lneigs, l)
    irem <= 0 && break
    push!(remlist, irem)
    println("Size Max Component: ", maximum(length, connected_components(g)))
end
vmap = rem_vertices!(gnew, remlist)
```

[1] Morone F., Makse H.
Influence maximization in complex networks through optimal percolation.
Nature (2015)
"""
function dismantle_ci(g::AGraph, l::Integer, nrem::Integer; verbose = false)
    @assert nrem >= 0
    gnew, heap, lneigs = dismantle_ci_init(g, l)
    remlist = Int[]
    for it=1:nrem
        irem = dismantle_ci_oneiter!(gnew, heap, lneigs, l)
        irem < 0 && break
        verbose && println("iter $it: removed $irem")
        push!(remlist, irem)
    end
    vmap = rem_vertices!(gnew, remlist)
    return gnew, vmap, remlist
end

"""
    dismantle_ci_init(g, l)

Initialization part of [`dismantle_ci`](@ref) algorithm.
Returns `(gnew, heap, lneigs)`.
"""
function dismantle_ci_init(g::AGraph, l::Integer)
    lneigs = [neighborhood(g, i, l) for i=1:nv(g)]
    h = MutableBinaryHeap{Pair{Int,Int},GreaterThan2}(GreaterThan2())
    for i=1:nv(g)
         j = push!(h, i=>ci(g, lneigs[i], i))
    end
    return deepcopy(g), h, lneigs
end

"""
    dismantle_ci_oneiter!(g, heap, lneigs, l)

One step of [`dismantle_ci`](@ref) algorithm.
To be called after [`dismantle_ci_init`](@ref)
Returns the cleaned vertex if any (see [`clean_vertex!`](@ref)), -1 otherwise.
"""
function dismantle_ci_oneiter!{T}(g::AGraph, h, lneigs::Vector{Vector{T}}, l::Integer)
    itop, citop = top(h)
    citop < 0 && return -1
    clean_vertex!(g, itop)
    neigstop = collect(lneigs[itop])
    for j in neigstop
        lneigs[j] = neighborhood(g, j, l)
        updateheap!(g, h, j, lneigs[j])
    end
    return itop
end

function ci(g::AGraph, neigs::Vector, i::Int)
    zi = degree(g, i)- 1
    zi == -1 && return -1
    return sum(degree(g,j)-1  for j in neigs) * zi
end

updateheap!(g::AGraph, h, j::Int, neigs::Vector) = update!(h, j, j=>ci(g, neigs, j))
updateheap!{T}(g::AGraph, h, j::T, neigs::Vector) = updateheap!(g, h, Int(j), neigs)
