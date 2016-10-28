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
                (e for u=1:nv(g) for e in out_edges(g, u))

edges(g::AGraph) = nv(g) == 0 ? #julia issue #18852
                (edge(g, u, v) for u=1:1 for v=1:0) :
                (e for u=1:nv(g) for e in out_edges(g, u) if src(e) <= dst(e))

edges(g::ADiGraph, vs::AbstractVector) = length(vs) == 0 ? #julia issue #18852
                (edge(g, u, v) for u=1:1 for v=1:0) :
                (e for u in vs for e in out_edges(g, u) if dst(e) ∈ vs)

edges(g::AGraph, vs::AbstractVector) = length(vs) == 0 ? #julia issue #18852
                (edge(g, u, v) for u=1:1 for v=1:0) :
                (e for u in vs for e in out_edges(g, u) if src(e) <= dst(e) && dst(e) ∈ vs)
