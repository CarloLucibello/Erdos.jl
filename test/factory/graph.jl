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

@test Graph(0) == Graph() == Graph{Int}() == Graph{Int}(0)
@test DiGraph(0) == DiGraph() == DiGraph{Int}() == DiGraph{Int}(0)


g = G(10, 20)
@test G(g) isa G
@test g == G(g)
@test g == g |> Network |> G

g = DG(10, 20)
@test DG(g) isa DG
@test g == DG(g) 
@test g == g |> DiNetwork |> DG
  
end # testset
