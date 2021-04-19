# Adapted from https://github.com/AlgebraicJulia/Catlab.jl/blob/5cd9a5610a45bd878eb28567fe6678ac6ed15c59/src/graphics/GraphvizGraphs.jl

export parse_graphviz, to_graphviz

import .Graphviz


# DiGraphs
########

""" Convert a graph to a Graphviz graph.
A simple default style is applied. For more control over the visual appearance,
first convert the graph to a property graph, define the Graphviz attributes as
needed, and then convert to a Graphviz graph.
"""
function to_graphviz(g::ADiGraph;
                prog::AbstractString = "dot", 
                graph_attrs::AbstractDict = Dict(),
                node_attrs::AbstractDict = Dict(), 
                edge_attrs::AbstractDict = Dict(),
                node_labels::Bool=false, 
                edge_labels::Bool = false)
  
    node_labeler(v) = Dict(:label => node_labels ? string(v) : "")
    edge_labeler(e) = edge_labels ? Dict(:label => string(e)) : Dict{Symbol,String}()
    
    net = DiNetwork(g, node_labeler, edge_labeler;
                    prog = prog,
                    graph = merge!(Dict(:rankdir => "LR"), graph_attrs),
                    node = merge!(default_node_attrs(node_labels), node_attrs),
                    edge = merge!(Dict(:arrowsize => "0.5"), edge_attrs),
                    )
    return to_graphviz(net)
end

default_node_attrs(show_labels::Bool) = Dict(
  :shape => show_labels ? "circle" : "point",
  :width => "0.05",
  :height => "0.05",
  :margin => "0",
)

# Symmetric graphs
##################

function to_graphviz(g::AGraph;
                    prog::AbstractString = "neato", 
                    graph_attrs::AbstractDict = Dict(),
                    node_attrs::AbstractDict = Dict(), 
                    edge_attrs::AbstractDict = Dict(),
                    node_labels::Bool=false, 
                    edge_labels::Bool=false)
    node_labeler(v) = Dict(:label => node_labels ? string(v) : "")
    edge_labeler(e) =   if edge_labels
                            e′ = inv(g, e)
                            Dict(:label => "($(min(e,e′)),$(max(e,e′)))")
                        else
                            Dict{Symbol,String}()
                        end
    net = Network(g, node_labeler, edge_labeler;
                prog = prog,
                graph = graph_attrs,
                node = merge!(default_node_attrs(node_labels), node_attrs),
                edge = merge!(Dict(:len => "0.5"), edge_attrs),
                )
    return to_graphviz(net)
end
