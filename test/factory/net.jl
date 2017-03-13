@testset "$TEST $G" begin

g = Net(10)
@test graphtype(g) == Net
@test digraphtype(g) == DiNet
@test edgetype(g) == IndexedEdge
@test vertextype(g) == Int

g = DiNet(10)
@test graphtype(g) == Net
@test digraphtype(g) == DiNet
@test edgetype(g) == IndexedEdge
@test vertextype(g) == Int

end # testset
