"""
abstract type that allows users to pass in their preferred Algorithm
"""
abstract type AbstractFlowAlgorithm end

"""
Forces the maximum_flow function to use the Edmonds–Karp algorithm.
"""
struct EdmondsKarpAlgorithm <: AbstractFlowAlgorithm end

"""
Forces the maximum_flow function to use Dinic\'s algorithm.
"""
struct DinicAlgorithm <: AbstractFlowAlgorithm end

"""
Forces the maximum_flow function to use the Boykov-Kolmogorov algorithm.
"""
struct BoykovKolmogorovAlgorithm <: AbstractFlowAlgorithm end

"""
Forces the maximum_flow function to use the Push-Relabel algorithm.
"""
struct PushRelabelAlgorithm <: AbstractFlowAlgorithm end

"""
Type that returns 1 if a forward edge exists, and 0 otherwise
"""
mutable struct DefaultCapacity{G<:ADiGraph, I<:Integer} <: AbstractMatrix{I}
    g::G
    nv::I
end
DefaultCapacity(g::G) where {G<:ADiGraph} = DefaultCapacity(g, signed(nv(g)))

getindex(d::DefaultCapacity, s, t) = has_edge(d.g, s , t) ? 1 : 0
size(d::DefaultCapacity) = (d.nv, d.nv)

function _complete(g::ADiGraph, capacity_matrix::AbstractMatrix{T}) where T
    S = signedtype(T)
    c = Vector{Vector{S}}()
    for i=1:nv(g)
        neigs = neighbors(g, i)
        push!(c, zeros(S, length(neigs)))
        for (k, j) in enumerate(neigs)
            if has_edge(g, i, j)
                val = capacity_matrix[i, j]
                @assert val >= 0 "Capacities should be non-negative"
                c[i][k] = val
            end #else 0
        end
    end
    return c
end

"""
`pl[i][k]` is the position of vertex `i`
in the adjlist of its neighbour `j=fadj[i][k]`,
i.e. `i == adj[j][pl[i][k]]`.
"""
function poslist(g::AGraphOrDiGraph)
    pl = Vector{Vector{Int}}()
    for i=1:nv(g)
        push!(pl, zeros(Int, degree(g, i)))
        for (k,j) in enumerate(neighbors(g, i))
            p = countfirst(neighbors(g,j), i)
            @assert p > 0
            pl[i][k] = p
        end
    end
    return pl
end

"""
    residual_graph{G<:ADiGraph}(g::G, capacity, flow)

Computers the residual graph of `g` associated to given `flow` and `capacity`.
See wikipedia.
"""
function residual_graph(g::G,
        capacity::Vector{Vector{T}}, flow::Vector{Vector{T}}
    ) where {G<:ADiGraph,T<:Number}
    h = G(nv(g))
    for i=1:nv(g)
        c = capacity[i]
        f = flow[i]
        for (k, j) in enumerate(neighbors(g, i))
            if c[k] - f[k] > 0
                add_edge!(h, i, j)
            end
        end
    end
    return h
end

function residual_graph(g::G, capacity::AbstractMatrix, flow::AbstractMatrix) where G<:ADiGraph
    h = G(nv(g))
    for e in edges(g)
        i, j = src(e), dst(e)
        if capacity[i,j] - flow[i,j] > 0
            add_edge!(h, i, j)
        end
    end
    return h
end

function cut_labels(g::G, source, capacity, flow) where G<:ADiGraph
    h = residual_graph(g, capacity, flow)
    svertices = neighborhood(h, source, nv(h))
    labels = fill(2, nv(h))
    for i in svertices
        labels[i] = 1
    end
    return labels
end


