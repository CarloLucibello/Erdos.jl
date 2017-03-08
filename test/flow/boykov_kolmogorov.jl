@testset "$TEST $G" begin

# construct graph
g = DG(3)
add_edge!(g,1,2)
add_edge!(g,2,3)

# source and sink terminals
source, target = 1, 3

# default capacity
capacity_matrix = Erdos.DefaultCapacity(g)

# state variables
flow_matrix = zeros(typeof(signed(V(0))), 3, 3)

TREE = zeros(Int, 3)
TREE[source] = 1
TREE[target] = 2

PARENT = zeros(Int, 3)

A = [source,target]

residual_graph = complete(g)

path = Erdos.find_path!(residual_graph, source, target, flow_matrix, capacity_matrix, PARENT, TREE, A)

@test path == [1,2,3]

end # testset
