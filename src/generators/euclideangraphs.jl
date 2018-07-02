"""
    euclidean_graph(points::Matrix, G; L=1., p=2., cutoff=Inf, bc=:periodic)

Given the `d×N` matrix `points` builds an Euclidean graph of `N` vertices
according to the following procedure.

Defining the `d`-dimensional vectors `x[i] = points[:,i]`, an edge between
vertices `i` and `j` is inserted if `norm(x[i]-x[j], p) < cutoff`.
In case of negative `cutoff` instead every edge is inserted.
For `p=2` we have the standard Euclidean distance.
Set `bc=:periodic` to impose periodic boundary conditions in the box ``[0,L]^d``.
Set `bc=:open` for open boundary condition. In this case the keyword argument `L`
will be ignored.

Returns a graph and Dict containing the distance on each edge.
"""
function euclidean_graph(points::Matrix, ::Type{G} = Graph;
            L=1., p=2., cutoff=Inf, bc=:open) where G<:AGraph
    d, N = size(points)
    g = G(N)
    weights = Dict{Edge,Float64}()
    bc ∉ [:periodic,:open] && error("Not a valid boundary condition.")
    if bc == :periodic
        maximum(points) > L &&  error("Some points are outside the box of size $L.")
    end
    for i=1:N
        for j=i+1:N
            if bc == :open
                Δ = points[:,i]-points[:,j]
            elseif bc == :periodic
                Δ = abs.(points[:,i]-points[:,j])
                Δ = min.(L - Δ, Δ)
            end
            dist = norm(Δ, p)
            if dist < cutoff
                e = Edge(i,j)
                add_edge!(g, e)
                weights[e] = dist
            end
        end
    end
    return g, weights
end
