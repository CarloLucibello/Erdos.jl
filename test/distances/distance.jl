@testset "$TEST $G" begin

adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
a1 = G(adjmx1)
a2 = DG(adjmx2)

distmx1 = EdgeMap(a1,[Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf])
distmx2 = EdgeMap(a2,[Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf])

g4 = PathDiGraph(5, DG)
@test_throws ErrorException eccentricities(g4)
z = eccentricities(a1, distmx1)
@test z == [6.2, 4.2, 6.2]
@test maximum(z) == diameter(a1, distmx1) == 6.2
@test periphery(z) == periphery(a1, distmx1) == [1,3]
@test minimum(z) == radius(a1, distmx1) == 4.2
@test center(z) == center(a1, distmx1) == [2]

z = eccentricities(a2, distmx2)
@test z == [6.2, 4.2, 6.1]
@test maximum(z) == diameter(a2, distmx2) == 6.2
@test periphery(z) == periphery(a2, distmx2) == [1]
@test minimum(z) == radius(a2, distmx2) == 4.2
@test center(z) == center(a2, distmx2) == [2]
@test z[3] == eccentricity(a2, 3, distmx2)

end # testset
