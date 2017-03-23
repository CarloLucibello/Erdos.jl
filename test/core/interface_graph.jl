if !isdefined(:TestIGraph)
    type TestIGraph <: AGraph; end
    type TestIDiGraph <: ADiGraph; end
    type TestIEdge <: AEdge; end
end

@testset "$TEST $G" begin

g = TestIGraph()
h = TestIDiGraph()
e = TestIEdge()

@test_throws ErrorException src(e)
@test_throws ErrorException dst(e)
@test_throws ErrorException reverse(e)

@test_throws ErrorException nv(g)
@test_throws ErrorException nv(h)
@test_throws ErrorException neighbors(g, 1)
@test edge(g, 1, 2) == Edge{Int}(1, 2)
@test edge(h, 1, 2) == Edge{Int}(1, 2)
@test_throws MethodError idx(Edge(1, 2))
@test_throws ErrorException neighbors(g, 1)
@test_throws ErrorException in_neighbors(h, 1)
@test_throws ErrorException out_neighbors(h, 1)
@test_throws ErrorException graphtype(h)
@test_throws ErrorException digraphtype(g)
@test edgetype(g) == Edge{Int}
@test_throws ErrorException  pop_vertex!(g)
@test vertextype(g) == Int
@test_throws ErrorException add_edge!(g, 1, 2)
@test_throws ErrorException ne(g)
@test_throws ErrorException rem_edge!(g, 1, 2)
@test_throws ErrorException add_vertex!(g)
@test_throws ErrorException swap_vertices!(g, 1, 2)

@test graphtype(Graph) == Graph{Int}
@test graphtype(DiGraph) == Graph{Int}
@test digraphtype(Graph) == DiGraph{Int}
@test digraphtype(DiGraph) == DiGraph{Int}

end # testset
