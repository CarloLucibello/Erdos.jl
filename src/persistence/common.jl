NI(x...) = error("This function is not implemented.")

# filemap is filled in the format specific source files
const filemap = Dict{Symbol, Tuple{Function, Function}}()
        # :gml        => (readgml, writegml)
        # :graphml    => (readgraphml, savegraphml)
        # ....

"""
    readgraph(file, t)

Reads a graph from  `file` in the format `t`.

Supported formats are `:gml, :dot, :graphml, :gexf, :NET, :jld`.
"""
function readgraph(fn::String, t::Symbol)
    GZip.open(fn,"r") do io
        readgraph(io, t)
    end
end

function readgraph(io::IO, t::Symbol)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    return filemap[t][1](io)
end


"""
    writegraph(file, g, t; compress=false)

Save a graph `g` to `file` in the format `t`.

Eventually the resulting file can be compressed in the gzip format.

Currently supported formats are `:lg, :gml, :graphml, :gexf, :dot, :NET`.
"""
function writegraph(io::IO, g::AS, t::Symbol)
    t in keys(filemap) || error("Please select a supported graph format: one of $(keys(filemap))")
    return filemap[t][2](io, g)
end

# save to a file
function writegraph(fn::String, g::AS, t::Symbol; compress::Bool=false)
    if compress
        io = GZip.open(fn,"w")
    else
        io = open(fn,"w")
    end
    retval = writegraph(io, g, t)
    close(io)
    return retval
end
