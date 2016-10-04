# construct graph
G = DiGraph(3)
add_edge!(G,1,2)
add_edge!(G,2,3)

# source and sink terminals
source, target = 1, 3

# default capacity
capacity_matrix = FatGraphs.DefaultCapacity(G)

# state variables
flow_matrix = zeros(Int, 3, 3)

TREE = zeros(Int, 3)
TREE[source] = 1
TREE[target] = 2

PARENT = zeros(Int, 3)

A = [source,target]

residual_graph = FatGraphs.residual(G)

path = FatGraphs.find_path!(residual_graph, source, target, flow_matrix, capacity_matrix, PARENT, TREE, A)

@test path == [1,2,3]
