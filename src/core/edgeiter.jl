struct EdgeIter{G<:AGraphOrDiGraph}
    g::G
end

@inline function start{G<:AGraph}(it::EdgeIter{G})
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

@inline function next{G<:AGraph}(it::EdgeIter{G}, st)
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

@inline done{G<:AGraph}(it::EdgeIter{G}, s) = s[1]

@inline start{G<:ADiGraph}(it::EdgeIter{G}) = _start(it)
@inline next{G<:ADiGraph}(it::EdgeIter{G}, s) = _next(it, s)
@inline done{G<:ADiGraph}(it::EdgeIter{G}, s) = _done(it, s)

@inline function _start(it::EdgeIter)
    i = 1
    xs_state = 1
    while i <= nv(it.g)
        eit = out_edges(it.g, i)
        xs_state = start(eit)
        if !done(eit, xs_state)
            break
        end
        i += 1
    end
    return i, xs_state
end

@inline function _next(it::EdgeIter, state)
    i, xs_state = state
    e, xs_state = next(out_edges(it.g, i), xs_state)
    while done(out_edges(it.g, i), xs_state)
        i += 1
        if i > nv(it.g)
            break
        end
        xs_state = start(out_edges(it.g, i))
    end
    return e, (i, xs_state)
end

@inline _done(it::EdgeIter, state) = state[1] > nv(it.g)

eltype(it::EdgeIter) = edgetype(it.g)
length(it::EdgeIter) = ne(it.g)
iteratorsize(::Type{EdgeIter}) = HasLength()


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
