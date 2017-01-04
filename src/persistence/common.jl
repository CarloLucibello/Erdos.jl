NI(x...) = error("This function is not implemented.")

# filemap is filled in the format specific source files
const filemap = Dict{Symbol, Tuple{Function, Function}}()
        # :gml        => (readgml, writegml)
        # :graphml    => (readgraphml, writegraphml)
        # ....

"""
    readgraph(file, t, G=Graph; compressed=false)

Reads a graph from  `file` in the format `t`. Returns a graph of type `G`.
Compressed files can eventually be read.

Supported formats are `:gml, :dot, :graphml, :gexf, :NET`.
"""
function readgraph{G<:ASimpleGraph}(fn::String, t::Symbol, ::Type{G}=Graph; compressed=false)
    if compressed
        io = GZip.open(fn,"r")
        g = readgraph(io, t, G)
        close(io)
        return g
    else
        io = open(fn,"r")
        g = readgraph(io, t, G)
        close(io)
        return g
    end
end

function readgraph{G<:ASimpleGraph}(io::IO, t::Symbol, ::Type{G}=Graph)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    return filemap[t][1](io, G)
end


"""
    writegraph(file, g, t; compress=false)

Save a graph `g` to `file` in the format `t`.

Eventually the resulting file can be compressed in the gzip format.

Currently supported formats are `:gml, :graphml, :gexf, :dot, :NET`.
"""
function writegraph(io::IO, g::ASimpleGraph, t::Symbol)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    return filemap[t][2](io, g)
end

# save to a file
function writegraph(fn::String, g::ASimpleGraph, t::Symbol; compress::Bool=false)
    if compress
        io = GZip.open(fn,"w")
    else
        io = open(fn,"w")
    end
    retval = writegraph(io, g, t)
    close(io)
    return retval
end
