"""
    community_detection_nback(g, k)

Community detection using the spectral properties of
the non-backtracking matrix of graph `g` (see [Krzakala et al.](http://www.pnas.org/content/110/52/20935.short)).
`k` is the number of communities to detect.

See also [`community_detection_bethe`](@ref) for a related community ddetection
algorithm.

Returns a vector with the vertex assignments in the communities.
"""
function community_detection_nback(g::AGraph, k::Integer)
    #TODO insert check on connected_components
    ϕ = real(nonbacktrack_embedding(g, k))
    if k == 2
        c = community_detection_threshold(g, ϕ[1,:])
    else
        c = kmeans(ϕ, k).assignments
    end
    return c
end

function community_detection_threshold(g::AGraphOrDiGraph, coords::AbstractArray)
    # TODO use a more intelligent method to set the threshold
    # 0 based thresholds are highly sensitive to errors.
    c = ones(Int, nv(g))
    # idx = sortperm(λ, lt=(x,y)-> abs(x) > abs(y))[2:k] #the second eigenvector is the relevant one
    for i=1:nv(g)
        c[i] = coords[i] > 0 ?  1 : 2
    end
    return c
end

"""
    nonbacktrack_embedding(g::AGraph, k::Int)

Spectral embedding of the non-backtracking matrix of `g`
(see [Krzakala et al.](http://www.pnas.org/content/110/52/20935.short)).

    `g`: imput Graph
    `k`: number of dimensions in which to embed

Returns  a matrix `ϕ` where `ϕ[:,i]` are the coordinates for vertex `i`.

Note:  does not explicitly construct the [`nonbacktracking_matrix`](@ref).
See [`nonbacktracking_matrix`](@ref) for details.
"""
function nonbacktrack_embedding(g::AGraph, k::Int)
    B, edgeid = nonbacktracking_matrix(g)
    λ, eigv, conv = Arpack.eigs(B, nev=k+1, v0=ones(Float64, size(B,1)))
    ϕ = zeros(ComplexF64, k-1, nv(g))
    # TODO decide what to do with the stationary distribution ϕ[:,1]
    # this code just throws it away in favor of eigv[:,2:k+1].
    # we might also use the degree distribution to scale these vectors as is
    # common with the laplacian/adjacency methods.
    E = edgetype(g)
    for n=1:k-1
        v = eigv[:,n+1]
        for i=1:nv(g)
            for e in in_edges(g, i)
                j = src(e)
                u = edgeid[e]
                ϕ[n,i] += v[u]
            end
        end
    end
    return ϕ
end



