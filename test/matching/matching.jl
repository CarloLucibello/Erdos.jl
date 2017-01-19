g =G(2)
add_edge!(g,1,2)
w = EdgeMap(g, Int)
w[1,2]=500
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 2

g = CompleteGraph(4, G)
w = EdgeMap(g, Int)
w[1,2]=500
w[1,3]=600
w[2,3]=700
w[3,4]=100
w[2,4]=1000
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 2
@test match.mate[2] == 1
@test match.mate[3] == 4
@test match.mate[4] == 3
@test match.weight == 600

g = CompleteGraph(4, G)
w = EdgeMap(g, Int)
w[1, 2]=500
w[1, 3]=400
w[2, 3]=300
w[3, 4]=1000
w[2, 4]=1000
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 3
@test match.mate[2] == 4
@test match.mate[3] == 1
@test match.mate[4] == 2
@test match.weight == 1400

g =CompleteBipartiteGraph(2,2, G)
w = EdgeMap(g, Float64)
w[1,3] = -10
w[1,4] = -0.5
w[2,3] = -11
w[2,4] = -1
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 4
@test match.mate[4] == 1
@test match.mate[2] == 3
@test match.mate[3] == 2
@test match.weight == -11.5

g =CompleteGraph(4, G)
w = EdgeMap(g, Float64)
w[1,3] = 10
w[1,4] = 0.5
w[2,3] = 11
w[2,4] = 2
w[1,2] = 100
match = minimum_weight_perfect_matching(g, w, 50)
@test match.mate[1] == 4
@test match.mate[4] == 1
@test match.mate[2] == 3
@test match.mate[3] == 2
@test match.weight == 11.5
