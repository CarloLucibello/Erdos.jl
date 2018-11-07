using Erdos
using Test
using Random
using SparseArrays
using LinearAlgebra
using Arpack
using Statistics

testdir = dirname(@__FILE__)

tests = [
    # "factory/graph",
    # "factory/net",
    # "core/edge",
    # "core/interface_graph",
    # "core/interface_network",
    # "core/core",
    # "core/edgeiter",
    # "maps/vertexmap",
    # "maps/edgemap",
    # "maps/property_store",
    # "operators/operators",
    # "distances/distance",
    # "distances/edit_distance",
    # "linalg/spectral",
    # "persistence/persistence",
    # "persistence/datasets",
    # "persistence/gt",
    # "persistence/gexf",
    # "persistence/graphml",
    # "persistence/gml",
    # "generators/randgraphs",
    # "generators/staticgraphs",
    # "generators/smallgraphs",
    # "generators/euclideangraphs",
    # "shortestpaths/astar",
    # "shortestpaths/bellman-ford",
    # "shortestpaths/dijkstra",
    # "shortestpaths/floyd-warshall",
    # "traversals/bfs",
    # "traversals/dfs",
    # "traversals/maxadjvisit",
    # "traversals/graphvisit",
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
    "centrality/kcore",
    "flow/edmonds_karp",
    "flow/dinic",
    "flow/boykov_kolmogorov",
    "flow/push_relabel",
    "flow/maximum_flow",
    "flow/multiroute_flow",
    "spanningtrees/spanningtrees",
    "spanningtrees/kruskal",
    "dismantling/dismantling",
    "utils"
]

include("common.jl")

GLIST =    [
            (Graph{Int64}, DiGraph{Int64}),
            (Graph{UInt32}, DiGraph{UInt32}),
            (Network, DiNetwork)
            ]

for GDG in GLIST, t in tests
    global G = GDG[1]
    global DG = GDG[2]
    global TEST = t
    global E = edgetype(G)
    global V = vertextype(G)

    include(joinpath(testdir,"$(t).jl"))
end

println("Finished testing Erdos")