"""
    community_detection_bethe(g::AGraph, k=-1; kmax=15)

Community detection using the spectral properties of
the Bethe Hessian matrix associated to `g` (see [Saade et al.](http://papers.nips.cc/paper/5520-spectral-clustering-of-graphs-with-the-bethe-hessian)).
`k` is the number of communities to detect. If omitted or if `k < 1` the
optimal number of communities will be automatically selected.
In this case the maximum number of detectable communities is given by `kmax`.
Returns a vector containing the vertex assignments.
"""
function community_detection_bethe(g::AGraph, k::Int=-1; kmax::Int=15)
    A = adjacency_matrix(g)
    D = Diagonal(degree(g))
    r = (sum(degree(g)) / nv(g))^0.5

    Hr = (r^2-1)*Diagonal(ones(nv(g))) - r*A + D;
    # Hmr = (r^2-1)*eye(nv(g))+r*A+D;
    k >= 1 && (kmax = k)
    λ, eigv = Arpack.eigs(Hr, which=:SR, nev=min(kmax, nv(g)))
    q = findlast(x -> x<0, λ)
    k > q && @warn("Using eigenvectors with positive eigenvalues,
                    some communities could be meaningless. Try to reduce `k`.")
    k < 1 && (k = q)
    k < 1 && return fill(1, nv(g))
    m = Matrix(eigv[:,2:k]') # convert to Matrix since 
                             # kmeans doesn't support Adjoint yet
    labels = kmeans(m, k).assignments
    return labels
end

"""
    label_propagation(g; maxiter=1000)

Community detection using the label propagation algorithm (see [Raghavan et al.](http://arxiv.org/abs/0709.2938)).
`g` is the input Graph, `maxiter` is the  maximum number of iterations.
Returns a vertex assignments and the convergence history
"""
function label_propagation(g::AGraphOrDiGraph; maxiter=1000)
    n = nv(g)
    label = collect(1:n)
    active_nodes = BitSet(vertices(g))
    c = NeighComm(collect(1:n), fill(-1,n), 1)
    convergence_hist = Vector{Int}()
    random_order = Vector{Int}(undef, n)
    i = 0
    while !isempty(active_nodes) && i < maxiter
        num_active = length(active_nodes)
        push!(convergence_hist, num_active)
        i += 1

        # processing nodes in random order
        for (j,node) in enumerate(active_nodes)
            random_order[j] = node
        end
        range_shuffle!(1:num_active, random_order)
        @inbounds for j=1:num_active
            u = random_order[j]
            old_comm = label[u]
            label[u] = vote!(g, label, c, u)
            if old_comm != label[u]
                for v in out_neighbors(g, u)
                    push!(active_nodes, v)
                end
            else
                delete!(active_nodes, u)
            end
        end
    end
    fill!(c.neigh_cnt, 0)
    renumber_labels!(label, c.neigh_cnt)
    label, convergence_hist
end

"""Type to record neighbor labels and their counts."""
mutable struct NeighComm
  neigh_pos::Vector{Int}
  neigh_cnt::Vector{Int}
  neigh_last::Int
end

"""Fast shuffle Array `a` in UnitRange `r` inplace."""
function range_shuffle!(r::UnitRange, a::AbstractVector)
    (r.start > 0 && r.stop <= length(a)) || error("out of bounds")
    @inbounds for i=length(r):-1:2
        j = rand(1:i)
        ii = i + r.start - 1
        jj = j + r.start - 1
        a[ii],a[jj] = a[jj],a[ii]
    end
end

"""Return the most frequency label."""
function vote!(g::AGraphOrDiGraph, m::Vector{Int}, c::NeighComm, u::Int)
    @inbounds for i=1:c.neigh_last-1
        c.neigh_cnt[c.neigh_pos[i]] = -1
    end
    c.neigh_last = 1
    c.neigh_pos[1] = m[u]
    c.neigh_cnt[c.neigh_pos[1]] = 0
    c.neigh_last = 2
    max_cnt = 0
    for neigh in out_neighbors(g,u)
        neigh_comm = m[neigh]
        if c.neigh_cnt[neigh_comm] < 0
            c.neigh_cnt[neigh_comm] = 0
            c.neigh_pos[c.neigh_last] = neigh_comm
            c.neigh_last += 1
        end
        c.neigh_cnt[neigh_comm] += 1
        if c.neigh_cnt[neigh_comm] > max_cnt
          max_cnt = c.neigh_cnt[neigh_comm]
        end
    end
    # ties breaking randomly
    range_shuffle!(1:c.neigh_last-1, c.neigh_pos)
    for lbl in c.neigh_pos
      if c.neigh_cnt[lbl] == max_cnt
        return lbl
      end
    end
end

function renumber_labels!(membership::Vector{Int}, label_counters::Vector{Int})
    N = length(membership)
    (maximum(membership) > N || minimum(membership) < 1) && error("Label must between 1 and |V|")
    j = 1
    @inbounds for i=1:length(membership)
        k = membership[i]
        if k >= 1
            if label_counters[k] == 0
                # We have seen this label for the first time
                label_counters[k] = j
                k = j
                j += 1
            else
                k = label_counters[k]
            end
        end
        membership[i] = k
    end
end
