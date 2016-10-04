"""
    community_detection_nback(g::Graph, k::Int)

Community detection using the spectral properties of
the non-backtracking matrix of `g` (see [Krzakala et al.](http://www.pnas.org/content/110/52/20935.short)).

`g`: imput Graph
`k`: number of communities to detect

return : array containing vertex assignments
"""
function community_detection_nback(g::Graph, k::Int)
    #TODO insert check on connected_components
    ϕ = real(nonbacktrack_embedding(g, k))
    if k==2
        c = community_detection_threshold(g, ϕ[1,:])
    else
        c = kmeans(ϕ, k).assignments
    end
    return c
end

function community_detection_threshold(g::SimpleGraph, coords::AbstractArray)
    # TODO use a more intelligent method to set the threshold
    # 0 based thresholds are highly sensitive to errors.
    c = ones(Int, nv(g))
    # idx = sortperm(λ, lt=(x,y)-> abs(x) > abs(y))[2:k] #the second eigenvector is the relevant one
    for i=1:nv(g)
        c[i] = coords[i] > 0 ?  1 : 2
    end
    return c
end


""" Spectral embedding of the non-backtracking matrix of `g`
(see [Krzakala et al.](http://www.pnas.org/content/110/52/20935.short)).

`g`: imput Graph
`k`: number of dimensions in which to embed

return : a matrix ϕ where ϕ[:,i] are the coordinates for vertex i.

Note does not explicitly construct the `non_backtracking_matrix`.
See `Nonbacktracking` for details.

"""
function nonbacktrack_embedding(g::Graph, k::Int)
    B = Nonbacktracking(g)
    λ, eigv, conv = eigs(B, nev=k+1, v0=ones(Float64, B.m))
    ϕ = zeros(Complex64, nv(g), k-1)
    # TODO decide what to do with the stationary distribution ϕ[:,1]
    # this code just throws it away in favor of eigv[:,2:k+1].
    # we might also use the degree distribution to scale these vectors as is
    # common with the laplacian/adjacency methods.
    for n=1:k-1
        v= eigv[:,n+1]
        ϕ[:,n] = contract(B, v)
    end
    return ϕ'
end



"""
    community_detection_bethe(g::Graph, k=-1; kmax=15)

Community detection using the spectral properties of
the Bethe Hessian matrix associated to `g` (see [Saade et al.](http://papers.nips.cc/paper/5520-spectral-clustering-of-graphs-with-the-bethe-hessian)).
`k` is the number of community to detect. If omitted or if `k<1` the
optimal number of communities will be automatically selected.
In this case the maximum number of detectable communities is given by `kmax`.
Returns a vector containing the vertex assignments.
"""
function community_detection_bethe(g::Graph, k::Int=-1; kmax::Int=15)
    A = adjacency_matrix(g)
    D = diagm(degree(g))
    r = (sum(degree(g)) / nv(g))^0.5

    Hr = (r^2-1)*eye(nv(g))-r*A+D;
    # Hmr = (r^2-1)*eye(nv(g))+r*A+D;
    k >= 1 && (kmax = k)
    λ, eigv = eigs(Hr, which=:SR, nev=min(kmax, nv(g)))
    q = findlast(x -> x<0, λ)
    k > q && warn("Using eigenvectors with positive eigenvalues,
                    some communities could be meaningless. Try to reduce `k`.")
    k < 1 && (k = q)
    k < 1 && return fill(1, nv(g))
    labels = kmeans(eigv[:,2:k]', k).assignments
    return labels
end
