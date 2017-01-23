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

function readgt{G}(io::IO, ::Type{G})
    @assert String(read(io, 6)) == _magic
    ver = read(io, UInt8)  ## version
    indian = read(io, Bool)
    @assert indian == false
    lencomment = read(io, UInt64)
    # println(String(read(io, lencomment)))
    read(io, lencomment) #skip comments
    isdir = read(io, Bool)
    n = read(io, UInt64)
    T = minutype(n)
    g = isdir ? digraph(G(n)) : graph(G(n))

    # println("$n $indian $T $isdir")
    readgt_adj!(io, g, T)
    return g
end

function readgt_adj!{T}(io::IO, g::ADiGraph, ::Type{T})
    for i=1:nv(g)
        k = read(io, UInt64)
        for _=1:k
            j = read(io, T) + 1
            unsafe_add_edge!(g, i, j)
        end
    end
    rebuild!(g)
end

function readgt_adj!{T}(io::IO, g::AGraph, ::Type{T})
    for i=1:nv(g)
        k = read(io, UInt64)
        for _=1:k
            j = read(io, T) + 1
            unsafe_add_edge!(g, i, j)
        end
    end
    rebuild!(g)
end

filemap[:gt] = (readgt, writegt)
