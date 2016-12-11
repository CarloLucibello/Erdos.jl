"""
Abstract type that allows users to pass in their preferred Algorithm
"""
abstract AbstractFlowAlgorithm

"""
Forces the maximum_flow function to use the Edmonds–Karp algorithm.
"""
type EdmondsKarpAlgorithm <: AbstractFlowAlgorithm
end

"""
Forces the maximum_flow function to use Dinic\'s algorithm.
"""
type DinicAlgorithm <: AbstractFlowAlgorithm
end

"""
Forces the maximum_flow function to use the Boykov-Kolmogorov algorithm.
"""
type BoykovKolmogorovAlgorithm <: AbstractFlowAlgorithm
end

"""
Forces the maximum_flow function to use the Push-Relabel algorithm.
"""
type PushRelabelAlgorithm <: AbstractFlowAlgorithm
end

"""
Type that returns 1 if a forward edge exists, and 0 otherwise
"""

type DefaultCapacity{G<:ADiGraph} <: AbstractMatrix{Int}
    flow_graph::G
    nv::Int
end
DefaultCapacity{G<:ADiGraph}(g::G) = DefaultCapacity(g, nv(g))

getindex(d::DefaultCapacity, s::Int, t::Int) = has_edge(d.flow_graph, s , t) ? 1 : 0
size(d::DefaultCapacity) = (d.nv, d.nv)
transpose(d::DefaultCapacity) = DefaultCapacity(reverse(d.flow_graph))
ctranspose(d::DefaultCapacity) = DefaultCapacity(reverse(d.flow_graph))

"""
Constructs a residual graph for the input flow graph. Creates a new graph instead
of modifying the input flow graph.

The residual graph comprises of the same Vertex list, but ensures that for each
edge (u,v), (v,u) also exists in the graph. (to allow flow in the reverse direction).

If only the forward edge exists, a reverse edge is created with capacity 0. If both
forward and reverse edges exist, their capacities are left unchanged. Since the capacities
in DefaultDistance cannot be changed, an array of ones is created. Returns the
residual graph and the modified capacity_matrix (when DefaultDistance is used.)

Requires arguments:

- flow_graph::DiGraph,                    # the input graph
- capacity_matrix::AbstractArray{T,2}     # input capacity matrix
"""
function residual{T}(flow_graph::ADiGraph, capacity_matrix::AbstractMatrix{T})
    g = digraph(graph(flow_graph))
    c = Vector{Vector{T}}()
    for i=1:nv(g)
        neigs = fadj(g, i)
        push!(c, zeros(T, length(neigs)))
        for k=1:length(neigs)
            j = neigs[k]
            if has_edge(flow_graph, i, j)
                c[i][k] = capacity_matrix[i, j]
            end #else 0
        end
    end
    return g, c
end

"""
`pl[i][k]` is the position of vertex `i`
in the adjlist of its neighbour `j=fadj[i][k]`,
i.e. `i == adj[j][pl[i][k]]`.
"""
function poslist(g::ASimpleGraph)
    a = fadj(g)
    pl = deepcopy(a)
    for i=1:nv(g)
        for k=1:length(a[i])
            j = a[i][k]
            p = searchsorted(a[j], i)
            @assert length(p) == 1
            pl[i][k] = p[1]
        end
    end
    return pl
end

residual(flow_graph::ADiGraph) = digraph(graph(flow_graph))

# Method for Edmonds–Karp algorithm

function maximum_flow{T<:Number}(
    flow_graph::ADiGraph,                   # the input graph
    source::Int,                           # the source vertex
    target::Int,                           # the target vertex
    capacity_matrix::AbstractMatrix{T},   # edge flow capacities
    algorithm::EdmondsKarpAlgorithm        # keyword argument for algorithm
    )
    residual_graph = residual(flow_graph)
    return edmonds_karp_impl(residual_graph, source, target, capacity_matrix)
end

# Method for Dinic's algorithm

