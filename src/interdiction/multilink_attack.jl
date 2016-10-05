# Compute the projection of (x,y) on the y-axis along a given slope
function projection{T<:AbstractFloat}(
  x::T, y::T,       # Coordinates
  slope::Int                    # Associated slope
  )
  return y - slope * x
end

# Compute the upper and lower bounds for a given number of attacks
function bounds_from_points{T<:AbstractFloat}(
  breaking_points::Vector{Tuple{T,T,Int}},       # Set of breaking points
  attacks::Int                                   # argument for attacks
  )
  # Indices for upper and lower bounds
  upper_index = 0
  lower_index = 0
  # Loop to find the correct indices
  for (id, point) in enumerate(breaking_points)
    if attacks ≤ point[3]
      lower_index = id
    end
    if attacks ≥ point[3]
      upper_index = id
      break
    end
  end

  # Assign the points corresponding to the upper and lower bounds
  lower_point = breaking_points[lower_index]
  upper_point = breaking_points[upper_index]

  # A bound is described by its value and an associated restriction
  # The restriction is useful to reconstruct a bound's flows and cuts
  lower_value = projection(lower_point[1], lower_point[2], lower_point[3])
  upper_value = projection(upper_point[1], upper_point[2], upper_point[3])
  lower_restriction, upper_restriction = lower_point[3], upper_point[3]

  return lower_value, upper_value, lower_restriction, upper_restriction
end


function multilink_attack{T<:AbstractFloat}(
  flow_graph::ADiGraph,                           # the input graph
  source::Int,                                   # the source vertex
  target::Int,                                   # the target vertex
  capacity_matrix::AbstractArray{T, 2},          # edge flow capacities
  attacks::Int                                   # argument for attacks
  )
  # Get all the breaking points from extended multiroute flow algorithm
  breaking_points = multiroute_flow(flow_graph, source, target, capacity_matrix, flow_algorithm = EdmondsKarpAlgorithm())

  # Return the lower and upper bounds : value, restriction
  return bounds_from_points(breaking_points, attacks)
end
