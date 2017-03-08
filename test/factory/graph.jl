@testset "$TEST $G" begin

#tests for the concrete types Graph and DiGraph
g = DiGraph(10, 20)
@test  nv(g) == 10
@test  ne(g) == 20
@test typeof(g) == DiGraph{Int}
@test vertextype(g) == Int
@test edgetype(g) == Edge{Int}

g = Graph(10, 20)
@test  nv(g) == 10
@test  ne(g) == 20
@test typeof(g) == Graph{Int}
@test edgetype(g) == Edge{Int}

w = sprand(10,10, 0.1)
@test Graph(w) == Graph{Int}(w)
@test DiGraph(w) == DiGraph{Int}(w)

end # testset
