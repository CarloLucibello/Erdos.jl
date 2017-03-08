@testset "$TEST $G" begin

g3 = PathGraph(5, G)
g4 = PathDiGraph(5, DG)

d1 = EdgeMap(g3, float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0]))
d2 = EdgeMap(g3, sparse(float([ 0 1 2 3 4; 5 0 6 7 8; 9 10 0 11 12; 13 14 15 0 16; 17 18 19 20 0])))

@test a_star(g3, 1, 4, d1) ==
    a_star(g4, 1, 4, d1) ==
    a_star(g3, 1, 4, d2)

@test a_star(g4, 4, 1) == Vector{Edge{V}}()

end # testset
