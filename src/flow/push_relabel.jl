immutable GreaterThan2
end

type PushRelabelHeap{T}
    data::MutableBinaryHeap{Pair{Int,T},GreaterThan2}
    handles::Vector{Int}

    function PushRelabelHeap(N::Int)
        handles = zeros(Int, N)
        data = MutableBinaryHeap{Pair{Int,T},GreaterThan2}(GreaterThan2())
        return new(data, handles)
    end
end


function push!(h::PushRelabelHeap, k::Int, v)
    a = push!(h.data, k=>v)
    h.handles[k] = a
end

function update!(h::PushRelabelHeap, k::Int, v)
    a = h.handles[k]
    a > 0 && update!(h.data, a, k=>v)
end

function pop!(h::PushRelabelHeap)
    k = pop!(h.data)[1]
    h.handles[k] = 0
    return k
end

length(h::PushRelabelHeap) = length(h.data)

compare(c::GreaterThan2, x, y) = x[2] > y[2]

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
- source::Int                            # the source vertex
- target::Int                            # the target vertex
- capacity_matrix::AbstractArray{T,2}    # edge flow capacities
"""
function push_relabel{T<:Number}(
        g::ADiGraph,               # the input graph
        source::Int,                           # the source vertex
        target::Int,                           # the target vertex
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

    Q = PushRelabelHeap{T}(n)

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
- v::Int
- active::AbstractArray{Bool,1}
- excess::AbstractArray{T,1}
"""

function enqueue_vertex!{T<:Number}(
        Q::PushRelabelHeap,
        v::Int,                                # input vertex
        active::AbstractVector{Bool},
        excess::Vector{T})

    @inbounds if !active[v] && excess[v] > 0
        active[v] = true
        push!(Q, v, excess[v])
    end
    return nothing
end

"""
Pushes as much flow as possible through the given edge.

Requires arguements:

- g::ADiGraph              # the input graph
- u::Int                               # input from-vertex
- v::Int                               # input to-vetex
- capacity_matrix::AbstractArray{T,2}
- flow_matrix::AbstractArray{T,2}
- excess::AbstractArray{T,1}
- height::AbstractArray{Int,1}
- active::AbstractArray{Bool,1}
- Q::PushRelabelHeap
"""

function push_flow!{T<:Number}(
        g::ADiGraph,             # the input graph
        u::Int,                              # input from-vertex
        v::Int,                                 # input to-vetex
        k::Int,                                 #index of v as neig of u
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
    update!(Q, v, excess[v])

    enqueue_vertex!(Q, v, active, excess)
end

"""
Implements the gap heuristic. Relabels all vertices above a cutoff height.
Reduces the number of relabels required.

Requires arguments:

- g::ADiGraph                # the input graph
- h::Int                                 # cutoff height
- excess::AbstractArray{T,1}
- height::AbstractArray{Int,1}
- active::AbstractArray{Bool,1}
- count::AbstractArray{Int,1}
- Q::PushRelabelHeap
"""

function gap!{T<:Number}(
        g::ADiGraph,               # the input graph
        h::Int,                                # cutoff height
        excess::AbstractArray{T,1},
        height::AbstractArray{Int,1},
        active::AbstractArray{Bool,1},
        count::AbstractArray{Int,1},
        Q::PushRelabelHeap
    )

    n = nv(g)
    @inbounds for v in vertices(g)
        height[v] < h && continue
        count[height[v]+1] -= 1
        height[v] = max(height[v], n + 1)
        count[height[v]+1] += 1
        enqueue_vertex!(Q, v, active, excess)
    end
end

"""
Relabels a vertex with respect to its neighbors, to produce an admissable
edge.

Requires arguments:

- g::ADiGraph                 # the input graph
- v::Int                                  # input vertex to be relabeled
- capacity_matrix::AbstractArray{T,2}
- flow_matrix::AbstractArray{T,2}
- excess::AbstractArray{T,1}
- height::AbstractArray{Int,1}
- active::AbstractArray{Bool,1}
- count::AbstractArray{Int,1}
- Q::AbstractArray{Int,1}
"""

function relabel!{T<:Number}(
        g::ADiGraph,                # the input graph
        v::Int,                                 # input vertex to be relabeled
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
    enqueue_vertex!(Q, v, active, excess)
end


"""
Drains the excess flow out of a vertex. Runs the gap heuristic or relabels the
vertex if the excess remains non-zero.

Requires arguments:

- g::ADiGraph                 # the input graph
- v::Int                                  # vertex to be discharged
- capacity_matrix::AbstractArray{T,2}
- flow_matrix::AbstractArray{T,2}
- excess::AbstractArray{T,1}
- height::AbstractArray{Int,1}
- active::AbstractArray{Bool,1}
- count::AbstractArray{Int,1}
- Q::PushRelabelHeap
"""
function discharge!{T<:Number}(
        g::ADiGraph,                # the input graph
        v::Int,                                 # vertex to be discharged
        capacity_matrix,
        flow_matrix,
        excess::Vector{T},
        height::Vector{Int},
        active::AbstractArray{Bool,1},
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
