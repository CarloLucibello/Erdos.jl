include("kruskal.jl")

"""
    count_spanning_trees(g::AGraph)

Returns the number of spanning trees of `g`, computed through
[Kirchhoff's theorem](https://en.wikipedia.org/wiki/Kirchhoff%27s_theorem).
The return type is a float, since the number can be very large.
"""
function count_spanning_trees(g::AGraph)
    @assert is_connected(g) "The graph has to be connected"
    nv(g) <= 1 && return 1.
    Δ = laplacian_matrix(g)[2:nv(g),2:nv(g)]
    return round(det(Δ))
end
