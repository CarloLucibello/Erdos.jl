# Generic fallbacks
# TODO overload for Graph and Network types
edges(g::ADiGraph) = (e for u=1:nv(g) for e in out_edges(g, u))

edges(g::AGraph) =  (e for u=1:nv(g) for e in out_edges(g, u) if src(e) <= dst(e))

edges(g::ADiGraph, vs::AbstractVector) = (e for u in vs for e in out_edges(g, u) if dst(e) ∈ vs)

edges(g::AGraph, vs::AbstractVector) = (e for u in vs for e in out_edges(g, u) if src(e) <= dst(e) && dst(e) ∈ vs)
