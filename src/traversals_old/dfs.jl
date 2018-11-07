# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.

# Depth-first visit / traversal


#################################################
#
#  Depth-first visit
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
struct DepthFirst <: SimpleGraphVisitAlgorithm end

function depth_first_visit_impl!(
    g::G,      # the graph
    stack,                          # an (initialized) stack of vertex
    vcolormap::AVertexMap,    # an (initialized) color-map to indicate status of vertices
    ecolormap::AEdgeMap,      # an (initialized) color-map to indicate status of edges
    visitor::SimpleGraphVisitor) where G<:AGraphOrDiGraph  # the visitor


    while !isempty(stack)
        # u, udsts, tstate = pop!(stack)
        u, udsts, it = pop!(stack)
        found_new_vertex = false

        # while !Base.done(udsts, tstate) && !found_new_vertex
        while it !== nothing && !found_new_vertex
            # v, tstate = Base.next(udsts, tstate)
            v, tstate = it
            ucolor = get(vcolormap, u, 0)
            vcolor = get(vcolormap, v, 0)
            v_edge = Edge(G,u,v) # ordering u,v for undirected graphs
            ecolor = get(ecolormap, v_edge, 0)
            examine_neighbor!(visitor, u, v, ucolor, vcolor, ecolor) #no return here

            ecolormap[v_edge] = 1
            if vcolor == 0
                found_new_vertex = true
                vcolormap[v] = vcolormap[u] - 1 #negative numbers
                discover_vertex!(visitor, v) || return
                # push!(stack, (u, udsts, tstate))
                it = iterate(udsts, tstate)
                if it !== nothing
                    push!(stack, (u, udsts, it))
                end

                open_vertex!(visitor, v)
                vdsts = out_neighbors(g, v)
                if !isempty(vdsts)
                    push!(stack, (v, vdsts, iterate(vdsts)))
                end
            end
        end

        if !found_new_vertex
            close_vertex!(visitor, u)
            vcolormap[u] *= -1 #revert to positive
        end
    end
end

function traverse_graph!(
        g::AGraphOrDiGraph,
        alg::DepthFirst,
        s,
        visitor::SimpleGraphVisitor;
        vcolormap::AVertexMap = VertexMap(g, Int),
        ecolormap::AEdgeMap = ConstEdgeMap(g, 0)
    )

    vcolormap[s] = -1
    discover_vertex!(visitor, s) || return

    sdsts = out_neighbors(g, s)
    # sstate = Base.start(sdsts)
    it = iterate(sdsts)
    stack = [(s, sdsts, it)]

    depth_first_visit_impl!(g, stack, vcolormap, ecolormap, visitor)
end

#################################################
#
#  Useful applications
#
#################################################

# Test whether a graph is cyclic

mutable struct DFSCyclicTestVisitor <: SimpleGraphVisitor
    found_cycle::Bool

    DFSCyclicTestVisitor() = new(false)
end

function examine_neighbor!(
    vis::DFSCyclicTestVisitor,
    u,
    v,
    ucolor,
    vcolor,
    ecolor)

    if vcolor < 0 && vcolor != ucolor+1 # seen and not parent
        vis.found_cycle = true
    end
end

discover_vertex!(vis::DFSCyclicTestVisitor, v) = !vis.found_cycle

"""
    has_cycles(g)

Tests whether a graph contains a simple cycle through depth-first search.
See also [`is_tree`](@ref).
"""
function has_cycles(g::AGraphOrDiGraph)
    cmap = VertexMap(g, zeros(Int, nv(g)))
    visitor = DFSCyclicTestVisitor()
    # em = is_directed(g) ? ConstEdgeMap(g, 0) : EdgeMap(g, Dict{Edge,Int}())
    em = ConstEdgeMap(g, 0)
    for s in vertices(g)
        if cmap[s] == 0
            traverse_graph!(g, DepthFirst(), s, visitor, vcolormap=cmap,
                ecolormap=em)
        end
        visitor.found_cycle && return true
    end
    return false
end
# TODO
# now has_cycles for undir graphs 
# is true whenever ne(g) > 0, so this has to be changed
#
# """
#     is_tree(g)

# Check whether `g` is a tree.
# Return `false` whenever [`has_cycles`](@ref) returns `true` and viceversa.
# """
# is_tree(g::AGraphOrDiGraph) = !has_cycles(g)

## This is a faster implementation found on
## http://www.geeksforgeeks.org/detect-cycle-in-a-graph/
##  TODO benchmark carefully and eventually use this
# function _has_cycles(g, v, visited, parent)
#     visited[v] = 1
#     for i in neighbors(g, v)
#         if visited[i] == 0
#             _has_cycles(g, i, visited, v) && return true
#         elseif i != parent
#             return true
#         end
#     end
#     return false
# end
#
#
# function has_cycles(g::AGraph)
#     visited = zeros(Int, nv(g))
#     for i=1:nv(g)
#         if visited[i] == 0
#             _has_cycles(g, i, visited, -1) && return true
#         end
#     end
#
#     return false
# end
#

# Topological sort using DFS

mutable struct TopologicalSortVisitor <: SimpleGraphVisitor
    vertices::Vector{Int}

    function TopologicalSortVisitor(n)
        vs = Vector{Int}()
        sizehint!(vs, n)
        new(vs)
    end
end


function examine_neighbor!(visitor::TopologicalSortVisitor, u, v, ucolor, vcolor, ecolor)
    (vcolor < 0 && ecolor == 0) && error("The input graph contains at least one loop.")
end

function close_vertex!(visitor::TopologicalSortVisitor, v)
    push!(visitor.vertices, v)
end

function topological_sort_by_dfs(g::AGraphOrDiGraph)
    nvg = nv(g)
    cmap = VertexMap(g, zeros(Int, nvg))
    visitor = TopologicalSortVisitor(nvg)

    for s in vertices(g)
        if cmap[s] == 0
            traverse_graph!(g, DepthFirst(), s, visitor, vcolormap=cmap)
        end
    end

    reverse(visitor.vertices)
end


mutable struct TreeDFSVisitor{G <:ADiGraph} <:SimpleGraphVisitor
    tree::G
    predecessor::Vector{Int}
end

TreeDFSVisitor(n, ::Type{G}) where {G} = TreeDFSVisitor(digraph(G(n)), zeros(Int,n))

function examine_neighbor!(visitor::TreeDFSVisitor, u, v, ucolor, vcolor, ecolor)
    if (vcolor == 0)
        visitor.predecessor[v] = u
    end
    return true
end

"""
    dfs_tree(g, s)

Provides a depth-first traversal of the graph `g` starting with source vertex `s`,
and returns a directed acyclic graph of vertices in the order they were discovered.
"""
function dfs_tree(g::G, s) where G
    nvg = nv(g)
    visitor = TreeDFSVisitor(nvg, G)
    traverse_graph!(g, DepthFirst(), s, visitor)
    h = digraph(G(nvg))
    for (v, u) in enumerate(visitor.predecessor)
        if u != 0
            add_edge!(h, u, v)
        end
    end
    return h
end
