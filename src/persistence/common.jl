NI(x...) = error("This function is not implemented.")

# filemap is filled in the format specific source files
const filemap = Dict{Symbol, Tuple{Function, Function, Function, Function}}()
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
function readgraph(fn::String, t::Symbol, ::Type{G}=Graph; compressed=false) where G<:AGraphOrDiGraph
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    io = compressed ? GZip.open(fn,"r") : open(fn,"r")
    g = readgraph(io, t, G)
    close(io)
    return g
end

function readgraph(io::IO, t::Symbol, ::Type{G}=Graph) where G<:AGraphOrDiGraph
    return filemap[t][1](io, G)
end

function readgraph(fn::String, ::Type{G}=Graph) where G<:AGraphOrDiGraph
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
function readgraph(s::Symbol, ::Type{G}=Graph) where G<:AGraphOrDiGraph
    readgraph(joinpath(DATASETS_DIR, string(s) * ".gt.gz"), G)
end

"""
    readnetwork(filename, G=Network)
    readnetwork(filename, t, G=Network; compressed=false)

Readsa network from  `filename` in the format `t`. Returns a netowrk of type `G`
(or the corresponding directed/undirected type if needed).
Compressed files can eventually be read.

Supported formats are `:gml, :dot, :graphml, :gexf, :net, :gt`.
When possible, graph, edge, and vertex properties will be re read as well.

If no format is provided, it will be inferred from the `filename`.

    readnetwork(s::Symbol, G=Network)

Read a network identified by `s` from Erdos' datasets collection (e.g. `s=:karate`).
They are stored in the `gt` binary format in the `datasets` directory of the package.
For a list of available graph refer to the documentation.
"""
function readnetwork(fn::String, t::Symbol, ::Type{G}=Network; compressed=false) where G<:ANetOrDiNet
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    io = compressed ? GZip.open(fn,"r") : open(fn,"r")
    g = readnetwork(io, t, G)
    close(io)
    return g
end

function readnetwork(io::IO, t::Symbol, ::Type{G}=Network) where G<:ANetOrDiNet
    return filemap[t][3](io, G)
end

function readnetwork(fn::String, ::Type{G}=Network) where G<:ANetOrDiNet
    compressed = false
    ft = split(fn,'.')[end]
    if ft == "gz"
        compressed = true
        ft = split(fn,'.')[end-1]
    end
    Symbol(ft) in keys(filemap) || error("Could not infer file format.")
    return readnetwork(fn, Symbol(ft), G; compressed=compressed)
end

function readnetwork(s::Symbol, ::Type{G}=Network) where G<:AGraphOrDiGraph
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

Save a netowrk `g` to `file` in the format `t`.

Eventually the resulting file can be compressed in the gzip format.

Currently supported formats are `:gml, :graphml, :gexf, :dot, :net, :gt`.
When possible, graph, edge, and vertex properties will be written as well.

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
    i = findfirst(x->nodename(x)==s, childs)
    i === nothing && error("no child $s")
    return childs[i]
end

"adds a child `s` to `el` if it doesn't exist"
function getchild!(el::EzXML.Node, s::String)
    childs = elements(el)
    i = findfirst(x->nodename(x)==s, childs)
    return i !== nothing ? childs[i] : addelement!(el, s)
end
