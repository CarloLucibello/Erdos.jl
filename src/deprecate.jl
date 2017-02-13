@deprecate fadj(g) out_adjlist(g)
@deprecate fadj(g, v) out_neighbors(g, v)
@deprecate badj(g) in_adjlist(g)
@deprecate badj(g, v) in_neighbors(g, v)
@deprecate induced_subgraph subgraph
@deprecate maximum_weight_maximal_matching minimum_weight_perfect_matching
@deprecate indegree(g, v) in_degree(g, v)
@deprecate outdegree(g, v) out_degree(g, v)

@deprecate radius(vec) minimum(vec)
@deprecate diameter(vec) maximum(vec)

@deprecate adjacency_spectrum(g)  eigvals(full(adjacency_matrix(g)))
@deprecate laplacian_spectrum(g)  eigvals(full(laplacian_matrix(g)))
