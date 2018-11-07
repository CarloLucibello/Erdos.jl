# Parts of this code were taken / derived from Graphs.jl. See LICENSE for
# licensing details.
"""
    connected_components!(label, g)

Fill `label` with the `id` of the connected component in the undirected graph
`g` to which it belongs. Return a vector representing the component assigned
to each vertex. The component value is the smallest vertex ID in the component.

### Performance
This algorithm is linear in the number of edges of the graph.
"""
function connected_components!(label::AbstractVector, g::AGraphOrDiGraph)
    nvg = nv(g)
    T = vertextype(g)
    for u in vertices(g)
        label[u] != zero(T) && continue
        label[u] = u
        Q = Vector{T}()
        push!(Q, u)
        while !isempty(Q)
            src = popfirst!(Q)
            for vertex in all_neighbors(g, src)
                if label[vertex] == zero(T)
                    push!(Q, vertex)
                    label[vertex] = u
                end
            end
        end
    end
    return label
end


"""
    components_dict(labels)

Convert an array of labels to a map of component id to vertices, and return
a map with each key corresponding to a given component id
and each value containing the vertices associated with that component.
"""
function components_dict(labels::Vector{T}) where T <: Integer
    d = Dict{T,Vector{T}}()
    for (v, l) in enumerate(labels)
        vec = get(d, l, Vector{T}())
        push!(vec, v)
        d[l] = vec
    end
    return d
end

"""
    components(labels)

Given a vector of component labels, return a vector of vectors representing the vertices associated
with a given component id.
"""
function components(labels::Vector{T}) where T <: Integer
    d = Dict{T,T}()
    c = Vector{Vector{T}}()
    i = one(T)
    for (v, l) in enumerate(labels)
        index = get!(d, l, i)
        if length(c) >= index
            push!(c[index], v)
        else
            push!(c, [v])
            i += 1
        end
    end
    return c, d
end

"""
    connected_components(g)

Return the [connected components](https://en.wikipedia.org/wiki/Connectivity_(graph_theory))
of an undirected graph `g` as a vector of components, with each element a vector of vertices
belonging to the component.

For directed graphs, see [`strongly_connected_components`](@ref) and
[`weakly_connected_components`](@ref).

# Examples
```jldoctest
julia> g = Graph([0 1 0; 1 0 1; 0 1 0]);

julia> connected_components(g)
1-element Array{Array{Int64,1},1}:
 [1, 2, 3]

julia> g = Graph([0 1 0 0 0; 1 0 1 0 0; 0 1 0 0 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> connected_components(g)
2-element Array{Array{Int64,1},1}:
 [1, 2, 3]
 [4, 5]
```
"""
function connected_components(g::AGraphOrDiGraph)
    T = vertextype(g)
    label = zeros(T, nv(g))
    connected_components!(label, g)
    c, d = components(label)
    return c
end

"""
    is_connected(g)

Return `true` if graph `g` is connected. For directed graphs, return `true`
if graph `g` is weakly connected.

# Examples
```jldoctest
julia> g = Graph([0 1 0; 1 0 1; 0 1 0]);

julia> is_connected(g)
true

julia> g = Graph([0 1 0 0 0; 1 0 1 0 0; 0 1 0 0 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> is_connected(g)
false

julia> g = DiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_connected(g)
true
```
"""
function is_connected(g::AGraphOrDiGraph)
    nv(g) <= 1 && return true
    mult = is_directed(g) ? 2 : 1
    return mult * ne(g) + 1 >= nv(g) && length(connected_components(g)) == 1
end

"""
    weakly_connected_components(g)

Return the weakly connected components of the graph `g`. This
is equivalent to the connected components of the undirected equivalent of `g`.
For undirected graphs this is equivalent to the [`connected_components`](@ref) of `g`.

# Examples
```jldoctest
julia> g = DiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> weakly_connected_components(g)
1-element Array{Array{Int64,1},1}:
 [1, 2, 3]
```
"""
weakly_connected_components(g) = connected_components(g)

