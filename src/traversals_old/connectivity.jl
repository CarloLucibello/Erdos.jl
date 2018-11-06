# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.


"""
    connected_components!(label::Vector{Int}, g::AGraph)

Fills `label` with the `id` of the connected component to which it belongs.

Arguments:
    label: a place to store the output
    g: the graph
Output:
    c = labels[i] => vertex i belongs to component c.
    c is the smallest vertex id in the component.
"""
function connected_components!(label::Vector{Int}, g::AGraph)
    # this version of connected components uses Breadth First Traversal
    # with custom visitor type in order to improve performance.
    # one BFS is performed for each component.
    # This algorithm is linear in the number of edges of the graph
    # each edge is touched once. memory performance is a single allocation.
    # the return type is a vector of labels which can be used directly or
    # passed to components(a)
    nvg = nv(g)
    visitor = Erdos.ComponentVisitorVector(label, 0)
    colormap = VertexMap(g, fill(0, nvg))
    queue = Vector{Int}()
    sizehint!(queue, nvg)
    for v in 1:nvg
        if label[v] == 0
            visitor.labels[v] = v
            visitor.seed = v
            traverse_graph!(g, BreadthFirst(), v, visitor; vcolormap=colormap, queue=queue)
        end
    end
    return label
end

"""components_dict(labels) converts an array of labels to a Dict{Int,Vector{Int}} of components

Arguments:
    c = labels[i] => vertex i belongs to component c.
Output:
    vs = d[c] => vertices in vs belong to component c.
"""
function components_dict(labels::Vector{Int})
    d = Dict{Int,Vector{Int}}()
    for (v,l) in enumerate(labels)
        vec = get(d, l, Vector{Int}())
        push!(vec, v)
        d[l] = vec
    end
    return d
end

"""
    components(labels::Vector{Int})

Converts an array of labels to a Vector{Vector{Int}} of components

Arguments:
    c = labels[i] => vertex i belongs to component c.
Output:
    vs = c[i] => vertices in vs belong to component i.
    a = d[i] => if labels[v]==i then v in c[a] end
"""
function components(labels::Vector{Int})
    d = Dict{Int, Int}()
    c = Vector{Vector{Int}}()
    i = 1
    for (v,l) in enumerate(labels)
        index = get!(d, l, i)
        if length(c) >= index
            push!(c[index], v)
        else
            push!(c, [v])
            i += 1
        end
    end
    return c, d
end

"""
    connected_components(g::AGraph)

Returns the [connected components](https://en.wikipedia.org/wiki/Connectivity_(graph_theory))
of `g` as a vector of components, each represented by a
vector of vertices belonging to the component.

See also [`weakly_connected_components`](@ref) and [`strongly_connected_components`](@ref)
for directed graphs.
"""
function connected_components(g::AGraph)
    nv(g) == 0 && return Vector{Int}[Int[]]
    label = zeros(Int, nv(g))
    connected_components!(label, g)
    c, d = components(label)
    return c
end

"""
    is_connected(g)

Returns `true` if `g` is connected.
For DiGraphs, this is equivalent to a test of weak connectivity.
"""
is_connected(g::AGraph) = length(connected_components(g)) == 1

"""
    weakly_connected_components(g::ADiGraph)

Returns the weakly connected components of undirected graph `g`.
It is equivalent to the connected components of the corresponding
undirected graph, i.e. `connected_components(graph(g))`.
"""
weakly_connected_components(g::ADiGraph) = connected_components(graph(g))

"""
    is_weakly_connected(g::ADiGraph)

Returns `true` if the undirected graph `g` is weakly connected.

See also [`weakly_connected_components`](@ref).
"""
is_weakly_connected(g::ADiGraph) = length(weakly_connected_components(g)) == 1

# Adapated from Graphs.jl
mutable struct TarjanVisitor <: SimpleGraphVisitor
    stack::Vector{Int}
    onstack::BitVector
    lowlink::Vector{Int}
    index::Vector{Int}
    components::Vector{Vector{Int}}
end

TarjanVisitor(n) = TarjanVisitor(
    Vector{Int}(),
    falses(n),
    Vector{Int}(),
    zeros(Int, n),
    Vector{Vector{Int}}()
)

function discover_vertex!(vis::TarjanVisitor, v)
    vis.index[v] = length(vis.stack) + 1
    push!(vis.lowlink, length(vis.stack) + 1)
    push!(vis.stack, v)
    vis.onstack[v] = true
    return true
end

function examine_neighbor!(vis::TarjanVisitor, v, w, vcolor, w_color, ecolor)
    if w_color != 0 && vis.onstack[w] # != 0 means seen
        while vis.index[w] > 0 && vis.index[w] < vis.lowlink[end]
            pop!(vis.lowlink)
        end
    end
    return true
