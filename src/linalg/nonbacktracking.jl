"""
Given two oriented edges i->j and k->l in g, the
non-backtraking matrix B is defined as

B[i->j, k->l] = δ(j,k)* (1 - δ(i,l))

returns a matrix B, and an edgemap storing the oriented edges' positions in B
"""
function nonbacktracking_matrix(g::ASimpleGraph)
    E = Edge{vertextype(g)}
    edgeidmap = Dict{E, Int}()
    m = 0
    for e in edges(g)
        m += 1
        edgeidmap[E(src(e),dst(e))] = m
    end

    if !is_directed(g)
        for e in edges(g)
            m += 1
            ee = E(src(e),dst(e))
            edgeidmap[reverse(ee)] = m
        end
    end

    B = zeros(Float64, m, m)

    for (e,u) in edgeidmap
        i, j = src(e), dst(e)
        for k in in_neighbors(g,i)
            k == j && continue
            v = edgeidmap[E(k, i)]
            B[v, u] = 1
        end
    end

    return B, edgeidmap
end

"""Nonbacktracking: a compact representation of the nonbacktracking operator

    g: the underlying graph
    edgeidmap: the association between oriented edges and index into the NBT matrix

The Nonbacktracking operator can be used for community detection.
This representation is compact in that it uses only ne(g) additional storage
and provides an implicit representation of the matrix B_g defined below.

Given two oriented edges i->j and k->l in g, the
non-backtraking matrix B is defined as

B[i->j, k->l] = δ(j,k)* (1 - δ(i,l))

This type is in the style of GraphMatrices.jl and supports the necessary operations
for computed eigenvectors and conducting linear solves.

Additionally the contract!(vertexspace, nbt, edgespace) method takes vectors represented in
the domain of B and represents them in the domain of the adjacency matrix of g.
"""
type Nonbacktracking{G, E}
    g::G
    edgeidmap::Dict{E,Int}
    m::Int
end

function Nonbacktracking(g::ASimpleGraph)
    E = Edge{vertextype(g)}
    edgeidmap = Dict{E, Int}()
    m = 0
    for e in edges(g)
        ee = E(src(e),dst(e))
        m += 1
        edgeidmap[ee] = m
    end
    if !is_directed(g)
        for e in edges(g)
            ee = E(src(e),dst(e))
            m += 1
            edgeidmap[reverse(ee)] = m
        end
    end
    return Nonbacktracking(g, edgeidmap, m)
end

size(nbt::Nonbacktracking) = (nbt.m,nbt.m)
eltype(nbt::Nonbacktracking) = Float64
issymmetric(nbt::Nonbacktracking) = false

function *{G, T<:Number}(nbt::Nonbacktracking{G}, x::Vector{T})
    E = Edge{vertextype(nbt.g)}
    length(x) == nbt.m || error("dimension mismatch")
    y = zeros(T, length(x))
    for (e,u) in nbt.edgeidmap
        i, j = src(e), dst(e)
        for k in in_neighbors(nbt.g,i)
            k == j && continue
            v = nbt.edgeidmap[Edge(k, i)]
            y[v] += x[u]
        end
    end
    return y
end
function A_mul_B!(C, nbt::Nonbacktracking, B)
    # computs C = A*B
    for i in 1:size(B,2)
        C[:,i] = nbt*B[:,i]
    end
    return C
end

function coo_sparse{G}(nbt::Nonbacktracking{G})
    E = Edge{vertextype(nbt.g)}
    m = nbt.m
    #= I,J = zeros(Int, m), zeros(Int, m) =#
    I,J = zeros(Int, 0), zeros(Int, 0)
    for (e,u) in nbt.edgeidmap
        i, j = src(e), dst(e)
        for k in in_neighbors(nbt.g,i)
            k == j && continue
            v = nbt.edgeidmap[E(k, i)]
            #= J[u] = v =#
            #= I[u] = u =#
            push!(I, v)
            push!(J, u)
        end
    end
    return I,J,1.0
end

sparse(nbt::Nonbacktracking) = sparse(coo_sparse(nbt)..., nbt.m,nbt.m)

function *{G, T<:Number}(nbt::Nonbacktracking{G}, x::AbstractMatrix{T})
    y = zeros(x)
    for i in 1:nbt.m
        y[:,i] = nbt * x[:,i]
    end
    return y
end

"""contract!(vertexspace, nbt, edgespace) in place version of
contract(nbt, edgespace). modifies first argument
"""
function contract!{G}(vertexspace::Vector, nbt::Nonbacktracking{G}, edgespace::Vector)
    E = Edge{vertextype(nbt.g)}
    for i=1:nv(nbt.g)
        for j in neighbors(nbt.g, i)
            u = nbt.edgeidmap[i > j ? E(j,i) : E(i,j)]
            vertexspace[i] += edgespace[u]
        end
    end
end

"""contract(nbt, edgespace)
Integrates out the edges by summing over the edges incident to each vertex.
"""
function contract(nbt::Nonbacktracking, edgespace::Vector)
    y = zeros(eltype(edgespace), nv(nbt.g))
    contract!(y,nbt,edgespace)
    return y
end
