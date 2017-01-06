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

g = crosspath(3, BinaryTree(2, G))
@test typeof(g) == G
I = [1,1,1,2,2,3,3,4,4,4,4,5,5,5,6,6,6,7,7,7,8,8,9,9]
J = [2,3,4,1,5,1,6,1,5,6,7,2,4,8,3,4,9,4,8,9,5,7,6,7]
V = ones(Int, length(I))
Adj = sparse(I,J,V)
@test Adj == sparse(g)

g = DoubleBinaryTree(3, G)
@test typeof(g) == G
I = [1,1,1,2,2,2,3,3,3,4,5,6,7,8,8,8,9,9,9,10,10,10,11,12,13,14]
J = [3,2,8,4,1,5,1,6,7,2,2,3,3,10,9,1,11,8,12,8,13,14,9,9,10,10]
V = ones(Int, length(I))
Adj = sparse(I,J,V)
@test Adj == sparse(g)

rg3 = RoachGraph(3, G)
@test typeof(g) == G
I = [ 1,2,3,3,4,4,5,5,6,6,7,7,7,8,8,8,9,9,9,10,10,10,11,11,12,12 ]
J = [ 3,4,1,5,2,6,3,7,4,8,9,8,5,10,7,6,11,10,7,8,9,12,9,12,10,11 ]
V = ones(Int, length(I))
Adj = sparse(I,J,V)
@test Adj == sparse(rg3)
