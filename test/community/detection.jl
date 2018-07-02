@testset "$TEST $G" begin

# TODO some tests here intermittently fail on travis-ci
# using @test_skip for the time being

if !@isdefined(nonbacktrack_embedding_dense)
    #= Spectral embedding of the non-backtracking matrix of `g`
    (see [Krzakala et al.](http://www.pnas.org/content/110/52/20935.short)).

    `g`: imput Graph
    `k`: number of dimensions in which to embed

    return : a matrix ϕ where ϕ[:,i] are the coordinates for vertex i.
    =#
    function nonbacktrack_embedding_dense(g::AGraph, k::Int)
        B, edgeid = nonbacktracking_matrix(g)
        λ,eigv,conv = eigs(B, nev=k+1, v0=ones(Float64, size(B,1)))
        ϕ = zeros(Complex64, k-1, nv(g))
        # TODO decide what to do with the stationary distribution ϕ[:,1]
        # this code just throws it away in favor of eigv[:,2:k+1].
        # we might also use the degree distribution to scale these vectors as is
        # common with the laplacian/adjacency methods.
        E = Edge{vertextype(g)}
        for n=1:k-1
            v= eigv[:,n+1]
            for i=1:nv(g)
                for j in neighbors(g, i)
                    u = edgeid[E(j,i)]
                    ϕ[n,i] += v[u]
                end
            end
        end
        return ϕ
    end
end

n = 10; k = 5
pg = PathGraph(n, G)
ϕ1 = nonbacktrack_embedding(pg, k)'

nbt = Nonbacktracking(pg)
B, emap = nonbacktracking_matrix(pg)
Bs = sparse(nbt)
@test sparse(B) == Bs

# check that matvec works
x = ones(Float64, nbt.m)
y = nbt * x
z = B * x
@test norm(y-z) < 1e-8

#check that matmat works and full(nbt) == B
@test norm(nbt*eye(nbt.m) - B) < 1e-8

#check that we can use the implicit matvec in nonbacktrack_embedding
@test size(y) == size(x)
ϕ2 = nonbacktrack_embedding_dense(pg, k)'
@test size(ϕ2) == size(ϕ1)

#check that this recovers communities in the path of cliques
n=10
g10 = CompleteGraph(n, G)
z = copy(g10)
for k=2:5
    z = blockdiag(z, g10)
    add_edge!(z, (k-1)*n, k*n)

    c = community_detection_nback(z, k)
    @test sort(union(c)) == [1:k;]
    a = collect(n:n:k*n)
    #@test_skip length(c[a]) == length(unique(c[a]))
    for i=1:k
        for j=(i-1)*n+1:i*n
            #@test_skip c[j] == c[i*n]
        end
    end

    c = community_detection_bethe(z, k)
    @test sort(union(c)) == [1:k;]
    a = collect(n:n:k*n)
    #@test_skip length(c[a]) == length(unique(c[a]))

    for i=1:k
        for j=(i-1)*n+1:i*n
            @test c[j] == c[i*n]
        end
    end

    c = community_detection_bethe(z)
    @test sort(union(c)) == [1:k;]
    a = collect(n:n:k*n)
    #@test_skip length(c[a]) == length(unique(c[a]))
    for i=1:k
        for j=(i-1)*n+1:i*n
            @test c[j] == c[i*n]
        end
    end
end

n=10
g10 = CompleteGraph(n, G)
z = copy(g10)
for k=2:5
    z = blockdiag(z, g10)
    add_edge!(z, (k-1)*n, k*n)
    c, ch = label_propagation(z)
    a = collect(n:n:k*n)
    a = Int[div(i-1,n)+1 for i=1:k*n]
    # check the number of community
    # TODO fix tests
    # @test length(unique(a)) == length(unique(c))
    #@test_skip length(unique(a))== length(unique(c))
    # check the partition
    # @test a == c
end

end # testset
