# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

"""
    pagerank(g::ADiGraph, α=0.85, n=100, ϵ = 1.0e-6)

Calculates the [PageRank](https://en.wikipedia.org/wiki/PageRank) of the graph
`g`. Can optionally specify a different damping factor (`α`), number of
iterations (`n`), and convergence threshold (`ϵ`). If convergence is not
reached within `n` iterations, an error will be returned.
"""
function pagerank(g::ADiGraph, α=0.85, n=100, ϵ = 1.0e-6)
    A = adjacency_matrix(g,:in,Float64)
    S = 1 ./ vec(sum(A, dims=1))
    S[S .== Inf] .= 0.0
    M = A' # need a separate line due to bug #17456 in julia
    M = (Diagonal(S) * M)'
    N = nv(g)
    x = fill(1/N, N)
    p = fill(1/N, N)
    dangling_weights = p
    is_dangling = findall(S .== 0)

    for _ in 1:n
        xlast = x
        x = α * (M * x + sum(x[is_dangling]) * dangling_weights) + (1 - α) * p
        err = sum(abs, x - xlast)
        err < N * ϵ && return x
    end
    error("Pagerank did not converge after $n iterations.")
end
