type PushRelabelHeap{V<:Integer,T<:Integer}
    data::MutableBinaryHeap{Pair{V,T},LessThan2}
    handles::Vector{V}

    function PushRelabelHeap(n)
        handles = zeros(V, n)
        data = MutableBinaryHeap{Pair{V,T},LessThan2}(LessThan2())
        return new(data, handles)
    end
end

function push!{V<:Integer,T<:Integer}(h::PushRelabelHeap{V,T}, k::V, v::T)
    a = push!(h.data, k=>v)
    h.handles[k] = a
end
push!{V,T}(h::PushRelabelHeap{V,T}, k::Integer, v::Integer) = push!(h, V(k), T(v))

function update!{V<:Integer,T<:Integer}(h::PushRelabelHeap{V,T}, k::V, v::T)
    a = h.handles[k]
    a > 0 && update!(h.data, a, k=>v)
end
update!{V<:Integer,T<:Integer}(h::PushRelabelHeap{V,T}, k::Integer, v::Integer) = update!(h, V(k), T(v))

function pop!(h::PushRelabelHeap)
    k = pop!(h.data)[1]
    h.handles[k] = 0
    return k
end

length(h::PushRelabelHeap) = length(h.data)

"""
Implementation of the push relabel algorithm with gap and highest excess heuristics.
Takes O(V²√E) time.

Maintains the following auxillary arrays:
- height -> Stores the labels of all vertices
- count  -> Stores the number of vertices at each height
- excess -> Stores the difference between incoming and outgoing flow for all vertices
- active -> Stores the status of all vertices. (e(v)>0 => active[v] = true)
- Q      -> The heap that stores active vertices waiting to be discharged.

Requires arguments:

- g::ADiGraph                # the input graph
- source                            # the source vertex
- target                            # the target vertex
- capacity_matrix::AbstractMatrix{T}    # edge flow capacities
"""
function push_relabel_impl{T<:Number}(
        g::ADiGraph,               # the input graph
        source,                           # the source vertex
        target,                           # the target vertex
        capacity_matrix::Vector{Vector{T}},   # edge flow capacities
        pos
    )

    n = nv(g)
    # flow_matrix = zeros(T, n, n)
    flow_matrix = deepcopy(capacity_matrix) # initialize flow matrix
    for i=1:n
        fill!(flow_matrix[i], 0)
    end
    height = zeros(Int, n)
    height[source] = n

    count = zeros(Int, 2*n+1)
    count[0+1] = n-1
    count[n+1] = 1

    excess = zeros(T, n)
    excess[source] = typemax(T)

    active = falses(n)
    active[source] = true
    active[target] = true

    Q = PushRelabelHeap{Int,Int}(n)

    for (k, u) in enumerate(neighbors(g, source))
        push_flow!(g, source, u, k, capacity_matrix, flow_matrix, excess, height, active, Q, pos)
    end

    while length(Q) > 0
        v = pop!(Q)
        active[v] = false
        discharge!(g, v, capacity_matrix, flow_matrix, excess, height, active, count, Q, pos)
    end

    flow = zero(T)
    for (k, j) in enumerate(neighbors(g, target))
        k2 = pos[target][k]
        flow += flow_matrix[j][k2]
    end
    # return sum([flow_matrix[v,target] for v in badj(g, target) ]), flow_matrix
    return flow, flow_matrix
end

"""
Pushes inactive nodes into the queue and activates them.

Requires arguments:

- Q::PushRelabelHeap
- v
- active::AbstractVector{Bool}
- excess::AbstractVector{T}
"""

function enqueue_vertex!{T<:Number}(
        Q::PushRelabelHeap,
        v,                                # input vertex
        active::AbstractVector{Bool},
        excess::Vector{T},
        height::Vector{Int})

    @inbounds if !active[v] && excess[v] > 0
        active[v] = true
        push!(Q, v, height[v])
    end
    return nothing
end

