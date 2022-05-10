# Adapted from https://github.com/AlgebraicJulia/Catlab.jl/blob/master/src/graphics/GraphvizGraphs.jl

# export parse_graphviz, to_graphviz

import .Graphviz

function _to_graphviz(g::ANetOrDiNet)
    gv_name(v) = "n$v"
    gv_path(e) = [gv_name(src(e)), gv_name(dst(e))]

    # Add Graphviz node for each vertex in property graph.
    stmts = Graphviz.Statement[]
    for v in vertices(g)
        push!(stmts, Graphviz.Node(gv_name(v), vprop(g, v)))
    end

    # Add Graphviz edge for each edge in property graph.
    isdir = is_directed(g)
    for e in edges(g)
        # In undirected case, only include one edge from each pair.
        # if isdir || (e <= inv(g,e))
        push!(stmts, Graphviz.Edge(gv_path(e), eprop(g, e)))
        # end
    end

    attrs = gprop(g)
    gv = Graphviz.Graph(
            name = get(attrs, "name", "G"),
            directed = isdir,
            prog = get(attrs, "prog", isdir ? "dot" : "neato"),
            stmts = stmts,
            graph_attrs = Graphviz.as_attributes(get(attrs, "graph", Dict())),
            node_attrs = Graphviz.as_attributes(get(attrs, "node", Dict())),
            edge_attrs = Graphviz.as_attributes(get(attrs, "edge", Dict())),
        )
    return gv
end


""" 
Convert a graph to a Graphviz graph.
This method is usually more convenient than direct AST manipulation for creating
Graphviz graphs. For more advanced features, like nested subgraphs, you must use
the Graphviz AST directly.

A simple default style is applied. For more control over the visual appearance,
first convert the graph to a network type, define the Graphviz attributes as
needed, and then convert to a Graphviz graph.
"""
function to_graphviz(g::AGraphOrDiGraph;
                prog::AbstractString = is_directed(g) ? "dot" : "neato", 
                graph_attrs::AbstractDict = Dict(),
                node_attrs::AbstractDict = Dict(), 
                edge_attrs::AbstractDict = Dict(),
                node_labels::Bool=false, 
                edge_labels::Bool = false)
  
    net = is_directed(g) ? DiNetwork(g) : Network(g)
    node_labels && !has_vprop(net, "label") && vprop!(net, "label", v -> string(v))
    edge_labels && !has_eprop(net, "label") && eprop!(net, "label", e -> "($(src(e)), $(dst(e)))")
  
    # x, y = spring_layout(g)
    # vprop!(net, "pos", v -> "$(x[v]),$(y[v])!")
  
    gprop!(net, "prog", prog)
    gprop!(net, "graph", merge!(default_graph_attrs(g), graph_attrs))
    gprop!(net, "node", merge!(default_node_attrs(g, node_labels), node_attrs))
    gprop!(net, "edge", merge!(default_edge_attrs(g, edge_labels), edge_attrs))
    return _to_graphviz(net)
end

# default_node_attrs(g, show_labels::Bool) = Dict(
#   :shape => show_labels ? "circle" : "point",
#   :width => "0.05",
#   :height => "0.05",
#   :margin => "0",
# )
# default_edge_attrs(g, show_labels::Bool) = Dict("len" => "0.5")#, Dict(:arrowsize => "0.5")

default_graph_attrs(g) = Dict(:dpi=>"300") # Dict(:rankdir => "LR")
default_node_attrs(g, show_labels::Bool) = Dict(:shape => show_labels ? "circle" : "point",
                                                :fixedsize => "true")

default_edge_attrs(g, show_labels::Bool) = Dict()




"""
    draw(fname, g; fmt="png"; kws...)

Save the graph `g` to the file with name `fname` and extension `fmt`.

Notes:
- `fmt="png"` is the default output format.
- Requires Graphviz to be installed and commandline accessible.
"""
function draw(fname, g; fmt="png", kws...)
    gv = to_graphviz(g; kws...)
    open(fname, "w") do io
        Graphviz.run_graphviz(io, gv; format=fmt)
    end
    nothing
end

"""
    draw(g; kws...)

Plot the graph `g`.
"""
function draw(g; kws...)
    gv = to_graphviz(g; kws...)
    Graphviz.run_graphviz(gv; format="x11")
    nothing
end
