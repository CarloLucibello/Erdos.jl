include("../src/FatGraphs.jl")
using FatGraphs
using Base.Test

g1 = smallgraph(:petersen)
g2 = smallgraph(:tutte)
g3 = PathGraph(5)
g4 = PathDiGraph(5)
g5 = DiGraph(4)
add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
g6 = smallgraph(:house)

h1 = Graph(5)
h2 = Graph(3)
h3 = Graph()
h4 = DiGraph(7)
h5 = DiGraph()

# self loops
s2 = DiGraph(3)
add_edge!(s2,1,2); add_edge!(s2,2,3); add_edge!(s2,3,3)
s1 = graph(s2)

r1 = Graph(10,20)
r2 = DiGraph(5,10)

e0 = Edge(2, 3)
e1 = Edge(1, 2)
re1 = Edge(2, 1)

# polygons
triangle = random_regular_graph(3,2)
quadrangle = random_regular_graph(4,2)
pentagon = random_regular_graph(5,2)

testdir = dirname(@__FILE__)

p1 = readgraph(joinpath(testdir,"testdata","tutte.gml"),:gml)
p2 = readgraph(joinpath(testdir,"testdata","pathdigraph.gml"),:gml)


adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
distmx1 = [Inf 2.0 Inf; 2.0 Inf 4.2; Inf 4.2 Inf]
distmx2 = [Inf 2.0 Inf; 3.2 Inf 4.2; 5.5 6.1 Inf]

a1 = Graph(adjmx1)
a2 = DiGraph(adjmx2)

tests = [
    "core/edge",
    "core/interface",
    "core/core",
    "core/edgeiter",
    "core/operators",
    "core/connectivity",
    "factory/graphdigraph",
    "distances/distance",
    "distances/edit_distance",
    "linalg/spectral",
    "persistence/persistence",
    "generators/randgraphs",
    "generators/staticgraphs",
    "generators/smallgraphs",
    "generators/euclideangraphs",
    "generators/matrixdepot",
    "shortestpaths/astar",
    "shortestpaths/bellman-ford",
    "shortestpaths/dijkstra",
    "shortestpaths/floyd-warshall",
    "traversals/bfs",
    "traversals/dfs",
    "traversals/maxadjvisit",
    "traversals/graphvisit",
    "traversals/randomwalks",
    "community/core-periphery",
    "community/cliques",
    "community/modularity",
    "community/clustering",
    "community/detection",
    "centrality/betweenness",
    "centrality/closeness",
    "centrality/degree",
    "centrality/katz",
    "centrality/pagerank",
    "flow/edmonds_karp",
    "flow/dinic",
    "flow/boykov_kolmogorov",
    "flow/push_relabel",
    "flow/maximum_flow",
    "flow/multiroute_flow",
    "spanningtrees/kruskal",
    "matching/matching",
    "interdiction/interdiction",
    "utils"
]


for t in tests
    tp = joinpath(testdir,"$(t).jl")
    println("running $(tp) ...")
    include(tp)
end
