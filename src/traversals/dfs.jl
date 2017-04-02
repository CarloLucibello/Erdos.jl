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

type DepthFirst <: SimpleGraphVisitAlgorithm
end

function depth_first_visit_impl!(
    g::AGraphOrDiGraph,      # the graph
    stack,                          # an (initialized) stack of vertex
    vcolormap::AVertexMap,    # an (initialized) color-map to indicate status of vertices
    ecolormap::AEdgeMap,      # an (initialized) color-map to indicate status of edges
    visitor::SimpleGraphVisitor)  # the visitor


    while !isempty(stack)
        u, udsts, tstate = pop!(stack)
        found_new_vertex = false

        while !done(udsts, tstate) && !found_new_vertex
            v, tstate = next(udsts, tstate)
            ucolor = get(vcolormap, u, 0)
            vcolor = get(vcolormap, v, 0)
            v_edge = Edge(u,v)
            ecolor = get(ecolormap, v_edge, 0)
            examine_neighbor!(visitor, u, v, ucolor, vcolor, ecolor) #no return here

            ecolormap[v_edge] = 1

            if vcolor == 0
                found_new_vertex = true
                vcolormap[v] = vcolormap[u] - 1 #negative numbers
                discover_vertex!(visitor, v) || return
                push!(stack, (u, udsts, tstate))

                open_vertex!(visitor, v)
                vdsts = out_neighbors(g, v)
                push!(stack, (v, vdsts, start(vdsts)))
            end
        end

        if !found_new_vertex
            close_vertex!(visitor, u)
            vcolormap[u] *= -1
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
    sstate = start(sdsts)
    stack = [(s, sdsts, sstate)]

    depth_first_visit_impl!(g, stack, vcolormap, ecolormap, visitor)
end

#################################################
#
#  Useful applications
#
#################################################

# Test whether a graph is cyclic

type DFSCyclicTestVisitor <: SimpleGraphVisitor
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

    if vcolor < 0 && ecolor == 0
        vis.found_cycle = true
    end
end

discover_vertex!(vis::DFSCyclicTestVisitor, v) = !vis.found_cycle

"""
    is_cyclic(g)

Tests whether a graph contains a cycle through depth-first search. It
returns `true` when it finds a cycle, otherwise `false`.
"""
function is_cyclic(g::AGraphOrDiGraph)
    cmap = VertexMap(g, zeros(Int, nv(g)))
    visitor = DFSCyclicTestVisitor()

    for s in vertices(g)
        if cmap[s] == 0
            traverse_graph!(g, DepthFirst(), s, visitor, vcolormap=cmap)
        end
        visitor.found_cycle && return true
    end
    return false
end

# Topological sort using DFS

type TopologicalSortVisitor <: SimpleGraphVisitor
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


type TreeDFSVisitor{G <:ADiGraph} <:SimpleGraphVisitor
    tree::G
    predecessor::Vector{Int}
end

TreeDFSVisitor{G}(n, ::Type{G}) = TreeDFSVisitor(digraph(G(n)), zeros(Int,n))

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
function dfs_tree{G}(g::G, s)
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
