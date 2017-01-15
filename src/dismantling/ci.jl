function ci_dismantling(g::AGraph, l::Integer, niters = nv(g)÷10)
    gnew, h, lneigs = ci_dismantling_init(g, l)
    for it=1:niters
        ci_dismantling_oneiter!(gnew, h, lneigs, l)
        println("edges $(ne(gnew))")
        cc = connected_components(gnew)
        println("num conn comp $(length(cc))")
        println("size max comp $(maximum(length, cc))")
    end
    return gnew
end

function ci_dismantling_init(g, l)
    lneigs = Vector{Vector{Int}}()
    for i=1:nv(g)
        neigs = collect(neighborhood(g, i, l))
        deleteat!(neigs, findfirst(neigs, i))
        push!(lneigs, neigs)
    end

    h = MutableBinaryHeap{Pair{Int,Int},GreaterThan2}(GreaterThan2())
    for i=1:nv(g)
         j = push!(h, i=>ci(g, lneigs[i], i))
         @assert j == i
    end
    return deepcopy(g), h, lneigs
end

function ci_dismantling_oneiter!(g, h, lneigs, l)
    itop, citop = top(h)
    clean_vertex!(g, itop)
    update!(h, itop, itop=>0)
    for j in lneigs[itop]
        neigs = collect(neighborhood(g, j, l))
        deleteat!(neigs, findfirst(neigs, j))
        lneigs[j] = neigs
        # deleteat!(lneigs[j], findfirst(lneigs[j], i))
        update!(h, j, j=>ci(g, lneigs[j], j))
    end
end

function ci(g::AGraph, neigs::Vector, i)
    return sum(degree(g, j) - 1  for j in neigs)  * (degree(g, i) - 1)
end
