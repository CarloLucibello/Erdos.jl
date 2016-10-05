function init_first_level_arc{T<:AbstractFloat}(
  flow_graph::ADiGraph,                          # the input graph
  source::Int,                                  # the source vertex
  target::Int,                                  # the target vertex
  capacity_matrix::AbstractArray{T, 2},         # edge flow capacities
  solver::AbstractMathProgSolver                # keyword for solver
  )
  n = nv(flow_graph)           # size of the network

	first_level = Model(solver = solver)

	# x : first level binary variables
	@variable(first_level, 0 ≤ x[i = 1:n, j = 1:n] ≤ capacity_matrix[i, j])
  # z : objective function
	@variable(first_level, z)
	@objective(first_level, Max, z)

	# flow conservation constraints
	for v in vertices(flow_graph)
		if (v ≠ source && v ≠ target)
      @constraint(first_level, sum{x[i, j], i = 1:n, j = 1:n;
        capacity_matrix[i ,j] > 0} - sum{x[j, i], i = 1:n, j = 1:n;
        capacity_matrix[j, i] > 0} == 0)
	   	end
	end

  # objective function upper bound
	# @constraint(first_level, z ≤ prevfloat(typemax(T)))
	@constraint(first_level, z ≤ 10000000)

  return first_level, x, z
end

function init_second_level_arc{T<:AbstractFloat}(
  flow_graph::ADiGraph,                          # the input graph
  source::Int,                                  # the source vertex
  target::Int,                                  # the target vertex
  capacity_matrix::AbstractArray{T, 2},         # edge flow capacities
  attacks::Int,                                 # argument for attacks
  solver::AbstractMathProgSolver,               # keyword for solver
  x::Matrix{JuMP.Variable}                      # flows from first_level
  )
  n = nv(flow_graph)           # size of the network
  x_value = getvalue(x)        # extract the value of variable x

  second_level = Model(solver = solver)

  # variable that model if an arc is attacked or not
  @variable(second_level, 0 ≤ μ[i = 1:n, j = 1:n] ≤ 1, Int)
  # first cut variables
  @variable(second_level, δ[i = 1:n,j = 1:n] ≥ 0)
  # second cut variables
  @variable(second_level, σ[i = 1:n] ≥ 0)
  # linearization variables: ν = δμ
  @variable(second_level, ν[i = 1:n, j = 1:n] ≥ 0)

  # set objective
  @objective(second_level, Min, sum{
    x_value[i, j] * δ[i, j] - x_value[i, j] * ν[i, j], i = 1:n, j = 1:n;
    capacity_matrix[i, j] > 0})

  # constraints over the edges
  for e in edges(flow_graph)
    i, j = src(e), dst(e)
    # first linearization constraint for v
    @constraint(second_level, ν[i, j] ≤ μ[i, j])
    # second linearization constraint for v
    @constraint(second_level, ν[i, j] ≤ δ[i, j])
    if i == source
      # cut constraint for edge (i,j) when i is the source
      if j != target
        @constraint(second_level, δ[i, j] + σ[j] ≥ 1 )
      else
        @constraint(second_level, δ[i, j] ≥ 1 )
      end
    elseif j == target
      # cut constraint for edge (i,j) when j is the destination
      if i != source
         @constraint(second_level, δ[i, j] - σ[i] ≥ 0 )
      end
    else
      # cut constraint for edge (i,j) in the remaining cases
      @constraint(second_level, δ[i, j] + σ[j] - σ[i] ≥ 0)
    end
  end

  # constraint on the upper bound for the number of attacks
  @constraint(second_level, sum{μ[i, j], i = 1:n, j = 1:n} ≤ attacks)

  return second_level, δ, ν
end

function bilevel_adaptive_arc{T<:AbstractFloat}(
  flow_graph::ADiGraph,                          # the input graph
  source::Int,                                  # the source vertex
  target::Int,                                  # the target vertex
  capacity_matrix::AbstractArray{T, 2},         # edge flow capacities
  attacks::Int,                                 # argument for attacks
  solver::AbstractMathProgSolver,               # keyword for solver
  rtol::T,                                      # relative tolerance
  atol::T,                                      # absolute tolerance
  time_limit::Float64                           # time limit (seconds)
  )
	start_time = time()               # time stamp (seconds)
  n = nv(flow_graph)                # size of the network
  lower_bound = 0.
  upper_bound = 0.

  # Initialization : first level
  first_level, x, z =
    init_first_level_arc(flow_graph, source, target, capacity_matrix, solver)

  # Loop over the first level while adding cuts from the second level
  while solve(first_level) ≠ :Infeasible && time() - start_time < time_limit
    # Store first level results
    upper_bound, x_value = getobjectivevalue(first_level), getvalue(x)

    # Initialization : second level
    second_level, δ, ν =
      init_second_level_arc(flow_graph, source, target, capacity_matrix,
                                                     attacks, solver, x)

    # Solve second level and update lower_bound
		solve(second_level)
		lower_bound = getobjectivevalue(second_level)

    # If the bounds are tight, exit the loop
    (isapprox(upper_bound, lower_bound, rtol = rtol, atol = atol)) && break

    # Otherwise add the new cut to the first level
		δ_value = getvalue(δ)
		ν_value = getvalue(ν)
    @constraint(first_level, z ≤ sum{
      δ_value[i, j] * x[i, j] - ν_value[i, j] * x[i, j], i = 1:n, j = 1:n;
      capacity_matrix[i, j] > 0})
  end

  # Return objective value and elapsed time
  return lower_bound, upper_bound, time() - start_time
end
