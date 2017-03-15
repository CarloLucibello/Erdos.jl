# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# Breadth-first search / traversal

#################################################
#
#  Breadth-first visit
#
#################################################
"""
**Conventions in Breadth First Search and Depth First Search**
VertexColorMap :
- color == 0    => unseen
- color < 0     => examined but not closed
- color > 0     => examined and closed

EdgeColorMap :
- color == 0    => unseen
- color == 1     => examined
"""

immutable BreadthFirst <: SimpleGraphVisitAlgorithm end

function breadth_first_visit_impl!(
    g::AGraphOrDiGraph,                 # the graph
    queue::Vector{Int},                 # an (initialized) queue that stores the active vertices
    vcolormap::AVertexMap,   # an (initialized) color-map to indicate status of vertices (-1=unseen, otherwise distance from root)
    ecolormap::AEdgeMap,        # an (initialized) color-map to indicate status of edges
    visitor::SimpleGraphVisitor,            # the visitor
    fneig)                        # direction [:in,:out]

    while !isempty(queue)
        u = shift!(queue)
        open_vertex!(visitor, u)
        ucolor = vcolormap[u]

        for v in fneig(g, u)
            vcolor = get(vcolormap, v, 0)
            e = edge(g, u, v)
            ecolor = get(ecolormap, e, 0)
            examine_neighbor!(visitor, u, v, ucolor, vcolor, ecolor) || return
            ecolormap[e] = 1
            if vcolor == 0
                vcolormap[v] = ucolor - 1
                discover_vertex!(visitor, v) || return
                push!(queue, v)
            end
        end
        close_vertex!(visitor, u)
        vcolormap[u] *= -1
    end
end

function traverse_graph!(
    g::AGraphOrDiGraph,
    alg::BreadthFirst,
    source,
    visitor::SimpleGraphVisitor;
    vcolormap::AVertexMap = VertexMap(g, Int),
    ecolormap::AEdgeMap = ConstEdgeMap(g, 0),
    queue = Vector{Int}(),
    dir = :out)

    for s in source
        vcolormap[s] = -1
        discover_vertex!(visitor, s) || return
        push!(queue, s)
    end
    fneig = dir == :out ? out_neighbors : in_neighbors

    breadth_first_visit_impl!(g, queue, vcolormap, ecolormap
            , visitor, fneig)
end


#################################################
#
#  Useful applications
#
#################################################

###########################################
# Get the map of the (geodesic) distances from vertices to source by BFS                  #
###########################################

immutable GDistanceVisitor <: SimpleGraphVisitor end

"""
    gdistances!(g, source, dists) -> dists

Fills `dists` with the geodesic distances of vertices in  `g` from vertex/vertices `source`.
`dists` can be either a vector or a dictionary.
"""
function gdistances!(g::AGraphOrDiGraph, source, dists)
    visitor = GDistanceVisitor()
    traverse_graph!(g, BreadthFirst(), source, visitor, vcolormap=dists)
    for i in eachindex(dists)
        dists[i] -= 1
    end
    return dists
end


"""
    gdistances(g, source) -> dists

Returns a vector filled with the geodesic distances of vertices in  `g` from vertex/vertices `source`.
For vertices in disconnected components the default distance is -1.
"""
gdistances(g::AGraphOrDiGraph, source) = gdistances!(g, source, fill(0,nv(g)))


###########################################
# Constructing BFS trees                  #
###########################################

"""TreeBFSVisitorVector is a type for representing a BFS traversal
of the graph as a parents array. This type allows for a more performant implementation.
"""
type TreeBFSVisitorVector <: SimpleGraphVisitor
    tree::Vector{Int}
end

function TreeBFSVisitorVector(n::Integer)
    return TreeBFSVisitorVector(fill(0, n))
end

"""tree converts a parents array into a digraph"""
function tree{G}(parents::AbstractVector, ::Type{G})
    n = length(parents)
    t = digraph(G(n))
    for i in 1:n
        parent = parents[i]
        if parent > 0  && parent != i
            add_edge!(t, parent, i)
        end
    end
    return t
end

function examine_neighbor!(visitor::TreeBFSVisitorVector, u, v,
                            ucolor, vcolor, ecolor)
    if u != v && vcolor == 0
        visitor.tree[v] = u
    end
    return true
end


