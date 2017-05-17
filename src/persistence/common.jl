NI(x...) = error("This function is not implemented.")

# filemap is filled in the format specific source files
@compat const filemap = Dict{Symbol, Tuple{Function, Function, Function, Function}}()
        # :gml        => (readgml, writegml, readnetgml, writenetgml)


"""
    readgraph(filename, G=Graph)
    readgraph(filename, t, G=Graph; compressed=false)

Reads a graph from  `filename` in the format `t`. Returns a graph of type `G`
or the corresponding digraph/graph type.
Compressed files can eventually be read.

Supported formats are `:gml, :dot, :graphml, :gexf, :net, :gt`.

If no format is provided, it will be inferred from `filename`.

    readgraph(s::Symbol, G=Graph)

Read a graph identified by `s` from Erdos datasets collection (e.g. `s=:karate`).
They are stored in the `gt` binary format in the `datasets` directory of the package.
For a list of available graph refer to the documentation.
"""
function readgraph{G<:AGraphOrDiGraph}(fn::String, t::Symbol, ::Type{G}=Graph; compressed=false)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    io = compressed ? GZip.open(fn,"r") : open(fn,"r")
    g = readgraph(io, t, G)
    close(io)
    return g
end

function readgraph{G<:AGraphOrDiGraph}(io::IO, t::Symbol, ::Type{G}=Graph)
    return filemap[t][1](io, G)
end

function readgraph{G<:AGraphOrDiGraph}(fn::String, ::Type{G}=Graph)
    compressed = false
    ft = split(fn,'.')[end]
    if ft == "gz"
        compressed = true
        ft = split(fn,'.')[end-1]
    end
    Symbol(ft) in keys(filemap) || error("Could not infer file format.")
    return readgraph(fn, Symbol(ft), G; compressed=compressed)
end

const DATASETS_DIR = joinpath(Base.source_dir(), "..", "..", "datasets")
function readgraph{G<:AGraphOrDiGraph}(s::Symbol, ::Type{G}=Graph)
    readgraph(joinpath(DATASETS_DIR, string(s) * ".gt.gz"), G)
end

"""
    readnetwork(filename, G=Graph)
    readnetwork(filename, t, G=Graph; compressed=false)

Reads a graph from  `filename` in the format `t`. Returns a graph of type `G`
or the corresponding digraph/graph type.
Compressed files can eventually be read.

Supported formats are `:gml, :dot, :graphml, :gexf, :net, :gt`.

If no format is provided, it will be inferred from `filename`.

    readnetwork(s::Symbol, G=Graph)

Read a graph identified by `s` from Erdos datasets collection (e.g. `s=:karate`).
They are stored in the `gt` binary format in the `datasets` directory of the package.
For a list of available graph refer to the documentation.
"""
function readnetwork{G<:ANetOrDiNet}(fn::String, t::Symbol, ::Type{G}=Network; compressed=false)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    io = compressed ? GZip.open(fn,"r") : open(fn,"r")
    g = readnetwork(io, t, G)
    close(io)
    return g
end

function readnetwork{G<:ANetOrDiNet}(io::IO, t::Symbol, ::Type{G}=Network)
    return filemap[t][3](io, G)
end

function readnetwork{G<:ANetOrDiNet}(fn::String, ::Type{G}=Network)
    compressed = false
    ft = split(fn,'.')[end]
    if ft == "gz"
        compressed = true
        ft = split(fn,'.')[end-1]
    end
    Symbol(ft) in keys(filemap) || error("Could not infer file format.")
    return readnetwork(fn, Symbol(ft), G; compressed=compressed)
end

function readnetwork{G<:AGraphOrDiGraph}(s::Symbol, ::Type{G}=Network)
    readnetwork(joinpath(DATASETS_DIR, string(s) * ".gt.gz"), G)
end

"""
    writegraph(file, g)
    writegraph(file, g, t; compress=false)

Save a graph `g` to `file` in the format `t`.

Eventually the resulting file can be compressed in the gzip format.

Currently supported formats are `:gml, :graphml, :gexf, :dot, :net, :gt`.

If no format is provided, it will be inferred from `file` along with compression.
"""
function writegraph(io::IO, g::AGraphOrDiGraph, t::Symbol)
    return filemap[t][2](io, g)
end

function writegraph(fn::String, g::AGraphOrDiGraph, t::Symbol; compress::Bool=false)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    io = compress ? GZip.open(fn,"w") : open(fn,"w")
    retval = writegraph(io, g, t)
    close(io)
    return retval
end

function writegraph(fn::String, g::AGraphOrDiGraph)
    compress = false
    ft = split(fn,'.')[end]
    if ft == "gz"
        compress = true
        ft = split(fn,'.')[end-1]
    end
    Symbol(ft) in keys(filemap) || error("Could not infer file format.")
    return writegraph(fn, g, Symbol(ft), compress=compress)
end

"""
    writenetwork(file, g)
    writenetwork(file, g, t; compress=false)

Save a graph `g` to `file` in the format `t`.

Eventually the resulting file can be compressed in the gzip format.

Currently supported formats are `:gml, :graphml, :gexf, :dot, :net, :gt`.

If no format is provided, it will be inferred from `file` along with compression.
"""
function writenetwork(io::IO, g::ANetOrDiNet, t::Symbol)
    return filemap[t][4](io, g)
end

function writenetwork(fn::String, g::ANetOrDiNet, t::Symbol; compress::Bool=false)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    io = compress ? GZip.open(fn,"w") : open(fn,"w")
    retval = writenetwork(io, g, t)
    close(io)
    return retval
end

function writenetwork(fn::String, g::ANetOrDiNet)
    compress = false
    ft = split(fn,'.')[end]
    if ft == "gz"
        compress = true
        ft = split(fn,'.')[end-1]
    end
    Symbol(ft) in keys(filemap) || error("Could not infer file format.")
    return writenetwork(fn, g, Symbol(ft), compress=compress)
end

function getchild(el::EzXML.Node, s::String)
    childs = elements(el)
    i = findfirst(x->name(x)==s, childs)
    i == 0 && error("no child $s")
    return childs[i]
end

function haschild(el::EzXML.Node, s::String)
    return any(x->name(x)==s, eachelement(el))
end
