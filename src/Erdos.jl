__precompile__(true)
module Erdos

import GZip # I/O
import StatsFuns # randgraphs
using EzXML # I/O  graphml, gexf  #TODO import
import ParserCombinator: Parsers.DOT, Parsers.GML # persistence
import BlossomV # matching
import Clustering: kmeans # community detection
using Compat
# package Iterators.jl methods are now in utils.jl due to name
# conflict in julia 0.6 with Base.Iterators
# using Iterators: distinct, chain # all_neighbors
# using Iterators: nth # EdgeIter

import DataStructures: MutableBinaryHeap, update!, compare,  # push_relabel
                        PriorityQueue, dequeue!, peek, heappush!, heappop!,
                        enqueue!, compare, top

import Base: write, ==, <, *, ≈, isless, union, intersect,
            reverse, reverse!, blkdiag, getindex, setindex!, show, print, copy, in,
            sum, size, sparse, eltype, length, ndims,
            join, start, next, done, eltype, get, issymmetric, A_mul_B!,
            sort, push!, pop!, iteratorsize, values, valtype,
            SizeUnknown, IsInfinite, #iterators
            HasLength, HasShape,     #iterators
            haskey #edgemap

#interface
export AGraph, ADiGraph, AGraphOrDiGraph,
ANetwork, ADiNetwork, ANetOrDiNet,
graphtype, digraphtype, edgetype, vertextype,


# edge
AEdge, Edge, reverse,
AIndexedEdge, IndexedEdge, idx,

# core
vertices, edges, src, dst,
graph, digraph,
adjacency_list,
neighbors, in_neighbors, out_neighbors, all_neighbors,
in_edges, out_edges, all_edges,
has_vertex, has_edge, is_directed,
nv, ne, add_edge!, rem_edge!, add_vertex!, add_vertices!,
in_degree, out_degree, degree, has_self_loops, num_self_loops,
rem_vertex!, edge, clean_vertex!,
unsafe_add_edge!, rebuild!,
rem_vertices!, swap_vertices!, pop_vertex!,

# graph types (factory)
reverse!, Graph, DiGraph, DiNetwork, Network,

# distance
eccentricities, eccentricity, diameter, periphery, radius, center,

# distance between graphs
spectral_distance, edit_distance,

# edit path cost functions
MinkowskiCost, BoundedMinkowskiCost,

# operators
complement, blkdiag, union, intersect,
difference, symmetric_difference,
join, tensor_product, cartesian_product, crosspath,
subgraph, egonet, complete, complete!,

# graph visit
SimpleGraphVisitor, TrivialGraphVisitor, LogGraphVisitor,
discover_vertex!, open_vertex!, close_vertex!,
examine_neighbor!, visited_vertices, traverse_graph!, traverse_graph_withlog,

# bfs
BreadthFirst, gdistances, gdistances!, bfs_tree, is_bipartite, bipartite_map,

# dfs
DepthFirst, is_cyclic, topological_sort_by_dfs, dfs_tree,

# random
randomwalk, self_avoiding_randomwalk, nonbacktracking_randomwalk,

# connectivity
connected_components, strongly_connected_components, weakly_connected_components,
is_connected, is_strongly_connected, is_weakly_connected, period,
condensation, attracting_components, neighborhood, is_graphical, density,

# maximum_adjacency_visit
MaximumAdjacency, AbstractMASVisitor, mincut, maximum_adjacency_visit,

# a-star, dijkstra, bellman-ford, floyd-warshall
a_star, dijkstra_shortest_paths,
bellman_ford_shortest_paths, has_negative_edge_cycle, enumerate_paths,
floyd_warshall_shortest_paths,
shortest_paths,

# centrality
betweenness_centrality, closeness_centrality, degree_centrality,
in_degree_centrality, out_degree_centrality, katz_centrality, pagerank,
cores, kcore,

# spectral
adjacency_matrix,laplacian_matrix,
CombinatorialAdjacency, nonbacktracking_matrix, incidence_matrix,
nonbacktrack_embedding, Nonbacktracking,
contract,

# astar
a_star,

# persistence
readgraph, writegraph, readnetwork, writenetwork,

# flow
maximum_flow, EdmondsKarpAlgorithm, DinicAlgorithm, BoykovKolmogorovAlgorithm, PushRelabelAlgorithm,
multiroute_flow, KishimotoAlgorithm, ExtendedMultirouteFlowAlgorithm,
minimum_cut,

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
# graph, digraph

# Euclidean graphs
euclidean_graph,

# Spanning Trees
minimum_spanning_tree, count_spanning_trees,

# matching
MatchingResult, minimum_weight_perfect_matching,

# dismantling
dismantle_ci, dismantle_ci_init, dismantle_ci_oneiter!,

# maps
AVertexMap, ConstVertexMap, hasindex, VertexMap,
AEdgeMap, ConstEdgeMap, EdgeMap,

# properties
PropertyStore,
add_edge_property!, add_vertex_property!, set_graph_property!,
edge_property, vertex_property, graph_property,
rem_edge_property!, rem_vertex_property!,
vertex_properties, edge_properties, graph_properties,
#short forms
gprop, gprop!, rem_gprop!, gprops, gprop_names, has_gprop,
vprop, vprop!, rem_vprop!, vprops, vprop_names, has_vprop,
eprop, eprop!, rem_eprop!, eprops, eprop_names, has_eprop

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
Erdos

include("utils.jl")
include("core/interface_graph.jl")
    include("core/interface_network.jl")
    include("core/core.jl")
    include("core/edge.jl")
    include("core/edgeiter.jl")
    include("core/misc.jl")
include("maps/vertexmap.jl")
    include("maps/edgemap.jl")
    include("maps/property_store.jl")
include("operators/operators.jl")
include("traversals/graphvisit.jl")
    include("traversals/bfs.jl")
    include("traversals/dfs.jl")
    include("traversals/maxadjvisit.jl")
    include("traversals/randomwalks.jl")
    include("traversals/connectivity.jl")
include("distances/distance.jl")
    include("distances/edit_distance.jl")
include("shortestpaths/shortestpaths.jl")
include("linalg/nonbacktracking.jl")
    include("linalg/spectral.jl")
include("generators/staticgraphs.jl")
    include("generators/randgraphs.jl")
    include("generators/euclideangraphs.jl")
    include("generators/smallgraphs.jl")
include("centrality/betweenness.jl")
    include("centrality/closeness.jl")
    include("centrality/degree.jl")
    include("centrality/katz.jl")
    include("centrality/pagerank.jl")
    include("centrality/kcore.jl")
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
include("matching/matching.jl")
include("spanningtrees/spanningtrees.jl")
include("dismantling/ci.jl")
include("factory/graph.jl")
    include("factory/net.jl")
include("persistence/common.jl")
    include("persistence/dot.jl")
    include("persistence/gexf.jl")
    include("persistence/gml.jl")
    include("persistence/graphml.jl")
    include("persistence/net.jl")
    include("persistence/gt.jl")
include("deprecate.jl")
end # module
