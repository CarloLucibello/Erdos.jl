"""
    edges(g)
    edges(g, vertices)

Returns an iterator to the edges of a graph `g`.
The returned iterator is invalidated by changes to `g`.

If the optional argument `vertices` is given,  the returned iterator runs only
over the edges between vertex in `vertices`.
"""
function edges end

edges(g::ADiGraph) = nv(g) == 0 ? #julia issue #18852
                        (edge(g, u, v) for u=1:1 for v=1:0) :
                        (edge(g, u, v) for u=1:nv(g) for v in out_neighbors(g, u))

edges(g::AGraph) = nv(g) == 0 ? #julia issue #18852
                        (edge(g, u, v) for u=1:1 for v=1:0) :
                        (edge(g, u, v) for u=1:nv(g) for v in out_neighbors(g, u) if u <= v)

edges(g::ADiGraph, vs::AbstractVector) = length(vs) == 0 ? #julia issue #18852
                        (edge(g, u, v) for u=1:1 for v=1:0) :
                        (edge(g, u, v) for u in vs for v in out_neighbors(g, u) if v ∈ vs)

edges(g::AGraph, vs::AbstractVector) = length(vs) == 0 ? #julia issue #18852
                        (edge(g, u, v) for u=1:1 for v=1:0) :
                        (edge(g, u, v) for u in vs for v in out_neighbors(g, u) if u <= v && v ∈ vs)

"""
    edges(g, v)

Returns an iterator to the edges in `g` coming from vertex `v`.
`v == src(e)` for each returned edge `e`.
This is equivalent to [`out_edges`](@ref)(g, v).
"""
edges(g::ASimpleGraph, v::Int) = out_edges(g, v)
