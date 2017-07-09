"""
    complete(g::ADiGraph)

Returns a digraph containing both the edges `(u,v)`
of `g` and their reverse `(v,u)`. See also [`complete!`](@ref)
"""
function complete(g::ADiGraph)
    h = copy(g)
    complete!(h)
    return h
end

"""
    complete!(g::ADiGraph)

A a digraph containing both the edges `(u,v)`
of `g` and their reverse `(v,u)`.
"""
function complete!(g::ADiGraph)
    edgs  = collect(edges(g))
    for e in edgs
        if !has_edge(g, dst(e), src(e))
            add_edge!(g, dst(e), src(e))
        end
    end
    return g
end

"""
    complement(g)

Produces the [graph complement](https://en.wikipedia.org/wiki/Complement_graph)
of a graph.
"""
function complement{T<:AGraph}(g::T)
    gnv = nv(g)
    h = T(gnv)
    for i=1:gnv
        for j=i+1:gnv
            if !has_edge(g, i, j)
                add_edge!(h,i,j)
            end
        end
    end
    return h
end

function complement{T<:ADiGraph}(g::T)
    gnv = nv(g)
    h = T(gnv)
    for i=1:gnv
        for j=1:gnv
            if i != j && !has_edge(g,i,j)
                add_edge!(h,i,j)
            end
        end
    end
    return h
end

