@testset "$TEST $G" begin

g = WheelGraph(10, G)
h, vmap, reslist = dismantle_ci(g, 2, 1)
@test reslist == [1]
@test nv(h) == 9
@test ne(h) == ne(g) - 9
@test typeof(vmap) <: AVertexMap
# @test sort(vmap) == [2:10;]

g = StarGraph(10, G)
h, vmap, reslist = dismantle_ci(g, 2, 1)
@test reslist == [1]
@test nv(h) == 9
@test ne(h) == 0
# @test sort(vmap) == [2:10;]

g = PathGraph(3, G)
h, vmap, reslist = dismantle_ci(g, 2, 1)
@test reslist == [2]
@test nv(h) == 2
@test ne(h) == 0
@test typeof(vmap) <: AVertexMap
# @test sort(vmap) == [1,3]

g = CompleteGraph(10, G)
h, vmap, reslist = dismantle_ci(g, 2, 5)
# @test sort([reslist; vmap]) == [1:10;]
@test h == CompleteGraph(5, G)
@test typeof(vmap) <: AVertexMap

end # testset
