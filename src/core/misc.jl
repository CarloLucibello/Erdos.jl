"""
    is_graphical(degs::Vector{Int})

Check whether the degree sequence `degs` is graphical, according to
[Erdös-Gallai condition](http://mathworld.wolfram.com/GraphicSequence.html).

Time complexity: O(length(degs)^2)
"""
function is_graphical(degs::Vector{Int})
    iseven(sum(degs)) || return false
    n = length(degs)
    cumdeg = cumsum(degs)
    for r=1:n-1
        cond = cumdeg[r] <= r*(r-1) + sum(i->min(r,degs[i]), r+1:n)
        cond || return false
    end
    return true
end

"""
    has_self_loops(g)

Returns true if `g` has any self loops.
"""
has_self_loops(g::AGraphOrDiGraph) = any(v->has_edge(g, v, v), vertices(g))

"""
    num_self_loops(g)

Returns the number of self loops in `g`.
"""
num_self_loops(g::AGraphOrDiGraph) = count(v->has_edge(g, v, v), vertices(g))
