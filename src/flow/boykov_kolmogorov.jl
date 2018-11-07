"""
Computes the max-flow/min-cut between source and target using
Boykov-Kolmogorov algorithm.

Returns the maximum flow in the network, the flow matrix and
the partition {S,T} in the form of a vector of 1's and 2's.
The partition vector may also contain 0's. These can be
assigned any label (1 or 2), it is a user choice.

For further details, please refer to the paper:

BOYKOV, Y.; KOLMOGOROV, V., 2004. An Experimental Comparison of
Min-Cut/Max-Flow Algorithms for Energy Minimization in Vision.

Uses a default capacity of 1 when the capacity matrix isn\'t specified.

Requires arguments:
residual_graph::ADiGraph                # the input graph
source::Int                            # the source vertex
target::Int                            # the target vertex
capacity_matrix::AbstractMatrix{T}    # edge flow capacities

Author: Júlio Hoffimann Mendes (juliohm@stanford.edu)
"""
function boykov_kolmogorov_impl(
    residual_graph::ADiGraph,               # the input graph
    source,                           # the source vertex
    target,                           # the target vertex
    capacity_matrix::AbstractMatrix{T}    # edge flow capacities
    ) where T<:Number

    n = nv(residual_graph)

    flow = 0
    flow_matrix = spzeros(T, n, n)

    TREE = zeros(Int, n)
    TREE[source] = 1
    TREE[target] = 2

    PARENT = zeros(Int, n)

    A = [source,target]
    O = Vector{Int}()

    while true
        # growth stage
        path = find_path!(residual_graph, source, target, flow_matrix, capacity_matrix, PARENT, TREE, A)

        isempty(path) && break

        # augmentation stage
        flow += augment!(path, flow_matrix, capacity_matrix, PARENT, TREE, O)

        # adoption stage
        adopt!(residual_graph, source, target, flow_matrix, capacity_matrix, PARENT, TREE, A, O)
    end

    return flow, flow_matrix, TREE
end

function find_path!(
    residual_graph::ADiGraph,               # the input graph
    source,                           # the source vertex
    target,                           # the target vertex
    flow_matrix::AbstractMatrix{T},       # the current flow matrix
    capacity_matrix::AbstractMatrix{T},   # edge flow capacities
    PARENT::Vector{Int},                   # parent table
    TREE::Vector{Int},                     # tree table
    A::Vector{Int}                         # active set
    ) where T<:Number

    tree_cap(p,q) = TREE[p] == 1 ? capacity_matrix[p,q] - flow_matrix[p,q] :
                                    capacity_matrix[q,p] - flow_matrix[q,p]
    while !isempty(A)
        p = last(A)
        for q in neighbors(residual_graph, p)
            if tree_cap(p,q) > 0
                if TREE[q] == 0
                    TREE[q] = TREE[p]
                    PARENT[q] = p
                    pushfirst!(A, q)
                end
                if TREE[q] ≠ 0 && TREE[q] ≠ TREE[p]
                    # p -> source
                    path_to_source = [p]
                    while PARENT[p] ≠ 0
                        p = PARENT[p]
                        push!(path_to_source, p)
                    end

                    # q -> target
                    path_to_target = [q]
                    while PARENT[q] ≠ 0
                        q = PARENT[q]
                        push!(path_to_target, q)
                    end

                    # source -> target
                    path = [reverse!(path_to_source); path_to_target]

                    if path[1] == source && path[end] == target
                        return path
                    elseif path[1] == target && path[end] == source
                        return reverse!(path)
                    end
                end
            end
        end
        pop!(A)
    end

    return Vector{Int}()
end

function augment!(
    path::AbstractVector,                  # path from source to target
    flow_matrix::AbstractMatrix{T},       # the current flow matrix
    capacity_matrix::AbstractMatrix{T},   # edge flow capacities
    PARENT::Vector{Int},                   # parent table
    TREE::Vector{Int},                     # tree table
    O::Vector{Int}                         # orphan set
    ) where T<:Number

    # bottleneck capacity
    Δ = Inf
    for i=1:length(path)-1
        p, q = path[i:i+1]
        cap = capacity_matrix[p,q] - flow_matrix[p,q]
        cap < Δ && (Δ = cap)
    end

    # update residual graph
    for i=1:length(path)-1
        p, q = path[i:i+1]
        flow_matrix[p,q] += Δ
        flow_matrix[q,p] -= Δ

        # create orphans
        if flow_matrix[p,q] == capacity_matrix[p,q]
            if TREE[p] == TREE[q] == 1
                PARENT[q] = 0
                pushfirst!(O, q)
            end
            if TREE[p] == TREE[q] == 2
                PARENT[p] = 0
                pushfirst!(O, p)
            end
        end
    end

    return Δ
end

function adopt!(
    residual_graph::ADiGraph,               # the input graph
    source::Int,                           # the source vertex
    target::Int,                           # the target vertex
    flow_matrix::AbstractMatrix{T},       # the current flow matrix
    capacity_matrix::AbstractMatrix{T},   # edge flow capacities
    PARENT::Vector{Int},                   # parent table
    TREE::Vector{Int},                     # tree table
    A::Vector{Int},                        # active set
    O::Vector{Int}                         # orphan set
    ) where T<:Number

    tree_cap(p,q) = TREE[p] == 1 ? capacity_matrix[p,q] - flow_matrix[p,q] :
    capacity_matrix[q,p] - flow_matrix[q,p]
    while !isempty(O)
        p = pop!(O)
        # try to find parent that is not an orphan
        parent_found = false
        for q in neighbors(residual_graph, p)
            if TREE[q] == TREE[p] && tree_cap(q,p) > 0
                # check if "origin" is either source or target
                o = q
                while PARENT[o] ≠ 0
                    o = PARENT[o]
                end
                if o == source || o == target
                    parent_found = true
                    PARENT[p] = q
                    break
                end
            end
        end

        if !parent_found
            # scan all neighbors and make the orphan a free node
            for q in neighbors(residual_graph, p)
                if TREE[q] == TREE[p]
                    if tree_cap(q,p) > 0
                        pushfirst!(A, q)
                    end
                    if PARENT[q] == p
                        PARENT[q] = 0
                        pushfirst!(O, q)
                    end
                end
            end

            TREE[p] = 0
            B = setdiff(A, p)
            resize!(A, length(B))[:] = B
        end
    end
end
