EdgeIter(g::ADiGraph) = nv(g) == 0 ? #julia issue #18852
                        (edge(g, u, v) for u=1:1 for v=1:0) :
                        (edge(g, u, v) for u=1:nv(g) for v in out_neighbors(g, u))
EdgeIter(g::AGraph) = nv(g) == 0 ? #julia issue #18852
                    (edge(g, u, v) for u=1:1 for v=1:0) :
                    (edge(g, u, v) for u=1:nv(g) for v in out_neighbors(g, u) if u <= v)
