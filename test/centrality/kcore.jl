@testset "$TEST $G" begin

g = CompleteGraph(5, G)
klist = cores(g)
@test klist == fill(4, 5)

g = PathGraph(3)
klist = cores(g)
@test klist == fill(1, 3)

g = CycleGraph(3)
klist = cores(g)
@test klist == fill(2, 3)

add_vertex!(g)
add_edge!(g, 3, 4)
klist = cores(g)
@test klist == [2, 2, 2, 1]

h, vmap = kcore(g, 2)
@test h == CycleGraph(3)
@test vmap == [1,2,3]

end # testset
