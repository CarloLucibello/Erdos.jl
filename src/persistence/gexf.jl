function writegexf(f::IO, g::ASimpleGraph)
    xdoc = XMLDocument()
    xroot = setroot!(xdoc, ElementNode("gexf"))
    xroot["xmlns"] = "http://www.gexf.net/1.2draft"
    xroot["version"] = "1.2"
    xroot["xmlns:xsi"] = "http://www.w3.org/2001/XMLSchema-instance"
    xroot["xsi:schemaLocation"] = "http://www.gexf.net/1.2draft/gexf.xsd"

    xmeta = addelement!(xroot, "meta")
    xg = addelement!(xroot, "graph")
    xg["defaultedgetype"] = is_directed(g) ? "directed" : "undirected"
    xnodes = addelement!(xg, "nodes")
    for i in 1:nv(g)
        xv = addelement!(xnodes, "node")
        xv["id"] = "$(i-1)"
    end

    xedges = addelement!(xg, "edges")
    m = 0
    for e in edges(g)
        xe = addelement!(xedges, "edge")
        xe["id"] = "$m"
        xe["source"] = "$(src(e)-1)"
        xe["target"] = "$(dst(e)-1)"
        m += 1
    end

    prettyprint(f, xdoc)
    return 1
end

function gexf_read_one_graph!{G}(el::EzXML.Node, ::Type{G})
    elnodes = getchild(el, "nodes")
    nodes = Dict{String,Int}()
    for (i,f) in enumerate(eachelement(elnodes))
        nodes[f["id"]] = i
    end

    g = G(length(nodes))

    eledges = getchild(el, "edges")
    for f in eachelement(eledges)
        n1 = f["source"]
        n2 = f["target"]
        add_edge!(g, nodes[n1], nodes[n2])
    end

    return g
end

function readgexf{G<:ASimpleGraph}(io::IO, ::Type{G})
    xdoc = parsexml(readstring(io))
    xroot = root(xdoc)  # an instance of XMLElement
    name(xroot) == "gexf" || error("Not a Gexf file")
    el = getchild(xroot, "graph")
    isdir = false
    if haskey(el, "defaultedgetype")
        isdir = el["defaultedgetype"] == "directed"  ? true  : false
    end
    H = isdir ? digraphtype(G) : graphtype(G)
    return gexf_read_one_graph!(el, H)
end

filemap[:gexf] = (readgexf, writegexf, NI, NI)
