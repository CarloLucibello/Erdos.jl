@testset "$TEST $G" begin

g3 = PathGraph(5, G)
@test adjacency_matrix(g3)[3,2] == 1
@test adjacency_matrix(g3)[2,4] == 0
@test laplacian_matrix(g3)[3,2] == -1
@test laplacian_matrix(g3)[1,3] == 0

# check adjacency matrices with self loops
g = copy(g3)
add_edge!(g,1,1)
@test adjacency_matrix(g)[1,1] == 2

g10 = CompleteGraph(10, G)
B, em = nonbacktracking_matrix(g10)
@test length(em) == 2*ne(g10)
@test size(B) == (2*ne(g10),2*ne(g10))
for i=1:10
    @test sum(B[:,i]) == 8
    @test sum(B[i,:]) == 8
end
@test !issymmetric(B)


@test adjacency_matrix(g3) ==
    adjacency_matrix(g3, :out) ==
    adjacency_matrix(g3, :in) ==
    adjacency_matrix(g3, :all)

@test_throws ErrorException adjacency_matrix(g3, :purple)

g5 = DG(4)
add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
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
    evals = eigvals(Matrix(lmat))
    @test all(evals .>= -1e-15) # positive semidefinite
    @test isapprox(minimum(evals),0, atol=1e-13)
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

n = 10; k = 5
pg = CompleteGraph(n, G)
# ϕ1 = nonbacktrack_embedding(pg, k)'
B, emap = nonbacktracking_matrix(pg)
## TODO add test

# spectral distance checks
for n=3:10
  polygon = random_regular_graph(n, 2)
  @test isapprox(spectral_distance(polygon, polygon), 0, atol=1e-8)
  @test isapprox(spectral_distance(polygon, polygon, 1), 0, atol=1e-8)
end

end # testset
