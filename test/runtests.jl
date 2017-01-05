include("../src/FatGraphs.jl")
using FatGraphs
using Base.Test

tests = [
    "factory/graph",
    "factory/gtgraph",
    "core/edge",
    "core/interface",
    "core/core",
    "core/edgeiter",
    "operators/operators",
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
    "traversals/connectivity",
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
    "spanningtrees/spanningtrees",
    "spanningtrees/kruskal",
    "matching/matching",
    "utils"
]


testdir = dirname(@__FILE__)
# (G, DG) = (Graph{Int32}, DiGraph{Int32})
E = Edge
# (G, DG) = (GTGraph, GTDiGraph)
# E = GTEdge
GLIST =    [
            (Graph{Int64}, DiGraph{Int64}),
            (Graph{UInt32}, DiGraph{UInt32}),
            (GTGraph, GTDiGraph)
            ]

# @testset "FatGraphs Testing" begin
for x in GLIST
    global G = x[1]
    global DG = x[2]
    println("@@ TESTING $G and $DG")
    for t in tests
        tp = joinpath(testdir,"$(t).jl")
        # (G, DG) = (Graph, DiGraph)
        println("running $t.jl")
        #TODO stop when failing a testset
        # @testset "$t" begin
            include(tp)
        # end
    end
end
