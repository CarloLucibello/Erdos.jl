abstract AEdge

show(io::IO, e::AEdge) = print(io, "$(src(e))=>$(dst(e))")

"""
    immutable Edge
        src::Int
        dst::Int
    end

A type representing an edge between two vertices of a graph.
"""
immutable Edge <: AEdge
    src::Int
    dst::Int
end

Edge(g::ASimpleGraph, u::Int, v::Int) = Edge(u, v)

"""
    src(e::Edge)

Returns the source of an edge.
"""
src(e::Edge) = e.src

"""
    dst(e::Edge)

Returns the destination of an edge.
"""
dst(e::Edge) = e.dst

"""
    is_ordered(e::Edge)

Returns  `src(e) <= dst(e)`.
"""
is_ordered(e::Edge) = src(e) <= dst(e)

==(e1::Edge, e2::Edge) = (src(e1) == src(e2) && dst(e1) == dst(e2))

start(e::Edge) = 1
done(e::Edge, i) = i>2
next(e::Edge, i) = (getfield(e,i), i+1)
indexed_next(e::Edge, i::Int, state) = (getfield(e,i), i+1)

"""
    reverse(e::Edge)

Swap `e.src` and `e.dst`.
"""
reverse(e::Edge) = Edge(dst(e), src(e))

"""
    sort(e::Edge)

Swap `src` and `dst` if `src > dst`.
"""
sort(e::Edge) = src(e) > dst(e) ? reverse(e) : e