"""
    union(g, h)

Merges graphs `g` and `h` by taking the set union of all vertices and edges.
"""
function union{T<:AGraphOrDiGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = copy(g)
    add_vertices!(r, max(gnv, hnv) - gnv)
    for e in edges(h)
        add_edge!(r, e)
    end
    return r
end


"""
    blkdiag(g, h)

Produces a graph with ``|V(g)| + |V(h)|`` vertices and ``|E(g)| + |E(h)|``
edges.

Put simply, the vertices and edges from graph `h` are appended to graph `g`.
"""
function blkdiag{T<:AGraphOrDiGraph}(g::T, h::T)
    gnv = nv(g)
    r = T(gnv + nv(h))
    for e in edges(g)
        add_edge!(r, e)
    end
    for e in edges(h)
        add_edge!(r, gnv+src(e), gnv+dst(e))
    end
    return r
end

"""
    intersect(g, h)

Produces a graph with edges that are only in both graph `g` and graph `h`.

Note that this function may produce a graph with 0-degree vertices.
"""
function intersect{T<:AGraphOrDiGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(min(gnv, hnv))
    for e in intersect(edges(g),edges(h))
        add_edge!(r,e)
    end
    return r
end

"""
    difference(g, h)

Produces a graph with edges in graph `g` that are not in graph `h`.

Note that this function may produce a graph with 0-degree vertices.
"""
function difference{T<:AGraphOrDiGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(gnv)
    for e in edges(g)
        !has_edge(h, e) && add_edge!(r,e)
    end
    return r
end

"""
    symmetric_difference(g, h)

Produces a graph with edges from graph `g` that do not exist in graph `h`,
and vice versa.

Note that this function may produce a graph with 0-degree vertices.
"""
function symmetric_difference{T<:AGraphOrDiGraph}(g::T, h::T)
    gnv = nv(g)
    hnv = nv(h)

    r = T(max(gnv, hnv))
    for e in edges(g)
        !has_edge(h, e) && add_edge!(r, e)
    end
    for e in edges(h)
        !has_edge(g, e) && add_edge!(r, e)
    end
    return r
end

"""
    join(g, h)

Merges graphs `g` and `h` using `blkdiag` and then adds all the edges between
 the vertices in `g` and those in `h`.
"""
function join(g::AGraph, h::AGraph)
    r = blkdiag(g, h)
    for i=1:nv(g)
        for j=nv(g)+1:nv(g)+nv(h)
            add_edge!(r, i, j)
        end
    end
    return r
end


"""
    crosspath(g::AGraph, n::Integer)

Replicate `n` times `g` and connect each vertex with its copies in a path.
"""
crosspath{G<:AGraph}(g::G, n) = cartesian_product(g, PathGraph(n, G))

"""
    cartesian_product(g, h)

Returns the (cartesian product)[https://en.wikipedia.org/wiki/Cartesian_product_of_graphs] of `g` and `h`
"""
function cartesian_product{G<:AGraphOrDiGraph}(g::G, h::G)
    z = G(nv(g) * nv(h))
    id(i, j) = i + (j-1) * nv(g)

    for j=1:nv(h)
        for (i1, i2) in edges(g)
            add_edge!(z, id(i1,j), id(i2,j))
        end
    end

    for (j1, j2) in edges(h)
        for i=1:nv(g)
            add_edge!(z, id(i,j1), id(i,j2))
        end
    end
    return z
end

"""
    tensor_product(g, h)

Returns the (tensor product)[https://en.wikipedia.org/wiki/Tensor_product_of_graphs] of `g` and `h`
"""
function tensor_product{G<:AGraphOrDiGraph}(g::G, h::G)
    z = G(nv(g)*nv(h))
    id(i, j) = i + (j-1)*nv(g)
    for (j1, j2) in edges(h)
        for (i1, i2) in edges(g)
            add_edge!(z, id(i1, j1), id(i2, j2))
        end
    end
    return z
end


## subgraphs ###

"""
    subgraph(g, vlist) -> sg, vlist
    subgraph(g, elist) -> sg, vlist


Returns the subgraph of `g` induced by the vertices in  `vlist` or by the edges
in `elist`, along with `vlist` itself (a newly created vector for the second method).

The returned graph has `length(vlist)` vertices, with the new vertex `i`
corresponding to the vertex of the original graph in the `i`-th position
of `vlist`.

For easy subgraph creation also `g[vlist]` or `g[elist]` can be used.

If `g` is a network, vector and edge properties won't be converved
`sg`. You can preserve properties using the [`subnetwork`](@ref) method.

### Usage Examples:
```julia
g = CompleteGraph(10)
sg, vlist = subgraph(g, 5:8)
@assert g[5:8] == sg
@assert nv(sg) == 4
@assert ne(sg) == 6
@assert vm[4] == 8

sg, vlist = subgraph(g, [2,8,3,4])
@asssert sg == g[[2,8,3,4]]

elist = [Edge(1,2), Edge(3,4), Edge(4,8)]
sg, vlist = subgraph(g, elist)
@asssert sg == g[elist]
```
"""
function subgraph{G<:AGraphOrDiGraph,V<:Integer}(g::G, vlist::AbstractVector{V})
    allunique(vlist) || error("Vertices in subgraph list must be unique")
    h = G(length(vlist))
    newvid = Dict{V, V}()
    for (i,v) in enumerate(vlist)
        newvid[v] = i
    end

    vset = Set(vlist)
    _build_subraph!(h, g, vset, newvid)

    return h, vlist
end


function _build_subraph!(h::AGraphOrDiGraph, g, vset, newvid)
    for s in vset
        for d in out_neighbors(g, s)
            d in vset && add_edge!(h, newvid[s], newvid[d])
        end
    end
end

function subgraph{G<:AGraphOrDiGraph}(g::G, elist)
    h = G()
    V = vertextype(h)
    newvid = Dict{V, V}()
    vlist = Vector{V}()

    for e in elist
        u, v = src(e), dst(e)
        for i in (u,v)
            if !haskey(newvid, i)
                add_vertex!(h)
                newvid[i] = nv(h)
                push!(vlist, i)
            end
        end
        add_edge!(h, newvid[u], newvid[v])
    end
    return h, vlist
end


"""
    subnetwork(g, vlist) -> sg, vlist
    subnetwork(g, elist) -> sg, vlist

Equivalent to [`subgraph`](@ref) but preserves vertex and edge properties
when `g` is a network.
"""

function subnetwork{G<:ANetOrDiNet,V<:Integer}(g::G, vlist::AbstractVector{V})
    allunique(vlist) || error("Vertices in subgraph list must be unique")
    h = G(length(vlist))
    newvid = Dict{V, V}()
    for (i,v) in enumerate(vlist)
        newvid[v] = i
    end

    vset = Set(vlist)
    _build_subnetwork!(h, g, vset, newvid)

    return h, vlist
end

function _build_subnetwork!(h::ANetOrDiNet, g, vset, newvid)
    #sound right not to copy graph properties of g
    for (name, prop) in vprop(g)
        vprop!(h, name, valtype(prop))
    end
    for (name, prop) in eprop(g)
        eprop!(h, name, valtype(prop))
    end

    for s in vset
        i = newvid[s]
        for (name, prop) in vprop(g)
            vprop(h, name)[i] = prop[s]
        end
        for e in out_edges(g, s)
            d = dst(e)
            if d in vset
                j = newvid[d]
                ok, enew = add_edge!(h, i, j)
                !ok && continue
                for (name, prop) in eprop(g)
                    eprop(h, name)[enew] = prop[e]
                end
            end
        end
    end
end


function subnetwork{G<:ANetOrDiNet}(g::G, elist)
    h = G()
    V = vertextype(h)
    newvid = Dict{V, V}()
    vlist = Vector{V}()

    for (name, prop) in vprop(g)
        vprop!(h, name, valtype(prop))
    end
    for (name, prop) in eprop(g)
        eprop!(h, name,  valtype(prop))
    end

    for e in elist
        u, v = src(e), dst(e)
        for s in (u,v)
            if !haskey(newvid, s)
                add_vertex!(h)
                newvid[s] = nv(h)
                push!(vlist, s)
                for (name, prop) in vprop(g)
                    vprop(h, name)[nv(h)] = prop[s]
                end
            end
        end
        ok, enew = add_edge!(h, newvid[u], newvid[v])
        !ok && continue
        for (name, prop) in eprop(g)
            eprop(h, name)[enew] = prop[e]
        end
    end
    return h, vlist
end


if VERSION >= v"0.6dev"
    """
        g[iter]

    Returns the subgraph induced by the vertex or edge iterable `iter`.
    Equivalent to [`subgraph`](@ref)`(g, iter)[1]` or [`subnetwork`](@ref)`(g, iter)[1]`
    for networks.
    """
    getindex(g::AGraphOrDiGraph, iter) = subnetwork(g, iter)[1]

    # in julia 0.5 always gets dispatched to this (julia bug)
    subnetwork(g::AGraphOrDiGraph, list) = subgraph(g, list)
else
    """
        g[iter]

    Returns the subgraph induced by the vertex or edge iterable `iter`.
    Equivalent to [`subgraph`](@ref)`(g, iter)[1]` or [`subnetwork`](@ref)`(g, iter)[1]`
    for networks.
    """
    getindex(g::AGraphOrDiGraph, iter) = subgraph(g, iter)[1]
    getindex(g::ANetOrDiNet, iter) = subnetwork(g, iter)[1]
end

"""
    egonet(g, v::Int, d::Int; dir=:out)

Returns the subgraph of `g` induced by the neighbors of `v` up to distance
`d`. If `g` is a `DiGraph` the `dir` optional argument specifies
the edge direction the edge direction with respect to `v` (i.e. `:in` or `:out`)
to be considered. This is equivalent to [`subgraph`](@ref)`(g, neighborhood(g, v, d, dir=dir))[1].`
"""
egonet(g::AGraphOrDiGraph, v::Integer, d::Integer; dir=:out) =  g[neighborhood(g, v, d, dir=dir)]


# The following operators allow one to use a Erdos.Graph as a matrix in
# eigensolvers for spectral ranking and partitioning.
# """Provides multiplication of a graph `g` by a vector `v` such that spectral
# graph functions in [GraphMatrices.jl](https://github.com/jpfairbanks/GraphMatrices.jl) can utilize Erdos natively.
# """
function *{T<:Number}(g::AGraph, v::Vector{T})
    length(v) == nv(g) || error("Vector size must equal number of vertices")
    y = zeros(T, nv(g))
    for e in edges(g)
        i = src(e)
        j = dst(e)
        y[i] += v[j]
        y[j] += v[i]
    end
    return y
end

function *{T<:Number}(g::ADiGraph, v::Vector{T})
    length(v) == nv(g) || error("Vector size must equal number of vertices")
    y = zeros(T, nv(g))
    for e in edges(g)
        i = src(e)
        j = dst(e)
        y[i] += v[j]
    end
    return y
end

"""sum(g,i) provides 1:in_degree or 2:out_degree vectors"""
function sum(g::AGraphOrDiGraph, dim::Int)
    dim == 1 && return in_degree(g, vertices(g))
    dim == 2 && return out_degree(g, vertices(g))
    error("Graphs are only two dimensional")
end


size(g::AGraphOrDiGraph) = (nv(g), nv(g))

"""size(g,i) provides 1:nv or 2:nv else 1 """
size(g::AGraph,dim::Int) = (dim == 1 || dim == 2)? nv(g) : 1

"""sum(g) provides the number of edges in the graph"""
sum(g::AGraphOrDiGraph) = ne(g)

"""
    sparse(g)

Equivalent to [`adjacency_matrix`](@ref).
"""
sparse(g::AGraphOrDiGraph) = adjacency_matrix(g)

#arrayfunctions = (:eltype, :length, :ndims, :size, :strides, :issymmetric)
eltype(g::AGraphOrDiGraph) = Float64
length(g::AGraphOrDiGraph) = nv(g)*nv(g)
ndims(g::AGraphOrDiGraph) = 2
issymmetric(g::AGraphOrDiGraph) = !is_directed(g)
