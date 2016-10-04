#### Graphs for testing
graphs = [
  # Graph with 8 vertices
  (8,
   [
     (1, 2, 10), (1, 3, 5),  (1, 4, 15), (2, 3, 4),  (2, 5, 9),
     (2, 6, 15), (3, 4, 4),  (3, 6, 8),  (4, 7, 16), (5, 6, 15),
     (5, 8, 10), (6, 7, 15), (6, 8, 10), (7, 3, 6),  (7, 8, 10)
   ],
   1, 8                              # source/target
  ),

  # Graph with 6 vertices
  (6,
   [
     (1, 2, 9), (1, 3, 9), (2, 3, 10), (2, 4, 8), (3, 4, 1),
     (3, 5, 3), (5, 4, 8), (4, 6, 10), (5, 6, 7)
   ],
   1, 6                                      # source/target
  ),

  # Graph with 7 vertices
  (7,
   [
     (1, 2, 1), (1, 3, 2), (1, 4, 3), (1, 5, 4), (1, 6, 5),
     (2, 7, 1), (3, 7, 2), (4, 7, 3), (5, 7, 4), (6, 7, 5)
   ],
   1, 7                                      # source/target
  ),

  # Graph with 6 vertices
  (6,
   [
     (1, 2, 1), (1, 6, 1), (1, 3, 1), (1, 4, 2), (1, 5, 2),
     (2, 6, 1), (3, 6, 1), (4, 6, 2), (5, 6, 2), (6, 1, 1),
   ],
   1, 6                                      # source/target
  )
]

for (nvertices, flow_edges, s, t) in graphs
  flow_graph = DiGraph(nvertices)
  capacity_matrix = zeros(nvertices, nvertices)
  for e in flow_edges
    u, v, f = e
    add_edge!(flow_graph, u, v)
    capacity_matrix[u, v] = f
  end

  # Connectivity λ
  λ = maximum_flow(flow_graph, s, t)[1]
  for k in 0:λ
    # Compare MultilinkAttackAlgorithm and BilevelMixedIntegerLinearProgram
    # a) TODO: When the problem is NetworkInterdictionProblem
    mla = interdiction_flow(flow_graph, s, t, capacity_matrix, k)
    @test mla[1] ⪷ mla[2]
    bmilp = interdiction_flow(flow_graph, s, t, capacity_matrix, k,
                              problem = NetworkInterdictionProblem(),
                              algorithm = BilevelMixedIntegerLinearProgram())
    @test bmilp[1] ≈ 0.
    # b) When the problem is AdaptiveFlowArcProblem
    mla = interdiction_flow(flow_graph, s, t, capacity_matrix, k,
                            problem = AdaptiveFlowArcProblem())
    bmilp = interdiction_flow(flow_graph, s, t, capacity_matrix, k,
                              problem = AdaptiveFlowArcProblem(),
                              algorithm = BilevelMixedIntegerLinearProgram())
    @test mla[1] ⪷ bmilp[1] ⪷ bmilp[2] ⪷ mla[2]
    # c) TODO: When the problem is AdaptiveFlowPathProblem
    mla = interdiction_flow(flow_graph, s, t, capacity_matrix, k,
                            problem = AdaptiveFlowPathProblem())
    @test mla[1] * 2. ⪷ mla[2]
    bmilp = interdiction_flow(flow_graph, s, t, capacity_matrix, k,
                              problem = AdaptiveFlowPathProblem(),
                              algorithm = BilevelMixedIntegerLinearProgram())
    @test bmilp[1] ≈ 0.
  end
  # Test when attacks = -1
  @test interdiction_flow(flow_graph, s, t, capacity_matrix)[2] ==
        interdiction_flow(flow_graph, s, t, capacity_matrix, 1)

end