"""
    is_weakly_connected(g)

Return `true` if the graph `g` is weakly connected. If `g` is undirected,
this function is equivalent to [`is_connected(g)`](@ref).

# Examples
```jldoctest
julia> g = DiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_weakly_connected(g)
true

julia> g = DiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> is_connected(g)
true

julia> is_strongly_connected(g)
false

julia> is_weakly_connected(g)
true
```
"""
is_weakly_connected(g) = is_connected(g)

"""
    strongly_connected_components(g)

Compute the strongly connected components of a directed graph `g`.

Return an array of arrays, each of which is the entire connected component.

### Implementation Notes
The order of the components is not part of the API contract.

# Examples
```jldoctest
julia> g = DiGraph([0 1 0; 1 0 1; 0 0 0]);

julia> strongly_connected_components(g)
2-element Array{Array{Int64,1},1}:
 [3]
 [1, 2]
```
"""
function strongly_connected_components(g::ADiGraph)
    T = vertextype(g)
    zero_t = zero(T)
    one_t = one(T)
    nvg = nv(g)
    count = one_t
    index = zeros(T, nvg)         # first time in which vertex is discovered
    stack = Vector{T}()           # stores vertices which have been discovered and not yet assigned to any component
    onstack = zeros(Bool, nvg)    # false if a vertex is waiting in the stack to receive a component assignment
    lowlink = zeros(T, nvg)       # lowest index vertex that it can reach through back edge (index array not vertex id number)
    parents = zeros(T, nvg)       # parent of every vertex in dfs
    components = Vector{Vector{T}}()    # maintains a list of scc (order is not guaranteed in API)
    sizehint!(stack, nvg)
    sizehint!(components, nvg)

    for s in vertices(g)
        if index[s] == zero_t
            index[s] = count
            lowlink[s] = count
            onstack[s] = true
            parents[s] = s
            push!(stack, s)
            count = count + one_t

            # start dfs from 's'
            dfs_stack = Vector{T}([s])
            while !isempty(dfs_stack)
                v = dfs_stack[end] #end is the most recently added item
                u = zero_t
                for n in out_neighbors(g, v)
                    if index[n] == zero_t
                        # unvisited neighbor found
                        u = n
                        break
                        #GOTO A push u onto DFS stack and continue DFS
                    elseif onstack[n]
                        # we have already seen n, but can update the lowlink of v
                        # which has the effect of possibly keeping v on the stack until n is ready to pop.
                        # update lowest index 'v' can reach through out neighbors
                        lowlink[v] = min(lowlink[v], index[n])
                    end
                end
                if u == zero_t
                    # All out neighbors already visited or no out neighbors
                    # we have fully explored the DFS tree from v.
                    # time to start popping.
                    popped = pop!(dfs_stack)
                    lowlink[parents[popped]] = min(lowlink[parents[popped]], lowlink[popped])
                    if index[v] == lowlink[v]
                        # found a cycle in a completed dfs tree.
                        component = Vector{T}()
                        sizehint!(component, length(stack))
                        while !isempty(stack) #break when popped == v
                            # drain stack until we see v.
                            # everything on the stack until we see v is in the SCC rooted at v.
                            popped = pop!(stack)
                            push!(component, popped)
                            onstack[popped] = false
                            # popped has been assigned a component, so we will never see it again.
                            if popped == v
                                # we have drained the stack of an entire component.
                                break
                            end
                        end
                        push!(components, reverse(component))
                    end
                else #LABEL A
                    # add unvisited neighbor to dfs
                    index[u] = count
                    lowlink[u] = count
                    onstack[u] = true
                    parents[u] = v
                    count = count + one_t
                    push!(stack, u)
                    push!(dfs_stack, u)
                    # next iteration of while loop will expand the DFS tree from u.
                end
            end
        end
    end

    return components
