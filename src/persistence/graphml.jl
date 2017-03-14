function graphml_read_one_graph!{G}(el::EzXML.Node, ::Type{G})
    nodes = Dict{String,Int}()
    E = Edge{Int}
    edges = Vector{E}()

    nodeid = 1
    for f in eachelement(el)
        if name(f) == "node"
            nodes[f["id"]] = nodeid
            nodeid += 1
        elseif name(f) == "edge"
            n1 = f["source"]
            n2 = f["target"]
            push!(edges, E(nodes[n1], nodes[n2]))
        else
            warn("Skipping unknown node '$(name(f))'")
        end
    end
    g = G(length(nodes))
    for edge in edges
        add_edge!(g, edge)
    end
    return g
end

function readgraphml{G<:ASimpleGraph}(io::IO, ::Type{G})
    xdoc = parsexml(readstring(io))
    xroot = root(xdoc)  # an instance of XMLElement
    name(xroot) == "graphml" || error("Not a GraphML file")
    el = getchild(xroot, "graph")
    isdir = false
    if haskey(el, "edgedefault")
        isdir = el["edgedefault"] == "directed"  ? true  : false
    end
    H = isdir ? digraphtype(G) : graphtype(G)
    return graphml_read_one_graph!(el, H)
end


function writegraphml(io::IO, g::ASimpleGraph)
    xdoc = XMLDocument()
    xroot = setroot!(xdoc, ElementNode("graphml"))
    xroot["xmlns"] = "http://graphml.graphdrawing.org/xmlns"
    xroot["xmlns:xsi"] = "http://www.w3.org/2001/XMLSchema-instance"
    xroot["xsi:schemaLocation"] = "http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd"

    xg = addelement!(xroot, "graph")
    xg["edgedefault"] = is_directed(g) ? "directed" : "undirected"
    for i in 1:nv(g)
        xv = addelement!(xg, "node")
        xv["id"] = "n$(i-1)"
    end
    for e in edges(g)
        xe = addelement!(xg, "edge")
        xe["source"] = "n$(src(e)-1)"
        xe["target"] = "n$(dst(e)-1)"
    end
    prettyprint(io, xdoc)
    return 1
end

filemap[:graphml] = (readgraphml, writegraphml, NI, NI)
