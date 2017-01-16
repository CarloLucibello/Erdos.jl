# TODO: implement writing a dict of graphs

function _graphml_read_one_graph{G}(e::XMLElement, ::Type{G})
    nodes = Dict{String,Int}()
    edges = Vector{Edge{Int}}()

    nodeid = 1
    for f in child_elements(e)
        if name(f) == "node"
            nodes[attribute(f, "id")] = nodeid
            nodeid += 1
        elseif name(f) == "edge"
            n1 = attribute(f, "source")
            n2 = attribute(f, "target")
            push!(edges, Edge(nodes[n1], nodes[n2]))
        else
            warn("Skipping unknown node '$(name(f))'")
        end
    end
    #Put data in graph
    g = G(length(nodes))
    for edge in edges
        add_edge!(g, edge)
    end
    return g
end

function readgraphml{G<:ASimpleGraph}(io::IO, ::Type{G})
    xdoc = parse_string(readstring(io))
    xroot = root(xdoc)  # an instance of XMLElement
    name(xroot) == "graphml" || error("Not a GraphML file")

    # traverse all its child nodes and print element names
    for c in child_nodes(xroot)  # c is an instance of XMLNode
        if is_elementnode(c)
            e = XMLElement(c)  # this makes an XMLElement instance
            if name(e) == "graph"
                edgedefault = attribute(e, "edgedefault")
                isdir = edgedefault=="directed" ? true :
                             edgedefault=="undirected" ? false : error("Unknown value of edgedefault: $edgedefault")
                # if has_attribute(e, "id")
                #     graphname = attribute(e, "id")
                # else
                #     graphname =  isdir ? "digraph" : "graph"
                # end
                T = isdir ? digraphtype(G()) : graphtype(G())
                return _graphml_read_one_graph(e, T)
            else
                warn("Skipping unknown XML element '$(name(e))'")
            end
        end
    end
    error("Graph not found")
end


function writegraphml(io::IO, g::ASimpleGraph)
    xdoc = XMLDocument()
    xroot = create_root(xdoc, "graphml")
    set_attribute(xroot,"xmlns","http://graphml.graphdrawing.org/xmlns")
    set_attribute(xroot,"xmlns:xsi","http://www.w3.org/2001/XMLSchema-instance")
    set_attribute(xroot,"xsi:schemaLocation","http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd")

    xg = new_child(xroot, "graph")
    # set_attribute(xg,"id",gname)
    strdir = is_directed(g) ? "directed" : "undirected"
    set_attribute(xg,"edgedefault",strdir)

    for i=1:nv(g)
        xv = new_child(xg, "node")
        set_attribute(xv,"id","n$(i-1)")
    end

    m = 0
    for e in edges(g)
        xe = new_child(xg, "edge")
        set_attribute(xe,"id","e$m")
        set_attribute(xe,"source","n$(src(e)-1)")
        set_attribute(xe,"target","n$(dst(e)-1)")
        m += 1
    end
    show(io, xdoc)
    return 1
end

filemap[:graphml] = (readgraphml, writegraphml)