end


"""
    is_strongly_connected(g)

Return `true` if directed graph `g` is strongly connected.

# Examples
```jldoctest
julia> g = DiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> is_strongly_connected(g)
true
```
"""
is_strongly_connected(g::ADiGraph) = length(strongly_connected_components(g)) == 1

"""
    period(g)

Return the (common) period for all vertices in a strongly connected directed graph.
Will throw an error if the graph is not strongly connected.

# Examples
```jldoctest
julia> g = DiGraph([0 1 0; 0 0 1; 1 0 0]);

julia> period(g)
3
```
"""
function period(g::ADiGraph)
    !is_strongly_connected(g) && throw(ArgumentError("Graph must be strongly connected"))

    # First check if there's a self loop
    has_self_loops(g) && return 1

    g_bfs_tree  = bfs_tree(g, 1)
    levels      = gdistances(g_bfs_tree, 1)
    tree_diff   = difference(g, g_bfs_tree)
    T = vertextype(g)
    edge_values = Vector{T}()

    divisor = 0
    for e in edges(tree_diff)
        @inbounds value = levels[src(e)] - levels[dst(e)] + 1
        divisor = gcd(divisor, value)
        isequal(divisor, 1) && return 1
    end

    return divisor
end

"""
    condensation(g[, scc])

Return the condensation graph of the strongly connected components `scc`
in the directed graph `g`. If `scc` is missing, generate the strongly
connected components first.

# Examples
```jldoctest
julia> g = DiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0])
{5, 6} directed simple Int64 graph

julia> strongly_connected_components(g)
2-element Array{Array{Int64,1},1}:
 [4, 5]
 [1, 2, 3]

julia> foreach(println, edges(condensation(g)))
Edge 2 => 1
```
"""
function condensation(g::G, scc::Vector{Vector{T}}) where {T <: Integer,
                                                           G <: ADiGraph}

    h = G(length(scc))

    component = Vector{T}(undef, nv(g))

    for (i, s) in enumerate(scc)
        @inbounds component[s] .= i
    end

    @inbounds for e in edges(g)
        s, d = component[src(e)], component[dst(e)]
        if (s != d)
            add_edge!(h, s, d)
        end
    end
    return h
end
condensation(g::ADiGraph) = condensation(g, strongly_connected_components(g))

"""
    attracting_components(g)

Return a vector of vectors of integers representing lists of attracting
components in the directed graph `g`.

The attracting components are a subset of the strongly
connected components in which the components do not have any leaving edges.

# Examples
```jldoctest
julia> g = SimpleDiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0])
{5, 6} directed simple Int64 graph

julia> strongly_connected_components(g)
2-element Array{Array{Int64,1},1}:
 [4, 5]
 [1, 2, 3]

julia> attracting_components(g)
1-element Array{Array{Int64,1},1}:
 [4, 5]
```
"""
function attracting_components(g::ADiGraph)
    scc  = strongly_connected_components(g)
    cond = condensation(g, scc)
    T = vertextype(g)
    attracting = Vector{T}()

    for v in vertices(cond)
        if out_degree(cond, v) == 0
            push!(attracting, v)
        end
    end
    return scc[attracting]
end

"""
    neighborhood(g, v, d, distmx=weights(g); dir=:out)
    

Return a vector of each vertex in `g` at a geodesic distance less than or equal to `d`, where distances
may be specified by `distmx`. 

### Optional Arguments
- `dir=:out`: If `g` is directed, this argument specifies the edge direction
with respect to `v` of the edges to be considered. Possible values: `:in` or `:out`.

# Examples
```jldoctest
julia> g = DiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> neighborhood(g, 1, 2)
3-element Array{Int64,1}:
 1
 2
 3

julia> neighborhood(g, 1, 3)
4-element Array{Int64,1}:
 1
 2
 3
 4

julia> neighborhood(g, 1, 3, [0 1 0 0 0; 0 0 1 0 0; 1 0 0 0.25 0; 0 0 0 0 0.25; 0 0 0 0.25 0])
5-element Array{Int64,1}:
 1
 2
 3
 4
 5
```
"""
function neighborhood(g::AGraphOrDiGraph, v::Integer, d, 
                    distmx=weights(g); dir=:out)
    first.(neighborhood_dists(g, v, d, distmx; dir=dir))