function maximum_flow{T<:Number}(
    flow_graph::ADiGraph,                   # the input graph
    source::Int,                           # the source vertex
    target::Int,                           # the target vertex
    capacity_matrix::AbstractArray{T,2},   # edge flow capacities
    algorithm::DinicAlgorithm              # keyword argument for algorithm
    )
    residual_graph = residual(flow_graph)
    return dinic_impl(residual_graph, source, target, capacity_matrix)
end

# Method for Boykov-Kolmogorov algorithm

function maximum_flow{T<:Number}(
    flow_graph::ADiGraph,                   # the input graph
    source::Int,                           # the source vertex
    target::Int,                           # the target vertex
    capacity_matrix::AbstractArray{T,2},   # edge flow capacities
    algorithm::BoykovKolmogorovAlgorithm   # keyword argument for algorithm
    )
    residual_graph = residual(flow_graph)
    return boykov_kolmogorov_impl(residual_graph, source, target, capacity_matrix)
end

# Method for Push-relabel algorithm

function maximum_flow{T<:Number}(
        flow_graph::ADiGraph,                   # the input graph
        source::Int,                           # the source vertex
        target::Int,                           # the target vertex
        capacity_matrix::AbstractArray{T,2},   # edge flow capacities
        algorithm::PushRelabelAlgorithm        # keyword argument for algorithm
    )

    residual_graph, c = residual(flow_graph, capacity_matrix)
    pos = poslist(residual_graph)
    return push_relabel(residual_graph, source, target, c, pos)
end

"""
    maximum_flow{T<:Number}(
                    flow_graph::ADiGraph,
                    source::Int,
                    target::Int,
                    capacity_matrix::AbstractMatrix{T} =
                        DefaultCapacity(flow_graph);
                    algorithm::AbstractFlowAlgorithm  =
                        PushRelabelAlgorithm(),
                    restriction::T = zero(T)
                    )

Generic maximum_flow function.
The function defaults to the Push-relabel algorithm. Alternatively, the algorithm
to be used can also be specified through a keyword argument. A default capacity of 1
is assumed for each link if no capacity matrix is provided.
If the restriction is bigger than 0, it is applied to capacity_matrix.

All algorithms return a tuple with 1) the maximum flow and 2) the flow matrix.
For the Boykov-Kolmogorov algorithm, the associated mincut is returned as a third output.


### Usage Example:
```julia

# Create a flow-graph and a capacity matrix
flow_graph = DiGraph(8)
flow_edges = [
    (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
    (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
    (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
]
capacity_matrix = zeros(Int, 8, 8)
for e in flow_edges
    u, v, f = e
    add_edge!(flow_graph, u, v)
    capacity_matrix[u,v] = f
end

# Run default maximum_flow without the capacity_matrix
f, F = maximum_flow(flow_graph, 1, 8)

# Run default maximum_flow with the capacity_matrix
f, F = maximum_flow(flow_graph, 1, 8)

# Run Endmonds-Karp algorithm
f, F = maximum_flow(flow_graph,1,8,capacity_matrix,algorithm=EdmondsKarpAlgorithm())

# Run Dinic's algorithm
f, F = maximum_flow(flow_graph,1,8,capacity_matrix,algorithm=DinicAlgorithm())

# Run Boykov-Kolmogorov algorithm
f, F, labels = maximum_flow(flow_graph,1,8,capacity_matrix,algorithm=BoykovKolmogorovAlgorithm())

```
"""
function maximum_flow{G<:ADiGraph, T<:Number}(
        flow_graph::G,                   # the input graph
        source::Int,                           # the source vertex
        target::Int,                           # the target vertex
        capacity_matrix::AbstractArray{T,2} =  # edge flow capacities
            DefaultCapacity(flow_graph);
        algorithm::AbstractFlowAlgorithm  =    # keyword argument for algorithm
            PushRelabelAlgorithm(),
        restriction::T = zero(T)               # keyword argument for restriction max-flow
    )
    if restriction > zero(T)
      return maximum_flow(flow_graph, source, target, min(restriction, capacity_matrix), algorithm)
    end
    return maximum_flow(flow_graph, source, target, capacity_matrix, algorithm)
end
