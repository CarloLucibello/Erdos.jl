@testset "$TEST $G" begin

g = GTGraph(10)
@test graphtype(g) == GTGraph
@test digraphtype(g) == GTDiGraph
@test edgetype(g) == GTEdge
@test vertextype(g) == Int

g = GTDiGraph(10)
@test graphtype(g) == GTGraph
@test digraphtype(g) == GTDiGraph
@test edgetype(g) == GTEdge
@test vertextype(g) == Int

end # testset
