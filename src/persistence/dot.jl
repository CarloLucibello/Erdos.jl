function _readdot{G<:ASimpleGraph}(pg, ::Type{G})
    nvg = length(DOT.nodes(pg))
    nodedict = Dict(zip(collect(DOT.nodes(pg)), 1:nvg))
    g = G(nvg)
    for es in DOT.edges(pg)
        s = nodedict[es[1]]
        d = nodedict[es[2]]
        add_edge!(g, s, d)
    end
    return g
end

function readdot{G<:ASimpleGraph}(io::IO, ::Type{G})
    pg = first(DOT.parse_dot(readstring(io)))
    H = pg.directed ? digraphtype(G) : graphtype(G)
    println("isdr $(pg.directed)")
    return _readdot(pg, H)
end

function writedot(io::IO, g::ASimpleGraph)
    if is_directed(g)
        println(io, "strict digraph {")
        eop = "->"
    else
        println(io, "strict graph {")
        eop = "--"
    end

    for (s,t) in edges(g)
        println(io,"\tn$s $eop n$t;")
    end

    println(io, "}")
    return 1
end

filemap[:dot] = (readdot, writedot)
