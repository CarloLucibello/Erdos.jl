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
    # "distances/distance",
    # "distances/edit_distance",
    "linalg/spectral",
    "persistence/persistence",
    "generators/randgraphs",
    "generators/staticgraphs",
    "generators/smallgraphs",
    "generators/euclideangraphs",
    "generators/matrixdepot",
    # "shortestpaths/astar",
    "shortestpaths/bellman-ford",
    # "shortestpaths/dijkstra",
    "shortestpaths/floyd-warshall",
    "traversals/bfs",
    "traversals/dfs",
    # "traversals/maxadjvisit",
    "traversals/graphvisit",
    "traversals/randomwalks",
    "traversals/connectivity",
    "community/core-periphery",
    "community/cliques",
    "community/modularity",
    "community/clustering",
    "community/detection",
    # "centrality/betweenness",
    # "centrality/closeness",
    "centrality/degree",
    "centrality/katz",
    "centrality/pagerank",
    "centrality/kcore",
    # "flow/edmonds_karp",
    # "flow/dinic",
    # "flow/boykov_kolmogorov",
    # "flow/push_relabel",
    # "flow/maximum_flow",
    # "flow/multiroute_flow",
    "spanningtrees/spanningtrees",
    # "spanningtrees/kruskal",
    "matching/matching",
    # "dismantling/dismantling",
    "utils"
]

testdir = dirname(@__FILE__)
datasets_dir = normpath(joinpath(@__FILE__,"..","..","datasets"))

# E = GTEdge
GLIST =    [
            (Graph{Int64}, DiGraph{Int64}),
            (Graph{UInt32}, DiGraph{UInt32}),
            (GTGraph, GTDiGraph)
            ]

# println("## Testing FatGraphs")
# @testset "$(x[1])" for x in GLIST
#     global G = x[1]
#     global DG = x[2]
#     @testset "$t" for t in tests
#         include(joinpath(testdir,"$(t).jl"))
#     end
# end
# println("## Finished Testing FatGraphs")

println("Testing FatGraphs")
@testset "$t  $(GDG[1])" for GDG in GLIST, t in tests
    global G = GDG[1]
    global DG = GDG[2]
    global E = edgetype(G())
    # println("$x")
    include(joinpath(testdir,"$(t).jl"))
end
println("Finished testing FatGraphs")
