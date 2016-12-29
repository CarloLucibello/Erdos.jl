w = Dict(Edge(1,2)=> 500)
g =G(2)
add_edge!(g,1,2)
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 2


w=Dict( Edge(1,2)=>500,
        Edge(1,3)=>600,
        Edge(2,3)=>700,
        Edge(3,4)=>100,
        Edge(2,4)=>1000)

g = CompleteGraph(4, G)
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 2
@test match.mate[2] == 1
@test match.mate[3] == 4
@test match.mate[4] == 3
@test match.weight == 600

w = Dict(
        Edge(1, 2) => 500,
        Edge(1, 3) => 400,
        Edge(2, 3) => 300,
        Edge(3, 4) => 1000,
        Edge(2, 4) => 1000
    )
g = CompleteGraph(4, G)
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 3
@test match.mate[2] == 4
@test match.mate[3] == 1
@test match.mate[4] == 2
@test match.weight == 1400

g =CompleteBipartiteGraph(2,2, G)
w =Dict{Edge,Float64}()
w[Edge(1,3)] = -10
w[Edge(1,4)] = -0.5
w[Edge(2,3)] = -11
w[Edge(2,4)] = -1

match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 4
@test match.mate[4] == 1
@test match.mate[2] == 3
@test match.mate[3] == 2
@test match.weight == -11.5


g =CompleteGraph(4, G)
w =Dict{Edge,Float64}()
w[Edge(1,3)] = 10
w[Edge(1,4)] = 0.5
w[Edge(2,3)] = 11
w[Edge(2,4)] = 2
w[Edge(1,2)] = 100

match = minimum_weight_perfect_matching(g, w, 50)
@test match.mate[1] == 4
@test match.mate[4] == 1
@test match.mate[2] == 3
@test match.mate[3] == 2
@test match.weight == 11.5
