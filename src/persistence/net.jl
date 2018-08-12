
"""
Writes a graph `g` to a file `f` in the [Pajek
.net](http://gephi.github.io/users/supported-graph-formats/pajek-net-format/) format.
Returns 1 (number of graphs written).
"""
function writepajek(f::IO, g::AGraphOrDiGraph)
    println(f, "*Vertices $(nv(g))")
    # write edges
    if is_directed(g)
        println(f, "*Arcs")
    else
        println(f, "*Edges")
    end
    for e in edges(g)
        println(f, "$(src(e)) $(dst(e))")
    end
    return 1
end

"""
    readpajek{G}(f::IO, ::Type{G})

Reads a graph from file `f` in the [Pajek .net](http://gephi.github.io/users/supported-graph-formats/pajek-net-format/) format.
Returns 1 (number of graphs written).
"""
function readpajek(f::IO, ::Type{G}) where G
    line =readline(f)
    # skip comments
    while startswith(line, "%")
        line =readline(f)
    end
    n = parse(Int, match(r"\d+",line).match)
    for fline in eachline(f)
        line = fline
        (occursin(r"^\*Arcs",line) || occursin(r"^\*Edges",line)) && break
    end
    dir = occursin(r"^\*Arcs",line)
    g = G(n)
    g = dir ? digraph(g) : graph(g)
    readpajek_edges!(g, f, line)
    return g
end

function readpajek_edges!(g::G, f::IO, line) where G<:AGraph
    while occursin(r"^\*Edges",line) && !eof(f)
        for fline in eachline(f)
            line = fline
            m = collect(eachmatch(r"\d+",line))
            length(m) < 2 && break
            i1, i2 = parse(Int, m[1].match), parse(Int, m[2].match)
            unsafe_add_edge!(g, i1, i2)
        end
    end
    rebuild!(g)
end

function readpajek_edges!(g::G, f::IO, line) where G<:ADiGraph
    while occursin(r"^\*Arcs",line) # add edges in both directions
        for fline in eachline(f)
            line = fline
            m = collect(eachmatch(r"\d+",line))
            length(m) < 2 && break
            i1, i2 = parse(Int, m[1].match), parse(Int, m[2].match)
            unsafe_add_edge!(g, i1, i2)
        end
    end
    while occursin(r"^\*Edges",line) # add edges in both directions
        for fline in eachline(f)
            line = fline
            m = collect(eachmatch(r"\d+",line))
            length(m) < 2 && break
            i1, i2 = parse(Int, m[1].match), parse(Int, m[2].match)
            unsafe_add_edge!(g, i1, i2)
            unsafe_add_edge!(g, i2, i1)
        end
    end
    rebuild!(g)
end

filemap[:net] = (readpajek, writepajek, NI, NI)
