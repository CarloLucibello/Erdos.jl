import MathProgBase.SolverInterface.AbstractMathProgSolver,
       JuMP.UnsetSolver,
       LightGraphs.DefaultCapacity

export interdiction_flow, ⪷,
      NetworkInterdictionProblem, AdaptiveFlowArcProblem, AdaptiveFlowPathProblem,
      MultilinkAttackAlgorithm, BilevelMixedIntegerLinearProgram

"""
Abstract type that allows users to indicate their Problem
"""
abstract AbstractInterdictionFlowProblem

"""
Set the problem version to Network Interdiction (attacker strikes first)
"""
type NetworkInterdictionProblem <: AbstractInterdictionFlowProblem
end

"""
Set the problem version to Adaptive Network Flow [arc version] (flow is computed first)
"""
type AdaptiveFlowArcProblem <: AbstractInterdictionFlowProblem
end

"""
Set the problem version to Adaptive Network Flow [path version] (flow is computed first)
"""
type AdaptiveFlowPathProblem <: AbstractInterdictionFlowProblem
end

"""
Abstract type that allows users to pass in their preferred Algorithm
"""
abstract AbstractInterdictionFlowAlgorithm

"""
Forces the network_interdiction, adaptive_arc, or adaptive_path functions to use the Multilink Attack (MLA) algorithm.
"""
type MultilinkAttackAlgorithm <: AbstractInterdictionFlowAlgorithm
end

"""
Forces the adaptive_arc function to use a Bilevel Mixed-Integer Linear Program (BMILP)
"""
type BilevelMixedIntegerLinearProgram <: AbstractInterdictionFlowAlgorithm
end

# Includes : algorithms
include("multilink_attack.jl")
include("bilevel_adaptive_arc.jl")
include("bilevel_adaptive_path.jl")
include("bilevel_network_interdiction.jl")
# Includes : Problems
include("adaptive_arc.jl")
include("network_interdiction.jl")
include("adaptive_path.jl")

"""
Approximative comparison to deal with Float precision

```julia
function ⪷{T<:AbstractFloat}(
  x::T,
  y::T
  )
  return x ≈ y || x < y
end
```
"""
function ⪷{T<:AbstractFloat}(
  x::T,
  y::T
  )
  return x ≈ y || x < y
end

# Method when the problem considered is Network Interdiction
function interdiction_flow{T<:AbstractFloat}(
  flow_graph::DiGraph,                           # the input graph
  source::Int,                                   # the source vertex
  target::Int,                                   # the target vertex
  capacity_matrix::AbstractArray{T, 2},          # edge flow capacities
  attacks::Int,                                  # argument for attacks
  algorithm::AbstractInterdictionFlowAlgorithm,  # argument for algorithm,
  problem::NetworkInterdictionProblem,           # argument for problem
  solver::AbstractMathProgSolver,                # argument for solver
  rtol::T,                                       # relative tolerance
  atol::T,                                       # absolute tolerance
  time_limit::Float64                            # time limit (seconds)
  )
  return network_interdiction(flow_graph, source, target, capacity_matrix,
                       attacks, algorithm, solver, rtol, atol, time_limit)
end

# Method when the problem considered is Adaptive Flow (arc version)
function interdiction_flow{T<:AbstractFloat}(
  flow_graph::DiGraph,                           # the input graph
  source::Int,                                   # the source vertex
  target::Int,                                   # the target vertex
  capacity_matrix::AbstractArray{T, 2},          # edge flow capacities
  attacks::Int,                                  # argument for attacks
  algorithm::AbstractInterdictionFlowAlgorithm,  # argument for algorithm,
  problem::AdaptiveFlowArcProblem,               # argument for problem
  solver::AbstractMathProgSolver,                # argument for solver
  rtol::T,                                       # relative tolerance
  atol::T,                                       # absolute tolerance
  time_limit::Float64                            # time limit (seconds)
  )
  return adaptive_arc(flow_graph, source, target, capacity_matrix, attacks,
                                 algorithm, solver, rtol, atol, time_limit)
end

# Method when the problem considered is Adaptive Flow (path version)
function interdiction_flow{T<:AbstractFloat}(
  flow_graph::DiGraph,                           # the input graph
  source::Int,                                   # the source vertex
  target::Int,                                   # the target vertex
  capacity_matrix::AbstractArray{T, 2},          # edge flow capacities
  attacks::Int,                                  # argument for attacks
  algorithm::AbstractInterdictionFlowAlgorithm,  # argument for algorithm,
  problem::AdaptiveFlowPathProblem,              # argument for problem
  solver::AbstractMathProgSolver,                # argument for solver
  rtol::T,                                       # relative tolerance
  atol::T,                                       # absolute tolerance
  time_limit::Float64                            # time limit (seconds)
  )
  return adaptive_path(flow_graph, source, target, capacity_matrix, attacks,
                                  algorithm, solver, rtol, atol, time_limit)
end

"""
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

"""

function interdiction_flow{T<:AbstractFloat}(
  flow_graph::DiGraph,                           # the input graph
  source::Int,                                   # the source vertex
  target::Int,                                   # the target vertex
  capacity_matrix::AbstractArray{T, 2},          # edge flow capacities
  attacks::Int = -1;                             # argument for attacks
  algorithm::AbstractInterdictionFlowAlgorithm = # keyword argument for algorithm
    MultilinkAttackAlgorithm(),
  problem::AbstractInterdictionFlowProblem =     # keyword argument for problem
    NetworkInterdictionProblem(),
  solver::AbstractMathProgSolver =               # keyword for solver
    UnsetSolver(),
  rtol::T = sqrt(eps()),                         # relative tolerance
  atol::T = 0.,                                  # absolute tolerance
  time_limit::Float64 = Inf                      # time limit (seconds)
  )
  # attacks ≥ λ (connectivity) → f = 0
  λ = maximum_flow(flow_graph, source, target, DefaultCapacity(flow_graph), algorithm = EdmondsKarpAlgorithm())[1]
  (attacks ≥ λ) && return 0., 0., 0., 0.

  # compute the result when 0 ≤ attacks < λ
  (attacks ≥ 0) && return interdiction_flow(flow_graph, source, target, capacity_matrix,
                       attacks, algorithm, problem, solver, rtol, atol, time_limit)

  # Iteration over all the relevant number of attacks k ∈ 0:λ
  return [
    interdiction_flow(flow_graph, source, target, capacity_matrix, k, algorithm,
                                              problem, solver, rtol, atol, time_limit)
    for k in 0:λ]
end
