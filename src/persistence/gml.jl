function _readgml{G}(io::IO, line, ::Type{G})
    mapping = Dict{Int,Int}()
    i = 0
    while startswith(line, "node")
        i += 1
        line = readline(io) |> strip
        line == "[" && (line = readline(io) |> strip)
        while !startswith(line, "]")
            name, valstr = splitgml(line)
            if name == "id"
                mapping[parse(Int, valstr)] = i
            end
            line = readline(io) |> strip
        end
        line = readline(io) |> strip #skip ]
    end
    g = G(i)
    while startswith(line, "edge")
        line = readline(io) |> strip
        line == "[" && (line = readline(io) |> strip)
        u = -1
        v = -1
        while !startswith(line, "]")
            name, valstr = splitgml(line)
            if name == "source"
                id = parse(Int, valstr)
                u = mapping[id]
            elseif name == "target"
                id = parse(Int, valstr)
                v = mapping[id]
            end
            line = readline(io) |> strip
        end
        @assert u > 0 && v > 0
        add_edge!(g, u, v)
        line = readline(io) |> strip #skip ]
    end
    return g
end

function readgml{G}(io::IO, ::Type{G})
    H = G
    line = readline(io) |> strip
    @assert startswith(line, "graph")
    line = readline(io) |> strip
    line == "[" && (line = readline(io) |> strip)
    while !startswith(line, "node") && !isempty(line)
        if startswith(line, "directed")
            H = parse(Int, line[10:end]) == 1 ? digraphtype(G) : graphtype(G)
        end
        line = readline(io) |> strip
    end
    return _readgml(io, line, H)
end

function gmltypeof(valstr)
    str = strip(valstr, '\"')
    if length(str) < length(valstr)
        return String
    else
        return Float64
    end
end

gmlval{T}(::Type{T}, x) = parse(T, x)
gmlval(::Type{String}, x) = strip(x, '\"')
function splitgml(s::AbstractString)
    i = findfirst(s, ' ')
    return SubString(s, 1, i-1), SubString(s, i+1, length(s))
end

gmlprintval(x) = x
gmlprintval(x::String) = "\"" * x * "\""


function _readnetgml(io::IO, line, g)
    mapping = Dict{Int,Int}()
    i = 0
    while startswith(line, "node")
        i += 1
        line = readline(io) |> strip
        line == "[" && (line = readline(io) |> strip)
        @assert startswith(line, "id")
        name, valstr = splitgml(line)
        mapping[parse(Int, valstr)] = i
        add_vertex!(g)
        line = readline(io) |> strip
        while !startswith(line, "]")
            name, valstr = splitgml(line)
            !has_vprop(g, name) && vprop!(g, name, String)
            T = valtype(vprop(g, name))
            vprop(g, name)[i] = gmlval(T, valstr)
            line = readline(io) |> strip
        end

        line = readline(io) |> strip #skip ]
    end

    while startswith(line, "edge")
        line = readline(io) |> strip
        line == "[" && (line = readline(io) |> strip)
        startswith(line, "id") && (line = readline(io) |> strip)

        @assert startswith(line, "source")
        name, valstr = splitgml(line)
        u = mapping[parse(Int, valstr)]
        line = readline(io) |> strip
        @assert startswith(line, "target")
        name, valstr = splitgml(line)
        v = mapping[parse(Int, valstr)]
        line = readline(io) |> strip
        ok, e = add_edge!(g, u, v)

        while !startswith(line, "]")
            name, valstr = splitgml(line)
            !has_eprop(g, name) && eprop!(g, name, gmltypeof(valstr))
            T = valtype(eprop(g, name))
            eprop(g, name)[e] = gmlval(T, valstr)
            line = readline(io) |> strip
        end

        line = readline(io) |> strip #skip ]
    end
    return g
end


function readnetgml{G<:ANetOrDiNet}(io::IO, ::Type{G})
    H = G
    line = readline(io) |> strip
    @assert startswith(line, "graph")
    line = readline(io) |> strip
    line == "[" && (line = readline(io) |> strip)
    gdict = Dict{String, String}()
    while !startswith(line, "node") && !isempty(line)
        if startswith(line, "directed")
            H = parse(Int, line[10:end]) == 1 ? digraphtype(G) : graphtype(G)
        else
            name, valstr = splitgml(line)
            gdict[name] = gmlval(String, valstr)
        end
        line = readline(io) |> strip
    end
    g = H()
    for (name, val) in gdict
        gprop!(g, name, val)
    end
    return _readnetgml(io, line, g)
end

"""
    writegml(f, g)

Writes a graph `g` to a file `f` in the
[GML](https://en.wikipedia.org/wiki/Graph_Modelling_Language) format.
"""
function writegml(io::IO, g::AGraphOrDiGraph)
    println(io, "graph [")
    # length(gname) > 0 && println(io, "label \"$gname\"")
    is_directed(g) && println(io, "\tdirected 1")
    for i=1:nv(g)
        println(io,"\tnode [")
        println(io,"\t\tid $i")
        println(io,"\t]")
    end
    for (s,t) in edges(g)
        println(io,"\tedge [")
        println(io,"\t\tsource $s")
        println(io,"\t\ttarget $t")
        println(io,"\t]")
    end
    println(io, "]")
    return 1
end

function writenetgml(io::IO, g::ANetOrDiNet)
    println(io, "graph [")
    is_directed(g) && println(io, "\tdirected 1")
    for (pname, p) in gprop(g)
        println(io,"\t$pname $(gmlprintval(p))")
    end
    for i=1:nv(g)
        println(io,"\tnode [")
        println(io,"\t\tid $i")
        for (name, val) in vprop(g, i)
            println(io,"\t\t$name $(gmlprintval(val))")
        end
        println(io,"\t]")
    end
    for e in edges(g)
        println(io,"\tedge [")
        println(io,"\t\tsource $(src(e))")
        println(io,"\t\ttarget $(dst(e))")
        for (name, val) in eprop(g, e)
            println(io,"\t\t$name $(gmlprintval(val))")
        end
        println(io,"\t]")
    end
    println(io, "]")
    return 1
end

filemap[:gml] = (readgml, writegml, readnetgml, writenetgml)