end

"""
    neighborhood_dists(g, v, d, distmx=weights(g))

Return a tuple of each vertex at a geodesic distance less than or equal to `d`, where distances
may be specified by `distmx`, along with its distance from `v`.

### Optional Arguments
- `dir=:out`: If `g` is directed, this argument specifies the edge direction
with respect to `v` of the edges to be considered. Possible values: `:in` or `:out`.

# Examples
```jldoctest
julia> g = DiGraph([0 1 0 0 0; 0 0 1 0 0; 1 0 0 1 0; 0 0 0 0 1; 0 0 0 1 0]);

julia> neighborhood_dists(g, 1, 3)
4-element Array{Tuple{Int64,Int64},1}:
 (1, 0)
 (2, 1)
 (3, 2)
 (4, 3)

julia> neighborhood_dists(g, 1, 3, [0 1 0 0 0; 0 0 1 0 0; 1 0 0 0.25 0; 0 0 0 0 0.25; 0 0 0 0.25 0])
5-element Array{Tuple{Int64,Float64},1}:
 (1, 0.0)
 (2, 1.0)
 (3, 2.0)
 (4, 2.25)
 (5, 2.5)

julia> neighborhood_dists(g, 4, 3)
2-element Array{Tuple{Int64,Int64},1}:
 (4, 0)
 (5, 1)

julia> neighborhood_dists(g, 4, 3, dir=:in)
5-element Array{Tuple{Int64,Int64},1}:
 (4, 0)
 (3, 1)
 (5, 1)
 (2, 2)
 (1, 3)
```
"""
function neighborhood_dists(g::AGraphOrDiGraph, v::Integer, d, 
                distmx::AEdgeMap=weights(g); dir=:out) where U <: Real

    (dir == :out) ? _neighborhood(g, v, d, distmx, out_neighbors) :
                    _neighborhood(g, v, d, distmx, in_neighbors)
end                


function _neighborhood(g::AGraphOrDiGraph, v::Integer, d::Real, distmx::AEdgeMap{U}, neighborfn::Function) where U
    T = vertextype(g)
    d < 0 && return Vector{Tuple{T,U}}()
    neighs = Vector{T}()
    push!(neighs, v)
    Q = Vector{T}()
    push!(Q, v)
    seen = falses(nv(g))
    dists = fill(typemax(U), nv(g))
    dists[v] = zero(U)
    while !isempty(Q)
        src = popfirst!(Q)
        seen[src] && continue
        seen[src] = true
        currdist = dists[src]
        vertexneighbors = neighborfn(g, src)
        @inbounds for vertex in vertexneighbors
            if !seen[vertex] 
                vdist = currdist + distmx[src, vertex]
                if vdist <= d
                    push!(Q, vertex)
                    push!(neighs, vertex)
                    dists[vertex] = vdist
                end
            end
        end
    end
    return [(x::T, dists[x]::U) for x in neighs]
end

"""
    isgraphical(degs)

Return true if the degree sequence `degs` is graphical, according to
[Erdös-Gallai condition](http://mathworld.wolfram.com/GraphicSequence.html).

### Performance
    Time complexity: ``\\mathcal{O}(|degs|^2)``
"""
function isgraphical(degs::Vector{Int})
    iseven(sum(degs)) || return false
    n = length(degs)
    for r = 1:(n - 1)
        cond = sum(i -> degs[i], 1:r) <= r * (r - 1) + sum(i -> min(r, degs[i]), (r + 1):n)
        cond || return false
    end
    return true
end