function bilevel_adaptive_path{T<:AbstractFloat}(
  flow_graph::DiGraph,                          # the input graph
  source::Int,                                  # the source vertex
  target::Int,                                  # the target vertex
  capacity_matrix::AbstractArray{T, 2},         # edge flow capacities
  attacks::Int,                                 # argument for attacks
  solver::AbstractMathProgSolver,               # keyword for solver
  rtol::T,                                      # absolute tolerance
  atol::T,                                      # relative tolerance
  time_limit::Float64                           # time limit
  )
	start_time = time()                           # time stamp
  n = nv(flow_graph)                            # size of the network
  lower_bound = 0.

  # TODO: Write the proper algorithm

  # Return objective value and elapsed time
  return lower_bound, time() - start_time
end
