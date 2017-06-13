"""
    vertices(g)

Returns an iterator to the vertices of a graph (i.e. 1:nv(g))
"""
vertices(g::AGraphOrDiGraph) = 1:nv(g)

"""
    adjacency_list(g::AGraph)
    adjacency_list(g::ADiGraph, dir=:out)

Returns the adjacency list `a` of a graph (a vector of vector of ints). The `i`-th
element of the adjacency list is a vector containing the neighbors of `i` in `g`.

For directed graphs a second optional argument can be specified (`:out` or `:in`).
The neighbors in the returned adjacency list are considered accordingly as those
related through outgoing or incoming edges.

The elements of  `a[i]` have the same order as in the iterator `(out_/in_)neighbors(g,i)`.

*Attention*: For some graph types it returns a reference, not a copy,
therefore the returned object should not be modified.
"""
adjacency_list(g::AGraph) = out_adjlist(g)
adjacency_list(g::ADiGraph, dir=:out) = dir == :out ? out_adjlist(g) :
                                        dir == :in ? in_adjlist(g) :
                                        error("Second argument has to be :out or :in.")

"""
    add_vertices!(g, n)

Add `n` new vertices to the graph `g`. Returns the final number
of vertices.
"""
function add_vertices!(g::AGraphOrDiGraph, n)
    added = true
    for i = 1:n
        add_vertex!(g)
    end
    return nv(g)
end

"""
    has_vertex(g, v)

Return true if `v` is a vertex of `g`.
"""
has_vertex(g::AGraphOrDiGraph, v) = v in vertices(g)


show(io::IO, g::AGraphOrDiGraph) = shortshow(io, g)
show(io::IO, g::ANetOrDiNet) = longshow(io, g)

function shortshow{G<:AGraphOrDiGraph}(io::IO, g::G)
    print(io, split("$G",'.')[end],
        "($(nv(g)), $(ne(g)))")
        # is_directed(g) ? " undirected graph" : " directed graph")
end


function longshow{G<:ANetOrDiNet}(io::IO, g::G)
    print(io, split("$G",'.')[end], "($(nv(g)), $(ne(g)))")
    print(io, " with ")
    _printstrvec(io, gprop_names(g))
    print(io, " graph, ")
    _printstrvec(io, vprop_names(g))
    print(io," vertex, ")
    _printstrvec(io, eprop_names(g))
    print(io, " edge properties")
end

function _printstrvec(io::IO, vs::Vector{String})
    print(io,"[")
    if length(vs) > 0
        for s in vs[1:end-1]
            print(io, "\"" * s * "\", ")
        end
        print(io, "\"" * last(vs) * "\"")
    end
    print(io,"]")
end


"""
    is_directed(g)

Check if `g` a graph with directed edges.
"""
is_directed(g::AGraph) = false
is_directed(g::ADiGraph) = true
is_directed{G<:AGraph}(::Type{G}) = false
is_directed{G<:ADiGraph}(::Type{G}) = true

"""
    in_degree(g, v)

Returns the number of edges which start at vertex `v`.
"""
in_degree(g::AGraphOrDiGraph, v) = length(in_neighbors(g,v))

"""
    out_degree(g, v)

Returns the number of edges which end at vertex `v`.
"""
out_degree(g::AGraphOrDiGraph, v) = length(out_neighbors(g,v))

"""
    degree(g, v)

Return the number of edges  from the vertex `v`.
"""
degree(g::AGraphOrDiGraph, v) = out_degree(g, v)

in_degree(g::AGraphOrDiGraph, v::AbstractVector{Int} = vertices(g)) = [in_degree(g,x) for x in v]
out_degree(g::AGraphOrDiGraph, v::AbstractVector{Int} = vertices(g)) = [out_degree(g,x) for x in v]
degree(g::AGraphOrDiGraph, v::AbstractVector{Int} = vertices(g)) = [degree(g,x) for x in v]

"""
    neighbors(g, v)

Returns a list of all neighbors from vertex `v` in `g`.

For directed graph, this is equivalent to [`out_neighbors`](@ref)(g, v).

NOTE: it may return a reference, not a copy. Do not modify result.
"""
neighbors(g::AGraphOrDiGraph, v) = out_neighbors(g, v)
in_neighbors(g::AGraph, v) = out_neighbors(g, v)

"""
    all_neighbors(g, v)

Iterates over all distinct in/out neighbors of vertex `v` in `g`.
"""
all_neighbors(g::AGraph, v) = out_neighbors(g, v)

all_neighbors(g::ADiGraph, v) =
    distinct(chain(out_neighbors(g, v), in_neighbors(g, v)))

