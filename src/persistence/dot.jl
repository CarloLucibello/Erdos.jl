function _dot_nodes_to_dict(pg)
    nodes = collect(DOT.nodes(pg))
    n = length(nodes)
    # try to convert label in index
    # so that  write("file",g) == read("file")
    try
        if all(v->isalpha(first(v)), nodes)
            d = Dict(v => parse(Int, v[2:end]) for v in nodes)
        else
            d = Dict(nodes[i] => parse(Int, nodes[i]) for i=1:n)
        end
        @assert minimum(values(d)) == 1
        @assert maximum(values(d)) == n
        return d
    catch
        return Dict(zip(nodes, 1:n))
    end
end

function _readdot{G<:ASimpleGraph}(pg, ::Type{G})
    n = length(DOT.nodes(pg))
    nodedict = _dot_nodes_to_dict(pg)
    g = G(n)
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

    for i=1:nv(g)
        if degree(g, i) == 0
            println(io, "\tn$i;")
        end
    end

    for e in edges(g)
        println(io, "\tn$(src(e)) $eop n$(dst(e));")
    end

    println(io, "}")
    return 1
end

filemap[:dot] = (readdot, writedot)
