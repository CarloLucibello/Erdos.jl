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

function writegt(io::IO, g::AGraphOrDiGraph)
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

function writenetgt(io::IO, g::ANetOrDiNet)
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


function writegt_adj(io::IO, g::ADiGraph, ::Type{T}) where T
    for i=1:nv(g)
        write(io, UInt64(out_degree(g, i)))
        for v in out_neighbors(g, i)
            write(io, T(v-1))
        end
    end
end

function writegt_adj(io::IO, g::AGraph, ::Type{T}) where T
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

function writegt_props(io::IO, g::ANetOrDiNet)
    nprop = length(gprop(g)) + length(vprop(g)) + length(eprop(g))
    write(io, nprop) # num of property maps
    # @show nprop
    #graph props
    for (pname, p) in gprop(g)
        write(io, UInt8(0)) #property type (graph/edge/vertex)
        writegt_prop(io, pname)
        pvaln = findfirst(isequal(typeof(p)), gtpropmap)
        write(io, UInt8(pvaln-1))
        writegt_prop(io, p)
    end
    #vertex props
    for (pname, p) in vprop(g)
        write(io, UInt8(1)) #property type (graph/edge/vertex)
        writegt_prop(io, pname)
        pvaln = findfirst(isequal(valtype(p)), gtpropmap)
        write(io, UInt8(pvaln-1))

        for i=1:nv(g)
            writegt_prop(io, p[i])
        end
    end
    #edge props
    for (pname, p) in eprop(g)
        write(io, UInt8(2)) #property type (graph/edge/vertex)
        writegt_prop(io, pname)
        pvaln = findfirst(isequal(valtype(p)), gtpropmap)
        write(io, UInt8(pvaln-1))
        if is_directed(g)
            for i=1:nv(g)
                for e in out_edges(g, i)
                    writegt_prop(io, p[e])
                end
            end
        else
            for i=1:nv(g)
                for e in out_edges(g, i)
                    dst(e) < i && continue
                    writegt_prop(io, p[e])
                end
            end
        end
    end
end

function readgt(io::IO, ::Type{G}) where G<:AGraphOrDiGraph
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

function readnetgt(io::IO, ::Type{G}) where G<:ANetOrDiNet
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

function readgt_props!(io::IO, g::ANetOrDiNet)
    nprops = read(io, UInt64)
    for i=1:nprops
        ptype = read(io, UInt8)
        num = ptype == 0 ? 1 :
              ptype == 1 ? nv(g) : ne(g)
        namelen = read(io, UInt64)
        pname = String(read(io, namelen))
        pvaln = read(io, UInt8) + 1
        # @show num namelen pname pvaln
        pvaln ∈ [6,13,14] && error("not implemented") #TODO
        T = gtpropmap[pvaln]
        m = readgt_prop(io, T, num)

        if ptype == 0
            set_graph_property!(g, pname, m[1])
        elseif ptype == 1
            add_vertex_property!(g, pname, m)
        elseif ptype == 2
            add_edge_property!(g, pname, EdgeMap(g, m))
        end
    end

end


const Num = Union{Bool,Int16,Int32,Int64,Float64}

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

readgt_prop(io, ::Type{T}, num) where {T<:Num} = read!(io, Vector{T}(undef, num))
function readgt_prop(io, ::Type{Vector{T}}, num) where {T <: Num}
    [(l = read(io, UInt64); read!(io, Vector{T}(undef, l))) for _=1:num]
end
readgt_prop(io, ::Type{String}, num) = [(l = read(io, UInt64); String(read(io, l))) for _=1:num]

writegt_prop(io, x::T) where {T<:Num} = write(io, x)
writegt_prop(io, x::Vector{T}) where {T<:Num} = 
    (write(io, length(x)); write(io, x))
writegt_prop(io, x::String) = (write(io, sizeof(x)); write(io, x))

function readgt_adj!(io::IO, g::ADiGraph, ::Type{T}) where T
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

function readgt_adj!(io::IO, g::AGraph, ::Type{T}) where T
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