"""
    density(g)

Density is defined as the ratio of the number of actual edges to the
number of possible edges. This is ``|v| |v-1|`` for directed graphs and
``(|v| |v-1|) / 2`` for undirected graphs.
"""
density(g::AGraph) = (2*ne(g)) / (nv(g) * (nv(g)-1))
density(g::ADiGraph) = ne(g) / (nv(g) * (nv(g)-1))

"""
    clean_vertex!(g, v)

Remove all incident edges on vertex `v` in `g`.
"""
function clean_vertex!(g::AGraphOrDiGraph, v)
    edgs = collect(all_edges(g, v))
    for e in edgs
        rem_edge!(g, e)
    end
end

copy(g::AGraphOrDiGraph) = deepcopy(g)

graphtype{G<:AGraph}(::Type{G}) = G
digraphtype{G<:ADiGraph}(::Type{G}) = G

edgetype{G<:AGraphOrDiGraph}(g::G) = edgetype(G)
graphtype{G<:AGraphOrDiGraph}(g::G) = graphtype(G)
digraphtype{G<:AGraphOrDiGraph}(g::G) = digraphtype(G)
vertextype{G<:AGraphOrDiGraph}(g::G) = vertextype(G)


graph(g::AGraph) = g
digraph(g::ADiGraph) = g

#### FALLBACKS #################

function (::Type{G}){G<:ADiGraph, T<:Number}(adjmx::AbstractMatrix{T}
        ; selfedges=true)
    op =  selfedges ? ((x,y) -> true)  : (!=)
    return _graph_from_matr!(G, op, adjmx)
end

function (::Type{G}){G<:AGraph, T<:Number}(adjmx::AbstractMatrix{T}
        ; upper=false, selfedges=true)

  op =  upper && !selfedges  ? (<) :
        upper && selfedges   ? (<=)  :
        !upper && !selfedges ? (!=) : ((x,y) -> true)

  return _graph_from_matr!(G, op, adjmx)
end

function _graph_from_matr!(G, op, adjmx::AbstractMatrix)
    n, m = size(adjmx)
    n == m || error("Adjacency / distance matrices must be square")
    g = G(n)
    for i in eachindex(adjmx)
        adjmx[i] == 0 && continue
        u, v = ind2sub(adjmx, i)
        op(u,v) || continue
        add_edge!(g, u, v)
    end
    return g
end

function _graph_from_matr!(G, op, adjmx::SparseMatrixCSC)
    n, m = size(adjmx)
    n == m || error("Adjacency / distance matrices must be square")
    g = G(n)
    rows = rowvals(adjmx)
    for v=1:n
        for j in nzrange(adjmx, v)
           u = rows[j]
           op(u,v) || continue
           add_edge!(g, u, v)
        end
    end
    return g
end

function digraph(g::AGraph)
    G = digraphtype(g)
    h = G(nv(g))
    for e in edges(g)
        add_edge!(h, src(e), dst(e))
        add_edge!(h, dst(e), src(e))
    end
    return h
end

function graph(g::ADiGraph)
    G = graphtype(g)
    h = G(nv(g))
    for e in edges(g)
        add_edge!(h, src(e), dst(e))
    end
    return h
end

function =={G<:AGraphOrDiGraph}(g::G, h::G)
    nv(g) != nv(h) && return false
    ne(g) != ne(h) && return false
    for i=1:nv(g)
        if sort(collect(out_neighbors(g, i))) != sort(collect(out_neighbors(h, i)))
            return false
        end
    end
    return true
end


#not exported
"""
    in_adjlist(g)

Returns the backward adjacency list of a graph.
For each vertex the vector of neighbors though incoming edges.

    in_adjlist(g) == [collect(in_neighbors(i)) for i=1:nv(g)]

It is the same as [`adjlist`](@ref) and [`out_adjlist`](@ref) for
undirected graphs.


NOTE: returns a reference, not a copy. Do not modify result.
"""
in_adjlist(g::ADiGraph) = Vector{Int}[collect(in_neighbors(g, i)) for i=1:nv(g)]

#not exported
"""
    out_adjlist(g)

Returns the forward adjacency list of a graph, i.e. a vector of vectors
containing for each vertex the neighbors trhough outgoing edges.

    out_adjlist(g) == [collect(out_neighbors(i)) for i=1:nv(g)]

The adjacency list is be pre-calculated for most graph types.
It is the same as [`adjlist`](@ref) and [`in_adjlist`](@ref) for
undirected graphs and the same as [`adjlist`](@ref) for directed ones.

NOTE: It may return a reference, not a copy. Do not modify result.

"""
out_adjlist(g::AGraphOrDiGraph) = Vector{Int}[collect(out_neighbors(g, i)) for i=1:nv(g)]


