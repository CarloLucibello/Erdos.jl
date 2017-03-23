function _readgml{G}(xg, ::Type{G})
    mapping = Dict{Int,Int}()
    if haskey(xg,:node)
        for (i, x) in enumerate(xg[:node])
            mapping[x[:id]] = i
        end
    end
    g = G(length(mapping))
    if haskey(xg, :edge)
        for e in xg[:edge]
            add_edge!(g, mapping[e[:source]], mapping[e[:target]])
        end
    end
    return g
end

function readgml{G}(io::IO, ::Type{G})
    xg = first(GML.parse_dict(readstring(io))[:graph])
    dir = Bool(get(xg, :directed, 0))
    H = dir ? digraphtype(G) : graphtype(G)
    return _readgml(xg, H)
end

gmltypeof(x) = typeof(x)
gmltypeof(x::SubString) = String
gmlval(x) = x
gmlval(x::SubString) = String(x)
gmlprintval(x) = x
gmlprintval(x::String) = "\"" * x * "\""

function _readnetgml{G}(xg, ::Type{G})
    mapping = Dict{Int,Int}()
    g = haskey(xg,:node) ? G(length(xg[:node])) : G()
    for (k, v) in xg
        k ∈ (:node, :edge, :directed) && continue
        pname = string(k)
        gprop!(g, pname, gmlval(v))
    end

    if haskey(xg,:node)
        for (i, xv) in enumerate(xg[:node])
            mapping[xv[:id]] = i
            for (k, v) in xv
                k == :id && continue
                pname = string(k)
                !has_vprop(g, pname) && vprop!(g, pname, gmltypeof(v))
                vprop(g, pname)[i] = gmlval(v)
            end
        end
    end
    if haskey(xg, :edge)
        for xe in xg[:edge]
            ok, e = add_edge!(g, mapping[xe[:source]], mapping[xe[:target]])
            !ok && warn("found edge duplicate")
            for (k, v) in xe
                (k == :source || k == :target) && continue
                pname = string(k)
                !has_eprop(g, pname) && eprop!(g, pname, gmltypeof(v))
                eprop(g, pname)[e] = gmlval(v)
            end
        end
    end
    return g
end

function readnetgml{G<:ANetOrDiNet}(io::IO, ::Type{G})
    xg = first(GML.parse_dict(readstring(io))[:graph])
    dir = Bool(get(xg, :directed, 0))
    H = dir ? digraphtype(G) : graphtype(G)
    return _readnetgml(xg, H)
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
    # length(gname) > 0 && println(io, "label \"$gname\"")
    is_directed(g) && println(io, "\tdirected 1")
    for (pname, p) in gprop(g)
        println(io,"\t$pname $(gmlprintval(p))")
    end
    for i=1:nv(g)
        println(io,"\tnode [")
        println(io,"\t\tid $i")
        for (pname, p) in vprop(g)
            hasindex(p, i) && println(io,"\t\t$pname $(gmlprintval(p[i]))")
        end
        println(io,"\t]")
    end
    for e in edges(g)
        println(io,"\tedge [")
        println(io,"\t\tsource $(src(e))")
        println(io,"\t\ttarget $(dst(e))")
        for (pname, p) in eprop(g)
            haskey(p, e) && println(io,"\t\t$pname $(gmlprintval(p[e]))")
        end
        println(io,"\t]")
    end
    println(io, "]")
    return 1
end

filemap[:gml] = (readgml, writegml, readnetgml, writenetgml)
