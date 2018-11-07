@deprecate fadj(g) adjacency_list(g)
@deprecate fadj(g, v) out_neighbors(g, v)
@deprecate badj(g) adjacency_list(g, :in)
@deprecate badj(g, v) in_neighbors(g, v)
@deprecate induced_subgraph subgraph
@deprecate indegree(g, v) in_degree(g, v)
@deprecate outdegree(g, v) out_degree(g, v)

@deprecate radius(vec) minimum(vec)
@deprecate diameter(vec) maximum(vec)

@deprecate adjacency_spectrum(g)  eigvals(Matrix(adjacency_matrix(g)))
@deprecate laplacian_spectrum(g)  eigvals(Matrix(laplacian_matrix(g)))

@deprecate is_cyclic(g) has_cycles(g)
