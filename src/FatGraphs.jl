__precompile__(true)
module FatGraphs

using GZip
using Distributions: Binomial # randgraphs
using Base.Collections
using LightXML # persistence
import ParserCombinator: Parsers.DOT, Parsers.GML # persistence
using StatsBase: fit, Histogram
import BlossomV # matching
using JuMP # matching/interdiction
using MathProgBase # interdiction
import Clustering: kmeans # community detection
using MatrixDepot # matrixdepot


# more imports in interdiction.jl

import Base: write, ==, <, *, ≈, isless, issubset, union, intersect,
            reverse, reverse!, blkdiag, getindex, setindex!, show, print, copy, in,
            sum, size, sparse, eltype, length, ndims, transpose,
            ctranspose, join, start, next, done, eltype, get, issymmetric, A_mul_B!


# core
export SimpleGraph, Edge, Graph, DiGraph, vertices, edges, src, dst,
fadj, badj, in_edges, out_edges, has_vertex, has_edge, is_directed,
nv, ne, add_edge!, rem_edge!, add_vertex!, add_vertices!,
indegree, outdegree, degree, degree_histogram, density, Δ, δ,
Δout, Δin, δout, δin, neighbors, in_neighbors, out_neighbors,
common_neighbors, all_neighbors, has_self_loops, num_self_loops,
rem_vertex!,

# distance
eccentricity, diameter, periphery, radius, center,

# distance between graphs
spectral_distance, edit_distance,

# edit path cost functions
MinkowskiCost, BoundedMinkowskiCost,

# operators
complement, reverse, reverse!, blkdiag, union, intersect,
difference, symmetric_difference,
join, tensor_product, cartesian_product, crosspath,
induced_subgraph, egonet,

# graph visit
SimpleGraphVisitor, TrivialGraphVisitor, LogGraphVisitor,
discover_vertex!, open_vertex!, close_vertex!,
examine_neighbor!, visited_vertices, traverse_graph!, traverse_graph_withlog,

# bfs
BreadthFirst, gdistances, gdistances!, bfs_tree, is_bipartite, bipartite_map,

# dfs
DepthFirst, is_cyclic, topological_sort_by_dfs, dfs_tree,

# random
randomwalk, saw, non_backtracking_randomwalk,

# connectivity
connected_components, strongly_connected_components, weakly_connected_components,
is_connected, is_strongly_connected, is_weakly_connected, period,
condensation, attracting_components, neighborhood, isgraphical,


# maximum_adjacency_visit
MaximumAdjacency, AbstractMASVisitor, mincut, maximum_adjacency_visit,

# a-star, dijkstra, bellman-ford, floyd-warshall
a_star, dijkstra_shortest_paths,
bellman_ford_shortest_paths, has_negative_edge_cycle, enumerate_paths,
floyd_warshall_shortest_paths,

# centrality
betweenness_centrality, closeness_centrality, degree_centrality,
indegree_centrality, outdegree_centrality, katz_centrality, pagerank,

# spectral
adjacency_matrix,laplacian_matrix, adjacency_spectrum, laplacian_spectrum,
CombinatorialAdjacency, non_backtracking_matrix, incidence_matrix,
nonbacktrack_embedding, Nonbacktracking,
contract,

# astar
a_star,

# persistence
readgraph, writegraph,

# flow
maximum_flow, EdmondsKarpAlgorithm, DinicAlgorithm, BoykovKolmogorovAlgorithm, PushRelabelAlgorithm,
multiroute_flow, KishimotoAlgorithm, ExtendedMultirouteFlowAlgorithm,

# randgraphs
erdos_renyi, watts_strogatz, random_regular_graph, random_regular_digraph, random_configuration_model,
StochasticBlockModel, make_edgestream, nearbipartiteSBM, blockcounts, blockfractions,
stochastic_block_model, barabasi_albert, barabasi_albert!, static_fitness_model, static_scale_free,

#community
modularity, core_periphery_deg,
local_clustering,local_clustering_coefficient, global_clustering_coefficient, triangles,
label_propagation, maximal_cliques,
community_detection_nback, community_detection_bethe,

#generators
CompleteGraph, StarGraph, PathGraph, WheelGraph, CycleGraph,
CompleteBipartiteGraph, CompleteDiGraph, StarDiGraph, PathDiGraph, Grid,
WheelDiGraph, CycleDiGraph, BinaryTree, DoubleBinaryTree, RoachGraph, CliqueGraph,

#smallgraphs
smallgraph,

# Euclidean graphs
euclidean_graph,

#minimum_spanning_trees
kruskal_mst,

#matching
MatchingResult, maximum_weight_maximal_matching, minimum_weight_perfect_matching,

#interdiction
# more imports/export in interdiction.jl

# matrixdepot
MDGraph, MDDiGraph

"""An optimized graphs package.

Simple graphs (not multi- or hypergraphs) are represented in a memory- and
time-efficient manner with adjacency lists and edge sets. Both directed and
undirected graphs are supported via separate types, and conversion is available
from directed to undirected.

The project goal is to mirror the functionality of robust network and graph
analysis libraries such as NetworkX while being simpler to use and more
efficient than existing Julian graph libraries such as Graphs.jl. It is an
explicit design decision that any data not required for graph manipulation
(attributes and other information, for example) is expected to be stored
outside of the graph structure itself. Such data lends itself to storage in
more traditional and better-optimized mechanisms.
"""
FatGraphs

include("core/edge.jl")
    include("core/abstract.jl")
    include("core/core.jl")
    include("core/graphdigraph.jl")
    include("core/edgeiter.jl")
    include("core/operators.jl")
include("traversals/graphvisit.jl")
    include("traversals/bfs.jl")
    include("traversals/dfs.jl")
    include("traversals/maxadjvisit.jl")
    include("traversals/randomwalks.jl")
    include("core/connectivity.jl")
include("distances/distance.jl")
    include("distances/edit_distance.jl")
include("shortestpaths/shortestpaths.jl")
include("linalg/nonbacktracking.jl")
    include("linalg/spectral.jl")
include("persistence/common.jl")
    include("persistence/dot.jl")
    include("persistence/gexf.jl")
    include("persistence/gml.jl")
    include("persistence/graphml.jl")
    include("persistence/net.jl")
    include("persistence/jld.jl")
include("generators/staticgraphs.jl")
    include("generators/randgraphs.jl")
    include("generators/euclideangraphs.jl")
    include("generators/smallgraphs.jl")
    include("generators/matrixdepot.jl")
include("centrality/betweenness.jl")
    include("centrality/closeness.jl")
    include("centrality/degree.jl")
    include("centrality/katz.jl")
    include("centrality/pagerank.jl")
include("community/modularity.jl")
    include("community/core-periphery.jl")
    include("community/clustering.jl")
    include("community/cliques.jl")
    include("community/detection.jl")
include("flow/maximum_flow.jl")
    include("flow/edmonds_karp.jl")
    include("flow/dinic.jl")
    include("flow/boykov_kolmogorov.jl")
    include("flow/push_relabel.jl")
    include("flow/multiroute_flow.jl")
    include("flow/kishimoto.jl")
    include("flow/ext_multiroute_flow.jl")
include("interdiction/interdiction.jl")
include("matching/matching.jl")
include("spanningtrees/kruskal.jl")
include("utils.jl")
include("deprecate.jl")

end # module
