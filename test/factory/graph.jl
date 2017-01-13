#tests for the concrete types Graph and DiGraph
g = DiGraph(10, 20)
@test  nv(g) == 10
@test  ne(g) == 20
@test typeof(g) == DiGraph{Int}

g = Graph(10, 20)
@test  nv(g) == 10
@test  ne(g) == 20
@test typeof(g) == Graph{Int}
