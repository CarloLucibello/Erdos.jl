_magic = "⛾ gt"
_version = 1


function minutype(n::Integer)
    @assert n ≥ 0
    if n < 2^8
        return UInt8
    elseif n < 2^16
        return UInt16
    elseif n < 2^32
        return UInt32
    elseif n < 2^64
        return UInt64
    end
    error("No type big enough")
end

function writegt(io::IO, g::ASimpleGraph)
    write(io, _magic)
    write(io, UInt8(_version))
    write(io, false) # endiannes, false=little endian
    write(io, UInt64(0)) # length of comment string
    write(io, is_directed(g))
    write(io, UInt64(nv(g)))

    T = minutype(nv(g))
    writegt_adj(io, g, T)

    writegt_props(io, g)

    return 1
end

function writegt_adj{T}(io::IO, g::ADiGraph, ::Type{T})
    for i=1:nv(g)
        write(io, UInt64(degree(g, i)))
        for v in out_neighbors(g, i)
            write(io, T(v-1))
        end
    end
end

function writegt_adj{T}(io::IO, g::AGraph, ::Type{T})
    for i=1:nv(g)
        neigs = out_neighbors(g, i)
        k = count(j -> j>=i, neigs)
        write(io, UInt64(k))
        for v in neigs
            if v >= i
                write(io, T(v-1))
            end
        end
    end
end

function writegt_props(io::IO, g::ASimpleGraph)
    write(io, UInt64(0)) # num of property maps
end

function readgt{G<:ASimpleGraph}(io::IO, ::Type{G})
    @assert String(read(io, 6)) == _magic "gt file not correctly formatted"
    ver = read(io, UInt8)  ## version
    indian = read(io, Bool)
    @assert indian == false
    lencomment = read(io, UInt64)
    read(io, lencomment)
    isdir = read(io, Bool)
    n = read(io, UInt64)
    T = minutype(n)
    g = isdir ? digraph(G(Int(n))) : graph(G(Int(n)))

    readgt_adj!(io, g, T)
    return g
end

function readnetgt{G<:ASimpleNetwork}(io::IO, ::Type{G})
    @assert String(read(io, 6)) == _magic "gt file not correctly formatted"
    ver = read(io, UInt8)  ## version
    indian = read(io, Bool)
    @assert indian == false
    lencomment = read(io, UInt64)
    read(io, lencomment) #skip comments
    isdir = read(io, Bool)
    n = read(io, UInt64)
    T = minutype(n)
    g = isdir ? digraph(G(Int(n))) : graph(G(Int(n)))

    readgt_adj!(io, g, T)
    readgt_props!(io, g)
    return g
end

function readgt_props!(io::IO, g::ASimpleNetwork)
    nprops = read(io, UInt64)
    for i=1:nprops
        ptype = read(io, UInt8)
        num = ptype == 0 ? 1 :
              ptype == 1 ? nv(g) : ne(g)

        namelen = read(io, UInt64)
        pname = String(read(io, namelen))
        pvaln = read(io, UInt8)
        T = gtpropmap[pvaln]
        if pvaln <= 4  #pvaln==5 -> Float128 not supported
            m = read(io, T, num)
        elseif pvaln == 5 #float128
            error("not implemented") #TODO
        elseif pvaln == 6
            m = [(l = read(io, UInt64); String(read(io, l))) for _=1:num]
        elseif pvaln ∈ [7, 8, 9, 10, 11]
            m = [(l = read(io, UInt64); read(io, eltype(T), l)) for _=1:num]
        else # pvaln > 5 (vectors)
            error("not implemented") #TODO
        end

        if ptype == 0 #graph
            #TODO
        elseif ptype == 1
            add_vertex_property!(g, pname, m)
        elseif ptype == 2
            add_edge_property!(g, pname, m)
        end
    end

end

const gtpropmap = Dict( 0x00 => Bool,
                        0x01 => Int16,
                        0x02 => Int32,
                        0x03 => Int64,
                        0x04 => Float64,
                        # 0x05 => Float128,
                        0x06 => String,
                        0x07 => Vector{Bool},
                        0x08 => Vector{Int16},
                        0x09 => Vector{Int32},
                        0x0a => Vector{Int64},
                        0x0b => Vector{Float64},
                        # 0x0c => Vector{Float128},
                        0x0d => Vector{String})

function readgt_adj!{T}(io::IO, g::ADiGraph, ::Type{T})
    for i=1:nv(g)
        k = read(io, UInt64)
        for _=1:k
            j = read(io, T) + 1
            # unsafe_add_edge!(g, i, j)
            add_edge!(g, i, j)
        end
    end
    # rebuild!(g)
end

function readgt_adj!{T}(io::IO, g::AGraph, ::Type{T})
    for i=1:nv(g)
        k = read(io, UInt64)
        for _=1:k
            j = read(io, T) + 1
            # @assert j >= i
            # unsafe_add_edge!(g, i, j)
            add_edge!(g, i, j)
        end
    end
    # rebuild!(g)
end

filemap[:gt] = (readgt, writegt, readnetgt, NI)
