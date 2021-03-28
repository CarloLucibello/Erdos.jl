@testset "$TEST $G" begin

g = Network(10)
@test nv(g) == 10
@test graphtype(g) == Network
@test digraphtype(g) == DiNetwork
@test edgetype(g) == IndexedEdge
@test vertextype(g) == Int

g = DiNetwork(10)
@test nv(g) == 10
@test graphtype(g) == Network
@test digraphtype(g) == DiNetwork
@test edgetype(g) == IndexedEdge
@test vertextype(g) == Int

net = Network(10, 20)
@test net == Network(net)

net = DiNetwork(10, 20)
@test net == DiNetwork(net) 

# test roundtrip to graph
net = Network(10, 20) # erdos_renyi
@test  net == net |> G |> Network  
@test  net == net |> Graph |> Network  
net = DiNetwork(10, 20)
@test  net == net |> DG |> DiNetwork
@test  net == net |> DiGraph |> DiNetwork  

end # testset
