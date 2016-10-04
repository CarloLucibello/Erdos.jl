# Network Interdiction

## Flow

Network Interdiction is a family of problems where some elements of graph
(vertices or links usually) are forbidden, destroyed or have failed. The goal is
then to compute some objective function, as a maximum flow or a shortest path.

Currently, `LightGraphsExtras.jl` implement methods for three kinds of Interdiction
Flow's problems. The Interdiction flow problems can be seen as a game between two
players, a defender (that maximizes the flow) and an attacker (that destroy some
links). Called using respectively `NetworkInterdictionProblem()`,
`AdaptiveFlowArcProblem()` and `AdaptiveFlowPathProblem()`, the three following
variants, as described by
[Bertsimas et al.](http://dx.doi.org/10.1016/j.orl.2015.11.005), are considered :

- The Network Interdiction Flow where the attacker strikes first, then a maximum-flow
  is computed on the remaining network. The goal is for the defender to predict the
  best worst case. The problem is called by using
- Adaptive Network Flow whre the defender computes a flow first. There are two
  variants.

    - Arc version : the flow is expressed as combination of flow on the links. The
      destruction of an edge only implies the flow on that to be destroyed (it could
      results with some flow on other egdes not reaching the target node).
    - Path version : the flow is now combination of paths from the souce to the sink
      where each edge that is destroyed also implies the destruction of all the paths
      going through this edge.


This Interdiction Flow (including all the variants) for general graphs is an NP-hard problem and several exact and approximative algorithms have been designed in the academic litterature. Called using respectively `MultilinkAttackAlgorithm()` and `BilevelMixedIntegerLinearProgram()`, `LightGraphsExtras.jl` provides the following methods (any help to implement other algorithms is welcome):

- A deterministic pollynomial algorithm called Multilink Attack relying on the
  Extended Multiroute Flow algorithm (available in `LightGraphs.jl`) introduced by
  [Baffier et al.](http://dx.doi.org/10.1016/j.disopt.2016.05.002). For a certain
  category of graph, it solves Network Interdiction Flow and Adaptive Flow (arc)
  exactly. When it fails, it provides upper and lower bounds. It provides a
  2-approximation for Adaptive Flow (path), see
  [Suppakitpaisarn et al.](http://dx.doi.org/10.1109/HPSR.2015.7483079)
  for more details.
- A Bilevel Mixed Integer Linear Program (BMILP) framework using `JuMP.jl` that is
  guaranteed to converge. (Only the adaptive flow (arc) vairant is covered yet, the
  others use dummy functions). The results of this framework through
  `LightGraphsExtras.jl` will be appear in the following month in the litterature.

The `interdiction_flow{T<:AbstractFloat}` function takes the following arguments:

- flow_graph::DiGraph                           # the input graph
- source::Int                                   # the source vertex
- target::Int                                   # the target vertex
- capacity_matrix::AbstractArray{T, 2}          # edge flow capacities
- attacks::Int                                  # argument for attacks
- algorithm::AbstractInterdictionFlowAlgorithm  # argument for algorithm,
- problem::NetworkInterdictionProblem           # argument for problem
- solver::AbstractMathProgSolver                # argument for solver (BMILP only)
- rtol::T                                       # relative tolerance (BMILP only)
- atol::T                                       # absolute tolerance (BMILP only)
- time_limit::Float64                           # time limit (BMILP only)

If no number of attacks is given, it will be set to -1 (that means for any possible
number of attacks between 0 and the source-sink connectivity).
The function defaults to `MultilinkAttackAlgorithm()` and `NetworkInterdictionProblem()`
for algorithm and problem. If `BilevelMixedIntegerLinearProgram()` is used,
the solver, rtol, atol, and time_limit are also used and default as respectively
`UnsetSolver()`, `sqrt(eps())`, `0.`, `Inf`. The relative and absolute tolerance are
used to compare the upper and lower bounds for termination.
Please consult the [`JuMP.jl` documentation](http://http://jump.readthedocs.io) for the
use of the solver keyword, as it is similar to the `Model()` method there.

All algorithms return a tuple with 1) a lower bound and 2) an upper bound.
For the Multilink Attack algorithm, it also returns the restriction values (to use with
the function maximum_flow in LightGraphs.jl) associated with 3-a) the lower bound and
4-a) the upper bound. When the BMILP is used, the third element returned is 3-b) the
time used by the algorithm.

When the number of attacks is set to -1, an array with the results for any possible number of attacks will be output. Each result will be output as above.

### Approximative comparison

Approximative comparison to deal with Float precision. LaTeX command : `\precapproc`

```julia
function ⪷{T<:AbstractFloat}(
  x::T,
  y::T
  )
  return x ≈ y || x < y
end
```

### Usage Example :

```julia

# Create a flow-graph and a capacity matrix
flow_graph = DiGraph(8)
flow_edges = [
    (1, 2, 10), (1, 3, 5),  (1, 4, 15), (2, 3, 4),  (2, 5, 9),
    (2, 6, 15), (3, 4, 4),  (3, 6, 8),  (4, 7, 16), (5, 6, 15),
    (5, 8, 10), (6, 7, 15), (6, 8, 10), (7, 3, 6),  (7, 8, 10)
]
capacity_matrix = zeros(Float64, 8, 8)
for e in flow_edges
    u, v, f = e
    add_edge!(flow_graph, u, v)
    capacity_matrix[u, v] = f
end

# Run default values
lower_bound, upper_bound , lower_restriction, upper_restriction =
  interdiction_flow(flow_graph, 1, 8, capacity_matrix)

# Run default values but with a specific number of attacks
lower_bound, upper_bound , lower_restriction, upper_restriction =
  interdiction_flow(flow_graph, 1, 8, capacity_matrix, 1)

# Run with BMILP for 1 attack and adaptive flow (arc) problem
lower_bound, upper_bound , time_used =
  interdiction_flow(flow_graph, 1, 8, capacity_matrix, 1,
    algorithm = BilevelMixedIntegerLinearProgram(),
    problem = AdaptiveFlowArcProblem())

if lower_bound ⪷ upper_bound
  print("Lower bound = $lower_bound and Upper Bound = $upper_bound")
  println(" in $time_used seconds.")
else
  error("There is a bound error in the BMILP")
end

```
