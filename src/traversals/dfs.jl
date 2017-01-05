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
    graph::ASimpleGraph,      # the graph
    stack,                          # an (initialized) stack of vertex
    vertexcolormap::AbstractVertexMap,    # an (initialized) color-map to indicate status of vertices
    edgecolormap::AbstractEdgeMap,      # an (initialized) color-map to indicate status of edges
    visitor::SimpleGraphVisitor)  # the visitor


    while !isempty(stack)
        u, udsts, tstate = pop!(stack)
        found_new_vertex = false

        while !done(udsts, tstate) && !found_new_vertex
            v, tstate = next(udsts, tstate)
            u_color = get(vertexcolormap, u, 0)
            v_color = get(vertexcolormap, v, 0)
            v_edge = Edge(u,v)
            e_color = get(edgecolormap, v_edge, 0)
            examine_neighbor!(visitor, u, v, u_color, v_color, e_color) #no return here

            edgecolormap[v_edge] = 1

            if v_color == 0
                found_new_vertex = true
                vertexcolormap[v] = vertexcolormap[u] - 1 #negative numbers
                discover_vertex!(visitor, v) || return
                push!(stack, (u, udsts, tstate))

                open_vertex!(visitor, v)
                vdsts = out_neighbors(graph, v)
                push!(stack, (v, vdsts, start(vdsts)))
            end
        end

        if !found_new_vertex
            close_vertex!(visitor, u)
            vertexcolormap[u] *= -1
        end
    end
end

function traverse_graph!(
    graph::ASimpleGraph,
    alg::DepthFirst,
    s,
    visitor::SimpleGraphVisitor;
    vertexcolormap = Dict{Int, Int}(),
    edgecolormap = DummyEdgeMap())

    vertexcolormap[s] = -1
    discover_vertex!(visitor, s) || return

    sdsts = out_neighbors(graph, s)
    sstate = start(sdsts)
    stack = [(s, sdsts, sstate)]

    depth_first_visit_impl!(graph, stack, vertexcolormap, edgecolormap, visitor)
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
function is_cyclic(g::ASimpleGraph)
    cmap = zeros(Int, nv(g))
    visitor = DFSCyclicTestVisitor()

    for s in vertices(g)
        if cmap[s] == 0
            traverse_graph!(g, DepthFirst(), s, visitor, vertexcolormap=cmap)
        end
        visitor.found_cycle && return true
    end
    return false
end

# Topological sort using DFS

type TopologicalSortVisitor <: SimpleGraphVisitor
    vertices::Vector{Int}

    function TopologicalSortVisitor(n)
        vs = Array(Int, 0)
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

function topological_sort_by_dfs(graph::ASimpleGraph)
    nvg = nv(graph)
    cmap = zeros(Int, nvg)
    visitor = TopologicalSortVisitor(nvg)

    for s in vertices(graph)
        if cmap[s] == 0
            traverse_graph!(graph, DepthFirst(), s, visitor, vertexcolormap=cmap)
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