"""
Pushes as much flow as possible through the given edge.

Requires arguements:

- g::ADiGraph              # the input graph
- u                               # input from-vertex
- v                               # input to-vetex
- capacity_matrix::AbstractMatrix{T}
- flow_matrix::AbstractMatrix{T}
- excess::AbstractVector{T}
- height::AbstractVector{Int}
- active::AbstractVector{Bool}
- Q::PushRelabelHeap
"""
function push_flow!{T<:Number}(
        g::ADiGraph,             # the input graph
        u,                              # input from-vertex
        v,                                 # input to-vetex
        k,                                 #index of v as neig of u
        capacity_matrix,
        flow_matrix,
        excess::Vector{T},
        height::Vector{Int},
        active::AbstractVector{Bool},
        Q::PushRelabelHeap,
        pos
    )

    height[u] <= height[v] && return
    flow = min(excess[u], capacity_matrix[u][k] - flow_matrix[u][k])
    flow == 0 && return

    flow_matrix[u][k] += flow
    k2 = pos[u][k]
    flow_matrix[v][k2] -= flow

    excess[u] -= flow
    excess[v] += flow

    #no need to update u since it is not in heap
    # update!(Q, v, excess[v])

    enqueue_vertex!(Q, v, active, excess, height)
end

"""
Implements the gap heuristic. Relabels all vertices above a cutoff height.
Reduces the number of relabels required.

Requires arguments:

- g::ADiGraph                # the input graph
- h                                 # cutoff height
- excess::AbstractVector{T}
- height::AbstractVector{Int}
- active::AbstractVector{Bool}
- count::AbstractVector{Int}
- Q::PushRelabelHeap
"""
function gap!{T<:Number}(
        g::ADiGraph,               # the input graph
        h,                                # cutoff height
        excess::AbstractVector{T},
        height::AbstractVector{Int},
        active::AbstractVector{Bool},
        count::AbstractVector{Int},
        Q::PushRelabelHeap
    )

    n = nv(g)
    @inbounds for v in vertices(g)
        hv = height[v]
        hv < h && continue
        count[hv+1] -= 1
        hv = max(hv, n + 1)
        count[hv+1] += 1
        height[v] = hv
        update!(Q, v, height[v])
        enqueue_vertex!(Q, v, active, excess, height)
    end
end

"""
Relabels a vertex with respect to its neighbors, to produce an admissable
edge.

Requires arguments:

- g::ADiGraph                 # the input graph
- v                                  # input vertex to be relabeled
- capacity_matrix::AbstractMatrix{T}
- flow_matrix::AbstractMatrix{T}
- excess::AbstractVector{T}
- height::AbstractVector{Int}
- active::AbstractVector{Bool}
- count::AbstractVector{Int}
- Q::AbstractVector{Int}
"""

function relabel!{T<:Number}(
        g::ADiGraph,                # the input graph
        v,                                 # input vertex to be relabeled
        capacity_matrix,
        flow_matrix,
        excess::Vector{T},
        height::Vector{Int},
        active::AbstractVector{Bool},
        count::Vector{Int},
        Q::PushRelabelHeap
    )

    n = nv(g)
    count[height[v]+1] -= 1
    height[v] = 2*n
    @inbounds for (k,to) in enumerate(neighbors(g, v))
        if capacity_matrix[v][k] > flow_matrix[v][k]
            height[v] = min(height[v], height[to]+1)
        end
    end
    count[height[v]+1] += 1
    update!(Q, v, height[v]) #TODO remove since v is not in Q
    enqueue_vertex!(Q, v, active, excess, height)
end


"""
Drains the excess flow out of a vertex. Runs the gap heuristic or relabels the
vertex if the excess remains non-zero.

Requires arguments:

- g::ADiGraph                 # the input graph
- v                                  # vertex to be discharged
- capacity_matrix::AbstractMatrix{T}
- flow_matrix::AbstractMatrix{T}
- excess::AbstractVector{T}
- height::AbstractVector{Int}
- active::AbstractVector{Bool}
- count::AbstractVector{Int}
- Q::PushRelabelHeap
"""
function discharge!{T<:Number}(
        g::ADiGraph,                # the input graph
        v,                                 # vertex to be discharged
        capacity_matrix,
        flow_matrix,
        excess::Vector{T},
        height::Vector{Int},
        active::AbstractVector{Bool},
        count::Vector{Int},
        Q::PushRelabelHeap,
        pos
    )

    for (k, u) in enumerate(neighbors(g, v))
        excess[v] == 0 && break
        push_flow!(g, v, u, k, capacity_matrix, flow_matrix, excess, height, active, Q, pos)
    end

    if excess[v] > 0
        if count[height[v]+1] == 1
            gap!(g, height[v], excess, height, active, count, Q)
        else
            relabel!(g, v, capacity_matrix, flow_matrix, excess, height, active, count, Q)
        end
    end
end
