# used in shortest path calculations
# has_distances{T}(distmx::AEdgeMap{T}) =
#     issparse(distmx)? (nnz(distmx) > 0) : !isempty(distmx)

"""
    eccentricity(g, v, distmx=weights(g))

Calculates the eccentricity[ies] of a vertex `v`,
An optional matrix of edge distances may be supplied.

The eccentricity of a vertex is the maximum shortest-path distance between it
and all other vertices in the graph.
"""
function eccentricity(
    g::AGraphOrDiGraph,
    v::Int,
    distmx::AEdgeMap=weights(g)
)
    e = maximum(dijkstra_shortest_paths(g,v,distmx).dists)
    e == typemax(valtype(distmx)) && error("Infinite path length detected")

    return e
end

"""

    eccentricities(g, distmx=weights(g))
    eccentricities(g, vs, distmx=weights(g))

Returns `[eccentricity(g,v,distmx) for v in vs]`. When `vs` it is not supplied,
considers all node in the graph.

See also [`eccentricity`](@ref).

Note: the eccentricity vector returned by `eccentricity` may be eventually used as input
in some eccentricity related measures ([`periphery`](@ref), [`center`](@ref)).
"""
function eccentricities(
    g::AGraphOrDiGraph,
    vs::AbstractVector,
    distmx::AEdgeMap=weights(g)
)
    [eccentricity(g,v,distmx) for v in vs]
end

eccentricities(
    g::AGraphOrDiGraph,
    distmx::AEdgeMap=weights(g)
) = eccentricities(g, 1:nv(g), distmx)

"""
    diameter(g, distmx=weights(g))

Returns the maximum distance between any two vertices in `g`.
Distances  between two adjacent nodes are given by `distmx`.

See also [`eccentricities`](@ref), [`radius`](@ref).
"""
diameter(g::AGraphOrDiGraph, distmx::AEdgeMap = weights(g)) =
    maximum(eccentricities(g, distmx))


"""
    radius(g, distmx=weights(g))

Returns the minimum distance between any two vertices in `g`.
Distances  between two adjacent nodes are given by `distmx`.

See [`eccentricities`](@ref), [`diameter`](@ref).
"""
radius(g::AGraphOrDiGraph, distmx=weights(g)) =
    minimum(eccentricities(g, distmx))

"""
    periphery(g, distmx=weights(g))
    periphery(all_ecc)

Returns the set of all vertices whose eccentricity is equal to the graph's
diameter (that is, the set of vertices with the largest eccentricity).

Eventually a vector `all_ecc` contain the eccentricity of each node
can be passed as argument.

See [`eccentricities`](@ref).
"""
function periphery(all_e::Vector)
    diam = maximum(all_e)
    return filter((x)->all_e[x] == diam, 1:length(all_e))
end

periphery(g::AGraphOrDiGraph, distmx::AEdgeMap=weights(g)) =
    periphery(eccentricities(g, distmx))

"""
    center(g, distmx=weights(g))
    center(all_ecc)

Returns the set of all vertices whose eccentricity is equal to the graph's
radius (that is, the set of vertices with the smallest eccentricity).

Eventually a vector `all_ecc` contain the eccentricity of each node
can be passed as argument.

See [`eccentricities`](@ref).
"""
function center(all_e::Vector)
    rad = minimum(all_e)
    return filter((x)->all_e[x] == rad, 1:length(all_e))
end

center(g::AGraphOrDiGraph, distmx::AEdgeMap = weights(g)) =
    center(eccentricities(g, distmx))
