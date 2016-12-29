

# TODO: implement save

function readdot{G<:ASimpleGraph}(io::IO, ::Type{G})
    pg = first(DOT.parse_dot(readall(io)))

    isdir = pg.directed
    nvg = length(DOT.nodes(pg))
    nodedict = Dict(zip(collect(DOT.nodes(pg)), 1:nvg))
    g = G(nvg)
    g = isdir ? digraph(g) : graph(g)
    for es in DOT.edges(pg)
        s = nodedict[es[1]]
        d = nodedict[es[2]]
        add_edge!(g, s, d)
    end
    return g
end

filemap[:dot] = (readdot, NI)
