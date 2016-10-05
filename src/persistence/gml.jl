function readgml(io::IO)
    gs = first(GML.parse_dict(readall(io))[:graph])
    dir = Bool(get(gs, :directed, 0))
    nodes = [x[:id] for x in gs[:node]]
    if dir
        g = DiGraph(length(nodes))
    else
        g = Graph(length(nodes))
    end
    mapping = Dict{Int,Int}()
    for (i,n) in enumerate(nodes)
        mapping[n] = i
    end
    sds = [(Int(x[:source]), Int(x[:target])) for x in gs[:edge]]
    for (s,d) in (sds)
        add_edge!(g, mapping[s], mapping[d])
    end
    return g
end

"""
    writegml(f, g)

Writes a graph `g` to a file `f` in the
[GML](https://en.wikipedia.org/wiki/Graph_Modelling_Language) format.
"""
function writegml(io::IO, g::ASimpleGraph)
    println(io, "graph")
    println(io, "[")
    # length(gname) > 0 && println(io, "label \"$gname\"")
    is_directed(g) && println(io, "directed 1")
    for i=1:nv(g)
        println(io,"\tnode")
        println(io,"\t[")
        println(io,"\t\tid $i")
        println(io,"\t]")
    end
    for (s,t) in edges(g)
        println(io,"\tedge")
        println(io,"\t[")
        println(io,"\t\tsource $s")
        println(io,"\t\ttarget $t")
        println(io,"\t]")
    end
    println(io, "]")
    return 1
end

filemap[:gml] = (readgml, writegml)
