@testset "$TEST $G" begin

g5 = DG(4)
add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
@test isapprox(pagerank(g5)[3], 0.318,  atol=0.001)
@test_throws ErrorException pagerank(g5, 2)
@test_throws ErrorException pagerank(g5, 0.85, 2)

end # testset
