@test_throws ErrorException eccentricity(g4)
z = eccentricity(a1, distmx1)
@test z == [6.2, 4.2, 6.2]
@test diameter(z) == diameter(a1, distmx1) == 6.2
@test periphery(z) == periphery(a1, distmx1) == [1,3]
@test radius(z) == radius(a1, distmx1) == 4.2
@test center(z) == center(a1, distmx1) == [2]

z = eccentricity(a2, distmx2)
@test z == [6.2, 4.2, 6.1]
@test diameter(z) == diameter(a2, distmx2) == 6.2
@test periphery(z) == periphery(a2, distmx2) == [1]
@test radius(z) == radius(a2, distmx2) == 4.2
@test center(z) == center(a2, distmx2) == [2]

@test size(LightGraphs.DefaultDistance()) == (typemax(Int), typemax(Int))
d = LightGraphs.DefaultDistance(3)
@test size(d) == (3, 3)
@test d[1,1] == 1
@test d[1:2, 1:2] == LightGraphs.DefaultDistance(2)
@test d == transpose(d) == ctranspose(d)