# this version of bfs_tree! allows one to reuse the memory necessary to compute the tree
# the output is stored in the visitor.tree array whose entries are the vertex id of the
# parent of the index. This function checks if the scratch space is too small for the graph.
# and throws an error if it is too small.
# the source is represented in the output by a fixed point v[root] == root.
# this function is considered a performant version of bfs_tree for useful when the parent
# array is more helpful than a DiGraph type, or when performance is critical.
function bfs_tree!(visitor::TreeBFSVisitorVector,
        g::AGraphOrDiGraph,
        s::Int;
        vcolormap = Dict{Int,Int}(),
        queue = Vector{Int}())

    length(visitor.tree) >= nv(g) || error("visitor.tree too small for graph")
    visitor.tree[s] = s
    traverse_graph!(g, BreadthFirst(), s, visitor; vcolormap=vcolormap, queue=queue)
end

"""
    bfs_tree(g, s)

Provides a breadth-first traversal of the graph `g` starting with source vertex `s`,
and returns a directed acyclic graph of vertices in the order they were discovered.
"""
function bfs_tree{G<:AGraphOrDiGraph}(g::G, s)
    visitor = TreeBFSVisitorVector(nv(g))
    bfs_tree!(visitor, g, s)
    return tree(visitor.tree, G)
end

############################################
# Connected Components with BFS            #
############################################
"""Performing connected components with BFS starting from seed"""
type ComponentVisitorVector <: SimpleGraphVisitor
    labels::Vector{Int}
    seed::Int
end

function examine_neighbor!(visitor::ComponentVisitorVector, u, v,
                            ucolor, vcolor, ecolor)
    if u != v && vcolor == 0
        visitor.labels[v] = visitor.seed
    end
    return true
end

############################################
# Test graph for bipartiteness             #
############################################
type BipartiteVisitor <: SimpleGraphVisitor
    bipartitemap::Vector{UInt8}
    is_bipartite::Bool
end

BipartiteVisitor(n) = BipartiteVisitor(zeros(UInt8,n), true)

function examine_neighbor!(visitor::BipartiteVisitor, u, v,
        ucolor, vcolor, ecolor)
    if vcolor == 0
        visitor.bipartitemap[v] = (visitor.bipartitemap[u] == 1) ? 2 : 1
    else
        if visitor.bipartitemap[v] == visitor.bipartitemap[u]
            visitor.is_bipartite = false
        end
    end
    return visitor.is_bipartite
end

"""
    is_bipartite(g)
    is_bipartite(g, v)

Will return `true` if graph `g` is [bipartite](https://en.wikipedia.org/wiki/Bipartite_graph).
If a node `v` is specified, only the connected component to which it belongs is considered.
"""
function is_bipartite(g::AGraph)
    cc = filter(x->length(x)>2, connected_components(g))
    vmap = Dict{Int,Int}()
    for c in cc
        _is_bipartite(g,c[1], vmap=vmap) || return false
    end
    return true
end

is_bipartite(g::AGraph, v) = _is_bipartite(g, v)

_is_bipartite(g::AGraph, v; vmap = Dict{Int,Int}()) = _bipartite_visitor(g, v, vmap=vmap).is_bipartite

function _bipartite_visitor(g::AGraph, s; vmap=Dict{Int,Int}())
    nvg = nv(g)
    visitor = BipartiteVisitor(nvg)
    for v in keys(vmap) #have to reset vmap, otherway problems with digraphs
        vmap[v] = 0
    end
    traverse_graph!(g, BreadthFirst(), s, visitor, vcolormap=vmap)
    return visitor
end

"""
    bipartite_map(g)

If the graph is bipartite returns a vector `c`  of size `nv(g)` containing
the assignment of each vertex to one of the two sets (`c[i] == 1` or `c[i]==2`).
If `g` is not bipartite returns an empty vector.
"""
function bipartite_map(g::AGraph)
    cc = connected_components(g)
    visitors = [_bipartite_visitor(g, x[1]) for x in cc]
    !all([v.is_bipartite for v in visitors]) && return zeros(Int, 0)
    m = zeros(Int, nv(g))
    for i=1:nv(g)
        m[i] = any(v->v.bipartitemap[i] == 1, visitors) ? 2 : 1
    end
    m
end

is_bipartite(g::ADiGraph) = is_bipartite(graph(g))
is_bipartite(g::ADiGraph, v) = is_bipartite(graph(g), v)
bipartite_map(g::ADiGraph) = bipartite_map(graph(g), v)
