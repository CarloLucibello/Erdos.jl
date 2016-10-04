g =CompleteBipartiteGraph(2,2)
w =Dict{Edge,Float64}()
w[Edge(1,3)] = 10.
w[Edge(1,4)] = 1.
w[Edge(2,3)] = 2.
w[Edge(2,4)] = 11.
match = maximum_weight_maximal_matching(g,w)
@test match.weight == 21
@test match.mate[1] == 3
@test match.mate[3] == 1
@test match.mate[2] == 4
@test match.mate[4] == 2

g =CompleteBipartiteGraph(2,4)
w =Dict{Edge,Float64}()
w[Edge(1,3)] = 10
w[Edge(1,4)] = 0.5
w[Edge(2,3)] = 11
w[Edge(2,4)] = 1
match = maximum_weight_maximal_matching(g,w)
@test match.weight == 11.5
@test match.mate[1] == 4
@test match.mate[4] == 1
@test match.mate[2] == 3
@test match.mate[3] == 2

g =CompleteBipartiteGraph(2,6)
w =Dict{Edge,Float64}()
w[Edge(1,3)] = 10
w[Edge(1,4)] = 0.5
w[Edge(2,3)] = 11
w[Edge(2,4)] = 1
w[Edge(2,5)] = -1
w[Edge(2,6)] = -1
match = maximum_weight_maximal_matching(g,w,0)
@test match.weight == 11.5
@test match.mate[1] == 4
@test match.mate[4] == 1
@test match.mate[2] == 3
@test match.mate[3] == 2

g =CompleteBipartiteGraph(4,2)
w =Dict{Edge,Float64}()
w[Edge(3,5)] = 10
w[Edge(3,6)] = 0.5
w[Edge(2,5)] = 11
w[Edge(1,6)] = 1
w[Edge(1,5)] = -1

match = maximum_weight_maximal_matching(g,w,0)
@test match.weight == 12
@test match.mate[1] == 6
@test match.mate[2] == 5
@test match.mate[3] == -1
@test match.mate[4] == -1
@test match.mate[5] == 2
@test match.mate[6] == 1

w = Dict(Edge(1,2)=> 500)
g =Graph(2)
add_edge!(g,1,2)
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 2


w=Dict( Edge(1,2)=>500,
        Edge(1,3)=>600,
        Edge(2,3)=>700,
        Edge(3,4)=>100,
        Edge(2,4)=>1000)

g = CompleteGraph(4)
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
g = CompleteGraph(4)
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 3
@test match.mate[2] == 4
@test match.mate[3] == 1
@test match.mate[4] == 2
@test match.weight == 1400

g =CompleteBipartiteGraph(2,2)
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


g =CompleteGraph(4)
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