end

function close_vertex!(vis::TarjanVisitor, v)
    if vis.index[v] == vis.lowlink[end]
        component = splice!(vis.stack, vis.index[v]:length(vis.stack))
        vis.onstack[component] = false
        pop!(vis.lowlink)
        push!(vis.components, component)
    end
    return true
end

"""
    strongly_connected_components(g::ADiGraph)

Computes the strongly connected components of a directed graph.
"""
function strongly_connected_components(g::ADiGraph)
    nvg = nv(g)
    cmap = VertexMap(g, zeros(Int, nvg))
    nv(g) == 0 && return Vector{Int}[Int[]]
    components = Vector{Vector{Int}}()

    for v in vertices(g)
        if cmap[v] == 0 # 0 means not visited yet
            visitor = TarjanVisitor(nvg)
            traverse_graph!(g, DepthFirst(), v, visitor, vcolormap=cmap)
            for component in visitor.components
                push!(components, component)
            end
        end
    end
    return components
end

"""
    is_strongly_connected(g::ADiGraph)

Returns `true` if `g` is strongly connected.

See also [`strongly_connected_components`](@ref)
"""
is_strongly_connected(g::ADiGraph) = length(strongly_connected_components(g)) == 1

"""
    period(g::ADiGraph)

Computes the common period for all nodes in a strongly connected graph.
"""
function period(g::ADiGraph)
    !is_strongly_connected(g) && error("Graph must be strongly connected")

    # First check if there's a self loop
    has_self_loops(g) && return 1

    g_bfs_tree  = bfs_tree(g,1)
    levels      = gdistances(g_bfs_tree,1)
    tree_diff   = difference(g,g_bfs_tree)
    edge_values = Vector{Int}()

    divisor = 0
    for e in edges(tree_diff)
        @inbounds value = levels[src(e)] - levels[dst(e)] + 1
        divisor = gcd(divisor,value)
        isequal(divisor,1) && return 1
    end

    return divisor
end

"""Computes the condensation graph of the strongly connected components."""
function _condensation(g::T, scc::Vector{Vector{Int}}) where T<:ADiGraph
    h = T(length(scc))

    component = Vector{Int}(nv(g))

    for (i,s) in enumerate(scc)
        @inbounds component[s] = i
    end

    @inbounds for e in edges(g)
        s, d = component[src(e)], component[dst(e)]
        if (s != d)
            add_edge!(h,s,d)
        end
    end
    return h
end

"""
    condensation(g::ADiGraph)

Returns the condensation graph associated with `g`. The condensation `h` of
a graph `g` is the directed graph where every node in `h` represents a strongly
connected component in `g`, and the presence of an edge between between nodes
in `h` indicates that there is at least one edge between the associated
strongly connected components in `g`. The node numbering in `h` corresponds to
the ordering of the components output from [`strongly_connected_components`](@ref).
"""
condensation(g::ADiGraph) = _condensation(g, strongly_connected_components(g))

"""
    attracting_components(g::ADiGraph)

Returns a vector of vectors of integers representing lists of attracting
components in `g`. The attracting components are a subset of the strongly
connected components in which the components do not have any leaving edges.
"""
function attracting_components(g::ADiGraph)
    scc  = strongly_connected_components(g)
    cond = _condensation(g, scc)

    attracting = Vector{Int}()

    for v in vertices(cond)
        if out_degree(cond,v) == 0
            push!(attracting,v)
        end
    end
    return scc[attracting]
end

mutable struct NeighborhoodVisitor{V} <: SimpleGraphVisitor
    d::Int
    neigs::Vector{V}
end

NeighborhoodVisitor(g::AGraphOrDiGraph, d::Integer) =
    (V=vertextype(g); NeighborhoodVisitor{V}(d, Vector{V}()))

function examine_neighbor!(visitor::NeighborhoodVisitor, u, v, ucolor, vcolor, ecolor)
    -ucolor > visitor.d && return false # color is negative for non-closed vertices
    if vcolor == 0
        push!(visitor.neigs, v)
    end
    return true
end


"""
    neighborhood(g, v, d; dir=:out)

Returns a vector of the vertices in `g` at distance less or equal to `d`
from `v`. If `g` is a `DiGraph` the `dir` optional argument specifies the edge direction
the edge direction with respect to `v` (i.e. `:in` or `:out`) to be considered.
"""
function neighborhood(g::AGraphOrDiGraph, v::Integer, d::Integer; dir=:out)
    @assert d >= 0 "Distance has to be greater then zero."
    visitor = NeighborhoodVisitor(g, d)
    push!(visitor.neigs, v)
    traverse_graph!(g, BreadthFirst(), v, visitor,
        vcolormap=VertexMap(g, Int), dir=dir)
    return visitor.neigs
end
