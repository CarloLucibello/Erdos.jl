g3 = PathGraph(5, G)
@test adjacency_matrix(g3)[3,2] == 1
@test adjacency_matrix(g3)[2,4] == 0
@test laplacian_matrix(g3)[3,2] == -1
@test laplacian_matrix(g3)[1,3] == 0
@test laplacian_spectrum(g3)[5] == 3.6180339887498945
@test adjacency_spectrum(g3)[1] == -1.732050807568878

g5 = DG(4)
add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
@test laplacian_spectrum(g5)[3] == laplacian_spectrum(g5,:out)[3] == 1.0
@test laplacian_spectrum(g5,:all)[3] == 3.0
@test laplacian_spectrum(g5,:in)[3] == 1.0

# check adjacency matrices with self loops
g = copy(g3)
add_edge!(g,1,1)
@test adjacency_matrix(g)[1,1] == 2

g10 = CompleteGraph(10, G)
B, em = non_backtracking_matrix(g10)
@test length(em) == 2*ne(g10)
@test size(B) == (2*ne(g10),2*ne(g10))
for i=1:10
    @test sum(B[:,i]) == 8
    @test sum(B[i,:]) == 8
end
@test !issymmetric(B)

v = ones(Float64, ne(g10))
z = zeros(Float64, nv(g10))
n10 = Nonbacktracking(g10)
@test size(n10) == (2*ne(g10), 2*ne(g10))
@test eltype(n10) == Float64
@test !issymmetric(n10)

FatGraphs.contract!(z, n10, v)

zprime = contract(n10, v)
@test z == zprime
@test z == 9*ones(Float64, nv(g10))

@test_approx_eq_eps(adjacency_spectrum(g5)[3],0.311, 0.001)
# @test adjacency_spectrum(g5)[3] ≈ 0.311  atol=0.001

@test adjacency_matrix(g3) ==
    adjacency_matrix(g3, :out) ==
    adjacency_matrix(g3, :in) ==
    adjacency_matrix(g3, :all)

@test_throws ErrorException adjacency_matrix(g3, :purple)

#that call signature works
inmat   = adjacency_matrix(g5, :in, Int)
outmat  = adjacency_matrix(g5, :out, Int)
bothmat = adjacency_matrix(g5, :all, Int)

#relations that should be true
@test inmat' == outmat
@test all((bothmat - outmat) .>= 0)
@test all((bothmat - inmat)  .>= 0)

#check properties of the undirected laplacian carry over.
for dir in [:in, :out, :all]
    amat = adjacency_matrix(g5, dir, Float64)
    lmat = laplacian_matrix(g5, dir, Float64)
    @test isa(amat, SparseMatrixCSC{Float64, Int64})
    @test isa(lmat, SparseMatrixCSC{Float64, Int64})
    evals = eigvals(full(lmat))
    @test all(evals .>= -1e-15) # positive semidefinite
    @test_approx_eq_eps minimum(evals) 0 1e-13
    # @test minimum(evals) ≈ 0 atol=1e-13
end

g4 = PathDiGraph(5, DG)
# testing incidence_matrix, first directed graph
@test size(incidence_matrix(g4)) == (5,4)
@test incidence_matrix(g4)[1,1] == -1
@test incidence_matrix(g4)[2,1] == 1
@test incidence_matrix(g4)[3,1] == 0


g3 = PathGraph(5, G)
# now undirected graph
@test size(incidence_matrix(g3)) == (5,4)
@test incidence_matrix(g3)[1,1] == 1
@test incidence_matrix(g3)[2,1] == 1
@test incidence_matrix(g3)[3,1] == 0

i3o = incidence_matrix(g3; oriented=true)
@test i3o == incidence_matrix(g4)
@test laplacian_matrix(g3) == i3o * i3o'

# TESTS FOR Nonbacktracking operator.

n = 10; k = 5
pg = CompleteGraph(n, G)
# ϕ1 = nonbacktrack_embedding(pg, k)'

nbt = Nonbacktracking(pg)
B, emap = non_backtracking_matrix(pg)
Bs = sparse(nbt)
@test sparse(B) == Bs
@test_approx_eq_eps(eigs(nbt, nev=1)[1], eigs(B, nev=1)[1], 1e-5)
# @test eigs(nbt, nev=1)[1] ≈ eigs(B, nev=1)[1] atol=1e-5


# check that matvec works
x = ones(Float64, nbt.m)
y = nbt * x
z = B * x
@test norm(y-z) < 1e-8

#check that matmat works and full(nbt) == B
@test norm(nbt*eye(nbt.m) - B) < 1e-8

#check that matmat works and full(nbt) == B
@test norm(nbt*eye(nbt.m) - B) < 1e-8

#check that we can use the implicit matvec in nonbacktrack_embedding
@test size(y) == size(x)

B₁ = Nonbacktracking(g10)

# just so that we can assert equality of matrices

if !isdefined(:test_full)
    test_full(nbt::Nonbacktracking) = full(sparse(nbt))
end

@test test_full(B₁) == full(B)
@test  B₁ * ones(size(B₁)[2]) == B*ones(size(B)[2])
@test size(B₁) == size(B)
# @test_approx_eq_eps norm(eigs(B₁)[1] - eigs(B)[1]) 0.0 1e-8 #TODO change test, it is unstable
# END tests for Nonbacktracking

# spectral distance checks
for n=3:10
  polygon = random_regular_graph(n, 2)
  @test isapprox(spectral_distance(polygon, polygon), 0, atol=1e-8)
  @test isapprox(spectral_distance(polygon, polygon, 1), 0, atol=1e-8)
end