"""
    maximum_flow{T<:Number}(
                        g::ADiGraph,
                        source::Int,
                        target::Int,
                        capacity_matrix::AbstractMatrix{T} =
                            DefaultCapacity(g);
                        algorithm::AbstractFlowAlgorithm  =
                            PushRelabelAlgorithm(),
                        restriction::T = zero(T)
                    )

Generic maximum_flow function.
The function defaults to the Push-Relabel (also called Preflow) algorithm. Alternatively, the algorithm
to be used can also be specified through a keyword argument. A default capacity of 1
is assumed for each link if no capacity matrix is provided.
If the restriction is bigger than 0, it is applied to capacity_matrix.

All algorithms return a tuple with
1) the maximum flow
2) the flow matrix
3) the labelling associated to the minimum cut

Available algorithms are `DinicAlgorithm`, `EdmondsKarpAlgorithm`, `BoykovKolmogorovAlgorithm`
and `PushRelabelAlgorithm`.

Time complexity is O(V²√E) for the push relabel algorithm.

### Usage Example:
```julia

# Create a flow-graph and a capacity matrix
g = DiGraph(8)
flow_edges = [
    (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
    (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
    (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
]
capacity_matrix = zeros(Int, 8, 8)
for e in flow_edges
    u, v, f = e
    add_edge!(g, u, v)
    capacity_matrix[u,v] = f
end

# Run default maximum_flow without the capacity_matrix (assumes capacity 1. on each edge).
f, F, labels = maximum_flow(g, 1, 8)

# Run Endmonds-Karp algorithm
f, F, labels = maximum_flow(g,1,8,capacity_matrix,algorithm=EdmondsKarpAlgorithm())
```
"""
function maximum_flow(
        g::G,                   # the input graph
        source,                           # the source vertex
        target,                           # the target vertex
        capacity_matrix::AbstractMatrix{T} =  # edge flow capacities
            DefaultCapacity(g);
        algorithm::AbstractFlowAlgorithm  =    # keyword argument for algorithm
            PushRelabelAlgorithm(),
        restriction::T = zero(T)
    ) where {G<:ADiGraph, T<:Number}
    if restriction > zero(T)
        capacity_matrix = min.(restriction, capacity_matrix)
    end
    flow_graph = complete(g)
    if  algorithm == DinicAlgorithm()
        f, F =  dinic_impl(flow_graph, source, target, capacity_matrix)
    elseif algorithm == EdmondsKarpAlgorithm()
        f, F =  edmonds_karp_impl(flow_graph, source, target, capacity_matrix)
    elseif algorithm == BoykovKolmogorovAlgorithm()
        f, F, labels =  boykov_kolmogorov_impl(flow_graph, source, target, capacity_matrix)
    elseif algorithm == PushRelabelAlgorithm()
        c = _complete(flow_graph, capacity_matrix)
        pos = poslist(flow_graph)
        f, Fvec = push_relabel_impl(flow_graph, source, target, c, pos)
        F = spzeros(T, nv(g), nv(g))
        for i=1:nv(g)
            for (k,j) in enumerate(neighbors(flow_graph, i))
                F[i,j] = Fvec[i][k]
            end
        end
    end
    labels = cut_labels(flow_graph, source, capacity_matrix, F)

    return f, F, labels
end

function maximum_flow(
        flow_graph::G,                   # the input graph
        source,                           # the source vertex
        target,                           # the target vertex
        capacities::Vector{Vector{T}}
    ) where {G<:ADiGraph, T<:Number}
    pos = poslist(flow_graph)
    f, F = push_relabel_impl(flow_graph, source, target, capacities, pos)
    labels = cut_labels(flow_graph, source, capacities, F)
    return f, F, labels
end

"""
    minimum_cut(g, s, t, capacity_matrix=DefaultCapacity(); kws...)

Finds the `s-t cut` of minimal weight according to the `capacities` matrix on
the directed graph `g`.
The solution is found through a maximal flow algorithm.
See [`maximum_flow`](@ref) for the optional arguments.

Returns a triple `(f, cut, labels)`, where `f` is the weight of the cut,
`cut` is a vector of the edges in the cut, and `labels` gives a partitioning
of the vertices in two sets, according to the cut.
"""
function minimum_cut(g::ADiGraph, s::Integer, t::Integer, args...; kws...)
    f, F, labels = maximum_flow(g, s, t, args...; kws...)
    E = edgetype(g)
    cut = Vector{E}()
    for e in edges(g)
        if labels[src(e)] == 1 && labels[dst(e)] == 2
            push!(cut, e)
        end
    end
    f, cut, labels
end
