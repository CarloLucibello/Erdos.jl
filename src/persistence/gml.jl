function _readgml{G}(gs, ::Type{G})
    mapping = Dict{Int,Int}()
    if haskey(gs,:node)
        for (i, x) in enumerate(gs[:node])
            mapping[x[:id]] = i
        end
    end
    g = G(length(mapping))
    if haskey(gs, :edge)
        for e in gs[:edge]
            add_edge!(g, mapping[e[:source]], mapping[e[:target]])
        end
    end
    return g
end

function readgml{G}(io::IO, ::Type{G})
    gs = first(GML.parse_dict(readstring(io))[:graph])
    dir = Bool(get(gs, :directed, 0))
    H = dir ? digraphtype(G) : graphtype(G)
    return _readgml(gs, H)
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
