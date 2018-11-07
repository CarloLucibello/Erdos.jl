struct EdgeIter{G<:AGraphOrDiGraph}
    g::G
end

#TODO implement iterate protocolo for real
iterate(it::EdgeIter{<:AGraphOrDiGraph}, i=start(it)) = done(it, i) ? nothing : next(it, i)

@inline function start(it::EdgeIter{G}) where G<:AGraph
    s = _start(it)
    while !_done(it, s)
        e, t = _next(it, s)
        if src(e) <= dst(e)
            return (false, e, t)
        end
        s = t
    end
    (true, edge(it.g, 1, 2), s)
end

@inline function next(it::EdgeIter{G}, st) where G<:AGraph
    _, e, s = st
    while !_done(it, s)
        w, t = _next(it, s)
        if src(w) <= dst(w)
            return e, (false, w, t)
        end
        s = t
    end
    e, (true, e, s)
end

@inline done(it::EdgeIter{G}, s) where {G<:AGraph} = s[1]

@inline start(it::EdgeIter{G}) where {G<:ADiGraph} = _start(it)
@inline next(it::EdgeIter{G}, s) where {G<:ADiGraph} = _next(it, s)
@inline done(it::EdgeIter{G}, s) where {G<:ADiGraph} = _done(it, s)

@inline function _start(it::EdgeIter)
    i = 1
    xs_state = 1
    while i <= nv(it.g)
        eit = out_edges(it.g, i)
        xs_state = Base.start(eit)
        !Base.done(eit, xs_state) && break
        i += 1
    end
    return i, xs_state
end

@inline function _next(it::EdgeIter, state)
    i, xs_state = state
    e, xs_state = Base.next(out_edges(it.g, i), xs_state)
    while Base.done(out_edges(it.g, i), xs_state)
        i += 1
        i > nv(it.g) && break
        xs_state = Base.start(out_edges(it.g, i))
    end
    return e, (i, xs_state)
end

@inline _done(it::EdgeIter, state) = state[1] > nv(it.g)

eltype(it::EdgeIter) = edgetype(it.g)
length(it::EdgeIter) = ne(it.g)
IteratorSize(::Type{EdgeIter}) = HasLength()


"""
    edges(g)

Returns an iterator to the edges of a graph `g`.
The returned iterator is invalidated by changes to `g`.
"""
edges(g::AGraphOrDiGraph) = EdgeIter(g)


## Simpler but slower with julia 0.5. Try again with future versions
# edges(g::ADiGraph) = nv(g) == 0 ? #julia issue #18852
#                 (edge(g, u, v) for u=1:1 for v=1:0) :
#                 (e for u=1:nv(g) for e in out_edges(g, u))
#
# edges(g::AGraph) = nv(g) == 0 ? #julia issue #18852
#                 (edge(g, u, v) for u=1:1 for v=1:0) :
#                 (e for u=1:nv(g) for e in out_edges(g, u) if src(e) <= dst(e))
#
# edges(g::ADiGraph, vs::AbstractVector) = length(vs) == 0 ? #julia issue #18852
#                 (edge(g, u, v) for u=1:1 for v=1:0) :
#                 (e for u in vs for e in out_edges(g, u) if dst(e) ∈ vs)
#
# edges(g::AGraph, vs::AbstractVector) = length(vs) == 0 ? #julia issue #18852
#                 (edge(g, u, v) for u=1:1 for v=1:0) :
#                 (e for u in vs for e in out_edges(g, u) if src(e) <= dst(e) && dst(e) ∈ vs)
