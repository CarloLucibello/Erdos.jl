@testset "$TEST $G" begin

g = Network(10)
@test graphtype(g) == Network
@test digraphtype(g) == DiNetwork
@test edgetype(g) == IndexedEdge
@test vertextype(g) == Int

g = DiNetwork(10)
@test graphtype(g) == Network
@test digraphtype(g) == DiNetwork
@test edgetype(g) == IndexedEdge
@test vertextype(g) == Int

end # testset
