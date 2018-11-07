@testset "$TEST $G" begin

g5 = DG(4)
add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
z = katz_centrality(g5, 0.4)
@test round.(z, digits=2) == [0.32, 0.44, 0.62, 0.56]

end # testset
