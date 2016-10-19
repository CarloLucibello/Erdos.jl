"""
    vertices(g)

Returns an iterator to the vertices of a graph (i.e. 1:nv(g))
"""
vertices(g::ASimpleGraph) = 1:nv(g)


"""
    adjlist(g)

Returns the adjacency list of a graph (a vector of vector of ints).
It is equivalent to  [`out_adjlist(g)`](@ref).

NOTE: For most graph types it returns a reference, not a copy,
therefore the returned object should not be modified.
"""
adjlist(g::ASimpleGraph) = out_adjlist(g)
in_adjlist(g::AGraph) = out_adjlist(g)

"""
    issubset(g, h)

Returns true if all of the vertices and edges of `g` are contained in `h`.
"""
function issubset{T<:ASimpleGraph}(g::T, h::T)
    return nv(g) < nv(h) && issubset(edges(g), edges(h))
end


"""
    add_vertices!(g, n)

Add `n` new vertices to the graph `g`. Returns the final number
of vertices.
"""
function add_vertices!(g::ASimpleGraph, n::Integer)
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
has_vertex(g::ASimpleGraph, v::Int) = v in vertices(g)

function show(io::IO, g::AGraph)
    if nv(g) == 0
        print(io, "empty undirected graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} undirected graph")
    end
end
function show(io::IO, g::ADiGraph)
    if nv(g) == 0
        print(io, "empty directed graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} directed graph")
    end
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
    indegree(g, v)

Returns the number of edges which start at vertex `v`.
"""
indegree(g::ASimpleGraph, v::Int) = length(in_neighbors(g,v))

"""
    outdegree(g, v)

Returns the number of edges which end at vertex `v`.
"""
outdegree(g::ASimpleGraph, v::Int) = length(out_neighbors(g,v))

"""
    degree(g, v)

Return the number of edges  from the vertex `v`.
"""
degree(g::ASimpleGraph, v::Int) = outdegree(g, v)

indegree(g::ASimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [indegree(g,x) for x in v]
outdegree(g::ASimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [outdegree(g,x) for x in v]
degree(g::ASimpleGraph, v::AbstractArray{Int,1} = vertices(g)) = [degree(g,x) for x in v]

"""
    neighbors(g, v)

Returns a list of all neighbors from vertex `v` in `g`.

For directed graph, this is equivalent to [`out_neighbors`](@ref)(g, v).

NOTE: it may return a reference, not a copy. Do not modify result.
"""
neighbors(g::ASimpleGraph, v::Int) = out_neighbors(g, v)
in_neighbors(g::AGraph, v::Int) = out_neighbors(g, v)

"""
    all_neighbors(g, v)

Iterates over all distinct in/out neighbors of vertex `v` in `g`.
"""
all_neighbors(g::AGraph, v::Int) = out_neighbors(g, v)

all_neighbors(g::ADiGraph, v::Int) =
    distinct(chain(out_neighbors(g, v), in_neighbors(g, v)))

"""
    density(g)

Density is defined as the ratio of the number of actual edges to the
number of possible edges. This is ``|v| |v-1|`` for directed graphs and
``(|v| |v-1|) / 2`` for undirected graphs.
"""
density(g::AGraph) = (2*ne(g)) / (nv(g) * (nv(g)-1))
density(g::ADiGraph) = ne(g) / (nv(g) * (nv(g)-1))


#### FALLBACKS #################
function =={G<:ASimpleGraph}(g::G, h::G)
    nv(g) != nv(h) && return false
    ne(g) != ne(h) && return false
    for i=1:nv(g)
        sort(out_neighbors(g, i)) != sort(out_neighbors(g, i)) && return false
    end
    return true
end


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
out_adjlist(g::ASimpleGraph) = Vector{Int}[collect(out_neighbors(g, i)) for i=1:nv(g)]


"""
    has_edge(g, e)
    has_edge(g, u, v)

Returns true if the graph `g` has an edge `e` (from `u` to `v`).
"""
function has_edge(g::AGraph, u::Int, v::Int)
    u > nv(g) || v > nv(g) && return false
    if degree(g, u) > degree(g, v)
        u, v = v, u
    end
    return findfirst(neighbors(g, u), v) > 0
end

function has_edge(g::ADiGraph, u::Int, v::Int)
    u > nv(g) || v > nv(g) && return false
    if degree(g, u) < degree(g, v)
        return findfirst(out_neighbors(g, u), v) > 0
    else
        return findfirst(in_neighbors(g, v), u) > 0
    end
end


"""
    in_edges(g, v)

Returns an iterator to the edges in `g` going to vertex `v`.
`v == dst(e)` for each returned edge `e`.
"""
in_edges(g::ASimpleGraph, v::Int) = (edge(g, x, v) for x in in_neighbors(g, v))

"""
    out_edges(g, v)

Returns an iterator to the edges in `g` coming from vertex `v`.
`v == src(e)` for each returned edge `e`.
"""
out_edges(g::ASimpleGraph, v::Int) = (edge(g, v, x) for x in out_neighbors(g, v))


#TODO define for abstract types
"""
    reverse(g::DiGraph)

Produces a graph where all edges are reversed from the
original.
"""
reverse(g::ADiGraph) = nothing


#TODO define for abstract types
"""
    reverse!(g::DiGraph)

In-place reverse (modifies the original graph).
"""
reverse!(g::ADiGraph) = nothing


### EDGE #################
has_edge(g::ASimpleGraph, e::Edge) = has_edge(g, src(e), dst(e))
add_edge!(g::ASimpleGraph, e::Edge) = add_edge!(g, src(e), dst(e))
rem_edge!(g::ASimpleGraph, e::Edge) = rem_edge!(g, src(e), dst(e))
