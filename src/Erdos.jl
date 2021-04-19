"""
A graph library for julia.
"""
module Erdos

using Random
using SparseArrays
using LinearAlgebra
using Arpack
import GZip # I/O
using Distributions: Binomial # randgraphs
import Printf
using EzXML # I/O  graphml, gexf  #TODO import instead of using
import Clustering: kmeans # community detection
using IterTools: distinct # all_neighbors
using IterTools: nth # EdgeIter
using Base.Iterators: flatten 
import Dates

import DataStructures: MutableBinaryHeap, update!, compare,  # push_relabel
                        PriorityQueue, dequeue!, peek, heappush!, heappop!,
                        enqueue!, compare, top

import SparseArrays: sparse, blockdiag
import LinearAlgebra: issymmetric


import Base: write, ==, <, *, ≈, isless, union, intersect,
            reverse, reverse!, getindex, setindex!, show, print, copy, in,
            sum, size, eltype, length, ndims,
            join, iterate, eltype, get,
            sort, push!, pop!, IteratorSize, values, valtype,
            SizeUnknown, IsInfinite, #iterators
            HasLength, HasShape,     #iterators
            haskey, Matrix #edgemap

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

# drawing
spring_layout, circular_layout, shell_layout,

# distance between graphs
spectral_distance, edit_distance,

# edit path cost functions
MinkowskiCost, BoundedMinkowskiCost,

# operators
complement, union, intersect,
difference, symmetric_difference,
join, tensor_product, cartesian_product, crosspath,
subgraph, egonet, complete, complete!,
subnetwork, contract!,

# bfs
gdistances, gdistances!, bfs_tree, is_bipartite, bipartite_map,
has_path,

# dfs
has_cycles, topological_sort_by_dfs, dfs_tree, 
#is_tree, #TODO add back

# random
randomwalk, self_avoiding_randomwalk, nonbacktracking_randomwalk,

# connectivity
connected_components, strongly_connected_components, weakly_connected_components,
is_connected, is_strongly_connected, is_weakly_connected, period,
condensation, attracting_components, neighborhood, is_graphical, density,

# maximum_adjacency_visit
maximum_adjacency_visit,

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
nonbacktracking_matrix, incidence_matrix, 
nonbacktrack_embedding,

# astar
a_star,

# persistence
readgraph, writegraph, readnetwork, writenetwork,

# flow
maximum_flow, EdmondsKarpAlgorithm, DinicAlgorithm, BoykovKolmogorovAlgorithm, PushRelabelAlgorithm,
multiroute_flow, KishimotoAlgorithm, ExtendedMultirouteFlowAlgorithm,
minimum_cut,

# randgraphs
erdos_renyi, watts_strogatz, 
random_regular_graph, random_regular_digraph, random_bipartite_regular_graph,
random_configuration_model, random_bipartite_configuration_model,
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

# dismantling
dismantle_ci, dismantle_ci_init, dismantle_ci_oneiter!,

# maps
AVertexMap, ConstVertexMap, VertexMap,
AEdgeMap, ConstEdgeMap, EdgeMap,
edgemap2adjlist, weights, 

# properties
PropertyStore,

graph_property, set_graph_property!, rem_graph_property!, has_graph_property,
vertex_property, add_vertex_property!, rem_vertex_property!, has_vertex_property,
edge_property, add_edge_property!, rem_edge_property!, has_edge_property,

#short forms
gprop, gprop!, rem_gprop!, has_gprop, gprop_names,
vprop, vprop!, rem_vprop!, has_vprop, vprop_names,
eprop, eprop!, rem_eprop!, has_eprop, eprop_names

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
include("traversals/bipartition.jl")
    include("traversals/bfs.jl")
    include("traversals/dfs.jl")
    include("traversals/maxadjvisit.jl")
    include("traversals/randomwalks.jl")
    include("traversals/connectivity.jl")
include("distances/distance.jl")
    include("distances/edit_distance.jl")
include("drawing/layout.jl")
    include("drawing/Graphviz.jl")
    include("drawing/draw.jl")
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
include("spanningtrees/spanningtrees.jl")
include("dismantling/ci.jl")
include("factory/graph.jl")
    include("factory/network.jl")
include("persistence/common.jl")
    include("persistence/dot.jl")
    include("persistence/gexf.jl")
    include("persistence/gml.jl")
    include("persistence/graphml.jl")
    include("persistence/net.jl")
    include("persistence/gt.jl")
include("deprecate.jl")

end # module
