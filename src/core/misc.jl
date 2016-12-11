"""
    isgraphical(degs::Vector{Int})

Check whether the degree sequence `degs` is graphical, according to
[Erdös-Gallai condition](http://mathworld.wolfram.com/GraphicSequence.html).

Time complexity: O(length(degs)^2)
"""
function isgraphical(degs::Vector{Int})
    iseven(sum(degs)) || return false
    n = length(degs)
    for r=1:n-1
        cond = sum(i->degs[i], 1:r) <= r*(r-1) + sum(i->min(r,degs[i]), r+1:n)
        cond || return false
    end
    return true
end

"Return the maximum `out_degree` of vertices in `g`."
Δout(g) = noallocextreme(out_degree,(>), typemin(Int), g)
"Return the minimum `out_degree` of vertices in `g`."
δout(g) = noallocextreme(out_degree,(<), typemax(Int), g)
"Return the maximum `in_degree` of vertices in `g`."
δin(g)  = noallocextreme(in_degree,(<), typemax(Int), g)
"Return the minimum `in_degree` of vertices in `g`."
Δin(g)  = noallocextreme(in_degree,(>), typemin(Int), g)
"Return the minimum `degree` of vertices in `g`."
δ(g)    = noallocextreme(degree,(<), typemax(Int), g)
"Return the maximum `degree` of vertices in `g`."
Δ(g)    = noallocextreme(degree,(>), typemin(Int), g)

"computes the extreme value of `[f(g,i) for i=i:nv(g)]` without gathering them all"
function noallocextreme(f, comparison, initial, g)
    value = initial
    for i in 1:nv(g)
        funci = f(g, i)
        if comparison(funci, value)
            value = funci
        end
    end
    return value
end

"""
    degree_histogram(g)

Returns a `StatsBase.Histogram` of the degrees of vertices in `g`.
"""
degree_histogram(g::ASimpleGraph) = fit(Histogram, degree(g))

"
    common_neighbors(g, u, v)

Returns the neighbors common to vertices `u` and `v` in `g`."
common_neighbors(g::ASimpleGraph, u::Int, v::Int) = intersect(neighbors(g,u), neighbors(g,v))

"
    common_inneighbors(g, u, v)

Returns the inneighbors common to vertices `u` and `v` in `g`."
common_inneighbors(g::ASimpleGraph, u::Int, v::Int) = intersect(in_neighbors(g,u), in_neighbors(g,v))

"
    common_outneighbors(g, u, v)

Returns the outneighbors common to vertices `u` and `v` in `g`."
common_outneighbors(g::ASimpleGraph, u::Int, v::Int) = intersect(out_neighbors(g,u), out_neighbors(g,v))


"
    has_self_loops(g)

Returns true if `g` has any self loops."

has_self_loops(g::ASimpleGraph) = any(v->has_edge(g, v, v), vertices(g))

"
    num_self_loops(g)

Returns the number of self loops in `g`."
num_self_loops(g::ASimpleGraph) = sum(v->has_edge(g, v, v), vertices(g))
