"""
    randomwalk(g, s, niter)

Performs a random walk on graph `g` starting at vertex `s` and continuing for
a maximum of `niter` steps. Returns a vector of vertices visited in order.
"""
function randomwalk(g::ASimpleGraph, s::Integer, niter::Integer)
  s in vertices(g) || throw(BoundsError())
  visited = Vector{Int}()
  sizehint!(visited, niter)
  currs = s
  i = 1
  while i <= niter
    push!(visited, currs)
    i += 1
    nbrs = out_neighbors(g,currs)
    length(nbrs) == 0 && break
    currs = myrand(nbrs)
  end
  return visited[1:i-1]
end

"""
    nonbacktracking_randomwalk(g, s, niter)

Performs a non-backtracking random walk on graph `g` starting at vertex `s` and continuing for
a maximum of `niter` steps. Returns a vector of vertices visited in order.
"""
function nonbacktracking_randomwalk(g::AGraph, s::Integer, niter::Integer)
    s in vertices(g) || throw(BoundsError())
    visited = Vector{Int}()
    sizehint!(visited, niter)
    currs = s
    prev = -1
    i = 1

    push!(visited, currs)
    i += 1
    nbrs = out_neighbors(g,currs)
    length(nbrs) == 0 && return visited[1:i-1]
    prev = currs
    currs = myrand(nbrs)

    while i <= niter
        push!(visited, currs)
        i += 1
        nbrs = out_neighbors(g,currs)
        length(nbrs) == 1 && break
        idnext = myrand(1:length(nbrs)-1)
        next = nth(nbrs, idnext)
        if next == prev
            next = nth(nbrs, length(nbrs))
        end
        prev = currs
        currs = next
    end
    return visited[1:i-1]
end

function nonbacktracking_randomwalk(g::ADiGraph, s::Integer, niter::Integer)
    s in vertices(g) || throw(BoundsError())
    visited = Vector{Int}()
    sizehint!(visited, niter)
    currs = s
    prev = -1
    i = 1

    while i <= niter
        push!(visited, currs)
        i += 1
        nbrs = out_neighbors(g,currs)
        length(nbrs) == 0 && break
        next = myrand(nbrs)
        if next == prev
            length(nbrs) == 1 && break
            idnext = myrand(1:length(nbrs)-1)
            next = nth(nbrs, idnext)
            if next == prev
                next = nth(nbrs, length(nbrs))
            end
        end
        prev = currs
        currs = next
    end
    return visited[1:i-1]
end

"""
    self_avoiding_randomwalk(g, s, niter)

Performs a [self-avoiding walk](https://en.wikipedia.org/wiki/Self-avoiding_walk)
on graph `g` starting at vertex `s` and continuing for a maximum of `niter` steps.
Returns a vector of vertices visited in order.
"""
function self_avoiding_randomwalk(g::ASimpleGraph, s::Integer, niter::Integer)
  s in vertices(g) || throw(BoundsError())
  visited = Vector{Int}()
  svisited = Set{Int}()
  sizehint!(visited, niter)
  sizehint!(svisited, niter)
  currs = s
  i = 1
  while i <= niter
    push!(visited, currs)
    push!(svisited, currs)
    i += 1
    nbrs = setdiff(Set(out_neighbors(g,currs)),svisited)
    length(nbrs) == 0 && break
    currs = rand(collect(nbrs))
  end
  return visited[1:i-1]
end
