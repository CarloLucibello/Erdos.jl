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
    write(io, UInt64(0)) # num of property maps

    return 1
end

function writenetgt(io::IO, g::ASimpleNetwork)
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
        write(io, UInt64(out_degree(g, i)))
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
        for j in neigs
            if j >= i
                write(io, T(j-1))
            end
        end
    end
end

#TODO the map has to be a vector
function writegt_eprop(io::IO, g::ADiNetwork, m::AEdgeMap)
    pvaln = findfirst(gtpropmap, valtype(m))
    write(io, UInt8(pvaln-1))
    if pvaln <= 5  #pvaln==5 -> Float128 not supported
        for i=1:nv(g)
            for e in out_edges(g, i)
                write(io, m[e])
            end
        end
    elseif pvaln == 6 #float128
        error("not implemented")
    elseif pvaln == 7
        for i=1:nv(g)
            for e in out_edges(g, i)
                s = m[e]
                write(io, UInt64(sizeof(s)))
                write(io, s)
            end
        end
    elseif pvaln ∈ [8, 9, 10, 11, 12]
        for i=1:nv(g)
            for e in out_edges(g, i)
                s = m[e]
                write(io, UInt64(length(s)))
                write(io, s)
            end
        end
    else
        error("not implemented")
    end
end

#TODO the map has to be a vector
function writegt_eprop(io::IO, g::ANetwork, m::AEdgeMap)
    pvaln = findfirst(gtpropmap, valtype(m))
    write(io, UInt8(pvaln-1))
    if pvaln <= 5  #pvaln==5 -> Float128 not supported
        for i=1:nv(g)
            for e in out_edges(g, i)
                dst(e) < i && continue
                write(io, m[e])
            end
        end
    elseif pvaln == 6 #float128
        error("not implemented")
    elseif pvaln == 7
        for i=1:nv(g)
            for e in out_edges(g, i)
                dst(e) < i && continue
                s = m[e]
                write(io, UInt64(sizeof(s)))
                write(io, s)
            end
        end
    elseif pvaln ∈ [8, 9, 10, 11, 12]
        for i=1:nv(g)
            for e in out_edges(g, i)
                dst(e) < i && continue
                s = m[e]
                write(io, UInt64(length(s)))
                write(io, s)
            end
        end
    else
        error("not implemented")
    end
end

#TODO the map has to be a vector
function writegt_vprop(io::IO, g::ASimpleNetwork, m::AVertexMap)
    pvaln = findfirst(gtpropmap, valtype(m))
    write(io, UInt8(pvaln-1))

    if pvaln <= 5  #pvaln==5 -> Float128 not supported
        for i=1:nv(g)
            write(io, m[i])
        end
    elseif pvaln == 6 #float128
        error("not implemented") #TODO
    elseif pvaln == 7
        for i=1:nv(g)
            s = m[i]
            write(io, UInt64(sizeof(s)))
            write(io, s)
        end
    elseif pvaln ∈ [8, 9, 10, 11, 12]
        for i=1:nv(g)
            s = m[i]
            write(io, UInt64(length(s)))
            write(io, s)
        end
    else
        error("not implemented") #TODO
    end
end

function writegt_props(io::IO, g::ASimpleNetwork)
    vpnames = vertex_properties(g)
    epnames = edge_properties(g)
    write(io, length(vpnames)+length(epnames)) # num of property maps
    for name in vpnames
        write(io, UInt8(1)) #property type (graph/edge/vertex)
        write(io, UInt64(sizeof(name)))
        write(io, name)
        m = vertex_property(g, name)
        writegt_vprop(io, g, m)
    end

    for name in epnames
        write(io, UInt8(2)) #property type (graph/edge/vertex)
        write(io, UInt64(length(name)))
        write(io, name)
        m = edge_property(g, name)
        writegt_eprop(io, g, m)
    end
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
        pvaln = read(io, UInt8) + 1
        T = gtpropmap[pvaln]
        # println("num=$num pvaln=$pvaln $pname $T")
        if pvaln <= 5  #pvaln==5 -> Float128 not supported
            m = read(io, T, num)
        elseif pvaln == 6 #float128
            error("not implemented") #TODO
        elseif pvaln == 7
            m = [(l = read(io, UInt64); String(read(io, l))) for _=1:num]
        elseif pvaln ∈ [8, 9, 10, 11, 12]
            m = [(l = read(io, UInt64); read(io, eltype(T), l)) for _=1:num]
        else
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

const gtpropmap = DataType[   Bool,                   #0x00
                              Int16,                  #0x01
                              Int32,                  #0x02
                              Int64,                  #0x03
                              Float64,                #0x04
                              Float64,               #0x05 #TODO => should be float128
                              String,                 #0x06
                              Vector{Bool},           #0x07
                              Vector{Int16},          #0x08
                              Vector{Int32},          #0x09
                              Vector{Int64},          #0x0a
                              Vector{Float64},        #0x0b
                              Vector{Float64},       #0x0c #TODO => should be float128
                              Vector{String}          #0x0d
                        ]

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

filemap[:gt] = (readgt, writegt, readnetgt, writenetgt)