"""
    has_edge(g, e)
    has_edge(g, u, v)

Returns true if the graph `g` has an edge `e` (from `u` to `v`).
"""
function has_edge(g::AGraph, u, v)
    u > nv(g) || v > nv(g) && return false
    if degree(g, u) > degree(g, v)
        u, v = v, u
    end
    return v ∈ neighbors(g, u)
end

function has_edge(g::ADiGraph, u, v)
    (u > nv(g) || v > nv(g)) && return false
    if out_degree(g, u) < in_degree(g, v)
        return v ∈ out_neighbors(g, u)
    else
        return u ∈ in_neighbors(g, v)
    end
end

"""
    in_edges(g, v)

Returns an iterator to the edges in `g` going to vertex `v`.
`v == dst(e)` for each returned edge `e`.
"""
in_edges(g::AGraphOrDiGraph, v) = (edge(g, x, v) for x in in_neighbors(g, v))

"""
    out_edges(g, v)

Returns an iterator to the edges in `g` coming from vertex `v`.
`v == src(e)` for each returned edge `e`.
"""
out_edges(g::AGraphOrDiGraph, v) = (edge(g, v, x) for x in out_neighbors(g, v))

"""
    edges(g, v)

Returns an iterator to the edges in `g` coming from vertex `v`.
`v == src(e)` for each returned edge `e`.

It is equivalent to [`out_edges`](@ref).

For digraphs, use [`all_edges`](@ref) to iterate over
both in and out edges.
"""
edges(g::AGraphOrDiGraph, v) = out_edges(g, v)

"""
    all_edges(g, v)

Iterates over all in and out edges of vertex `v` in `g`.
"""
all_edges(g::AGraph, v) = out_edges(g, v)
all_edges(g::ADiGraph, v) = chain(out_edges(g, v), in_edges(g, v))
#TODO fix chain eltype, since collect gives Any[...]

"""
    reverse(g::ADiGraph)

Produces a graph where all edges are reversed from the
original.
"""
function reverse{G<:ADiGraph}(g::G)
    h = G(nv(g))
    for e in edges(g)
        add_edge!(h, reverse(e))
    end
    return h
end

"""
    reverse!(g::DiGraph)

In-place reverse (modifies the original graph).
"""
reverse!(g::ADiGraph) = nothing

add_edge!(g::AGraphOrDiGraph, e::AEdge) = add_edge!(g, src(e), dst(e))
rem_edge!(g::AGraphOrDiGraph, e::AEdge) = rem_edge!(g, src(e), dst(e))
has_edge(g::AGraphOrDiGraph, e::AEdge) = has_edge(g, src(e), dst(e))

"""
    unsafe_add_edge!(g, u, v)

Possibly faster and unsafer version of [`add_edge!`](@ref), which doesn't guarantee
some graph invariant properties.

For example, some graph types (e.g. `Graph`) assume sorted adjacency lists as members.
In this case order is not preserved while inserting new edges, resulting in a
faster construction of the graph. As a consequence though, some functions such
`has_edge(g, u, v)` could give incorrect results.

To restore the correct behaviour, call [`rebuild!`](@ref)(g) after the last
call to `unsafe_add_edge!`.
"""
unsafe_add_edge!(g::AGraphOrDiGraph, u, v) = add_edge!(g, u, v)
unsafe_add_edge!(g::AGraphOrDiGraph, e::AEdge) = unsafe_add_edge!(g, src(e), dst(e))

"""
    rebuild!(g)

Check and restore the structure of `g`, which could be corrupted by the
use of unsafe functions (e. g. [`unsafe_add_edge!`](@ref))
"""
rebuild!(g::AGraphOrDiGraph) = nothing

"""
    rem_vertex!(g, v)

Remove the vertex `v` from graph `g`.
It will change the label of the last vertex of the old graph to `v`.

See also [`rem_vertices!`](@ref)
"""
function rem_vertex!(g::AGraphOrDiGraph, v)
    v in vertices(g) || return false
    clean_vertex!(g, v)
    swap_vertices!(g, v, nv(g))
    pop_vertex!(g)
    return true
end


"""
    rem_vertex!(g, vs)

Remove the vertices in `vs` from graph `g`.
Returns a vector mapping the vertices in the new graph to the
old ones.
"""
function rem_vertices!(g::AGraphOrDiGraph, vs)
    vlist = sort(union(vs))
    n = nv(g)
    nrem = length(vlist)
    vmap = [1:n-nrem;]
    vswap = n-nrem+1
    for v in vlist
        @assert 1 <= v <= n
        if v <= n-nrem
            while vswap in vlist
                vswap += 1
            end
            @assert vswap <= n
            clean_vertex!(g, v)
            vmap[v] = vswap
            vswap += 1
        end
    end

    for v in vs
        if v <= n-nrem
            swap_vertices!(g, v, vmap[v])
        end
    end
    for i=1:nrem
        pop_vertex!(g)
    end
    return vmap
end
