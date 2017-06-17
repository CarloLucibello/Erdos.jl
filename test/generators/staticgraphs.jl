@testset "$TEST $G" begin

g = CompleteDiGraph(5, DG)
@test nv(g) == 5 && ne(g) == 20
@test typeof(g) == DG

g = CompleteGraph(5, G)
@test nv(g) == 5 && ne(g) == 10
@test typeof(g) == G

g = CompleteBipartiteGraph(5, 8, G)
@test nv(g) == 13 && ne(g) == 40
@test typeof(g) == G
g = StarDiGraph(5, DG)
@test nv(g) == 5 && ne(g) == 4
g = StarGraph(5, G)
@test typeof(g) == G
@test nv(g) == 5 && ne(g) == 4
g = StarGraph(1, G)
@test typeof(g) == G
@test nv(g) == 1 && ne(g) == 0

g = PathDiGraph(5, DG)
@test typeof(g) == DG
@test nv(g) == 5 && ne(g) == 4
g = PathGraph(5, G)
@test typeof(g) == G
@test nv(g) == 5 && ne(g) == 4

g = CycleDiGraph(5, DG)
@test typeof(g) == DG
@test nv(g) == 5 && ne(g) == 5
g = CycleGraph(5, G)
@test typeof(g) == G
@test nv(g) == 5 && ne(g) == 5

g = WheelDiGraph(5, DG)
@test typeof(g) == DG
@test nv(g) == 5 && ne(g) == 8
g = WheelGraph(5, G)
@test typeof(g) == G
@test nv(g) == 5 && ne(g) == 8

g = Grid([3,3,4], G)
@test typeof(g) == G
@test nv(g) == 3*3*4
@test ne(g) == 75
@test maximum(degree(g)) == 6
@test minimum(degree(g)) == 3

g = CliqueGraph(3,5, G)
@test typeof(g) == G
@test nv(g) == 15 && ne(g) == 20
@test g[1:3] == CompleteGraph(3, G)

g = crosspath(BinaryTree(2, G), 3)
@test typeof(g) == G
@test nv(g) == 9
@test ne(g) == 12

g = DoubleBinaryTree(3, G)
@test typeof(g) == G
@test nv(g) == 14
@test ne(g) == 13

rg3 = RoachGraph(3, G)
@test typeof(g) == G
@test nv(g) == 14
@test ne(g) == 13

end # testset
