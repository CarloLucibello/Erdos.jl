# Parts of this code were taken / derived from NetworkX. See LICENSE for
# licensing details.

"""
    CompleteGraph(n, G = Graph)

Creates a complete graph of type `G` with `n` vertices. A complete graph has edges
connecting each pair of vertices.
"""
function CompleteGraph(n::Integer, ::Type{G} = Graph) where G<:AGraph
    g = G(n)
    for i = 1:n, j=i+1:n
        unsafe_add_edge!(g, i, j)
    end
    rebuild!(g)
    return g
end


"""
    CompleteBipartiteGraph(n1, n2, G = Graph)

Creates a complete bipartite graph with `n1+n2` vertices. It has edges
connecting each pair of vertices in the two sets.
"""
function CompleteBipartiteGraph(n1::Integer, n2::Integer, ::Type{G} = Graph) where G<:AGraph
    g = G(n1+n2)
    for i = 1:n1, j=n1+1:n1+n2
        unsafe_add_edge!(g, i, j)
    end
    rebuild!(g)
    return g
end

"""
    CompleteDiGraph(n, G = DiGraph)

Creates a complete digraph with `n` vertices. A complete digraph has edges
connecting each pair of vertices (both an ingoing and outgoing edge).
"""
function CompleteDiGraph(n::Integer, ::Type{G} = DiGraph) where G<:ADiGraph
    g = G(n)
    for i = 1:n, j=1:i-1
        unsafe_add_edge!(g, i,j)
    end
    for i = 1:n, j=i+1:n
        unsafe_add_edge!(g, i,j)
    end
    rebuild!(g)
    return g
end

"""
    StarGraph(n, G = Graph)

Creates a star graph with `n` vertices. A star graph has a central vertex
with edges to each other vertex.
"""
function StarGraph(n::Integer, ::Type{G} = Graph) where G<:AGraph
    g = G(n)
    for i = 2:n
        add_edge!(g, 1, i)
    end
    return g
end

"""Creates a star digraph with `n` vertices. A star digraph has a central
vertex with directed edges to every other vertex.
"""
function StarDiGraph(n::Integer, ::Type{G} = DiGraph) where G<:ADiGraph
    g = G(n)
    for i = 2:n
        add_edge!(g, 1,i)
    end
    return g
end

"""
    PathGraph(n, G = Graph)

Creates a path graph with `n` vertices. A path graph connects each
successive vertex by a single edge.
"""
function PathGraph(n::Integer, ::Type{G} = Graph) where G<:AGraph
    g = G(n)
    for i = 2:n
        add_edge!(g, i-1, i)
    end
    return g
end

"""
    PathDiGraph(n, G = DiGraph)

Creates a path digraph with `n` vertices. A path graph connects each
successive vertex by a single directed edge.
"""
function PathDiGraph(n::Integer, ::Type{G} = DiGraph) where G<:ADiGraph
    g = G(n)
    for i = 2:n
        add_edge!(g, i-1, i)
    end
    return g
end

"""
    CycleGraph(n, G=Graph)

Creates a cycle graph with `n` vertices. A cycle graph is a closed path graph.
"""
function CycleGraph(n::Integer, ::Type{G} = Graph) where G<:AGraph
    g = G(n)
    for i = 1:n-1
        add_edge!(g, i, i+1)
    end
    add_edge!(g, n, 1)
    return g
end

"""Creates a cycle digraph with `n` vertices. A cycle digraph is a closed path digraph.
"""
function CycleDiGraph(n::Integer, ::Type{G} = DiGraph) where G<:ADiGraph
    g = G(n)
    for i = 1:n-1
        add_edge!(g, i, i+1)
    end
    add_edge!(g, n, 1)
    return g
end


"""
    WheelGraph(n, G=Graph)

Creates a wheel graph with `n` vertices. A wheel graph is a star graph with
the outer vertices connected via a closed path graph.
"""
function WheelGraph(n::Integer, ::Type{G} = Graph) where G<:AGraph
    g = StarGraph(n, G)
    for i = 3:n
        add_edge!(g, i-1, i)
    end
    if n != 2
        add_edge!(g, n, 2)
    end
    return g
end

"""Creates a wheel digraph with `n` vertices. A wheel graph is a star digraph
with the outer vertices connected via a closed path graph.
"""
function WheelDiGraph(n::Integer, ::Type{G} = DiGraph) where G<:ADiGraph
    g = StarDiGraph(n, G)
    for i = 3:n
        add_edge!(g, i-1, i)
    end
    if n != 2
        add_edge!(g, n, 2)
    end
    return g
end

"""
    Grid(dims::AbstractVector, G=Graph; periodic=false)

Creates a `d`-dimensional cubic lattice, with `d=length(dims)` and length  `dims[i]` in dimension `i`.
If `periodic=true` the resulting lattice will have periodic boundary condition in each dimension.
"""
function Grid(dims::AbstractVector{T}, ::Type{G} = Graph;
        periodic=false) where {T<:Integer,G<:AGraph}
    f = periodic ? d->CycleGraph(d, G) : d->PathGraph(d, G)
    g = f(dims[1])
    for d in dims[2:end]
        g = cartesian_product(f(d), g)
    end
    return g
end

"""
    BinaryTree(levels, G=Graph)

Creates a binary tree with k-levels vertices are numbered 1:2^levels-1
"""
function BinaryTree(levels::Int, ::Type{G} = Graph) where G<:AGraph
    g = G(2^levels-1)
    for i in 0:levels-2
        for j in 2^i:2^(i+1)-1
            add_edge!(g, j, 2j)
            add_edge!(g, j, 2j+1)
        end
    end
    return g
end

"""
    DoubleBinaryTree(levels, G=Graph)

Create a double complete binary tree with k-levels
used as an example for spectral clustering by Guattery and Miller 1998.
"""
function DoubleBinaryTree(levels::Int, ::Type{G} = Graph) where G<:AGraph
    gl = BinaryTree(levels, G)
    gr = BinaryTree(levels, G)
    g = blkdiag(gl, gr)
    add_edge!(g,1, nv(gl)+1)
    return g
end


"""The Roach Graph from Guattery and Miller 1998"""
function RoachGraph(k::Int, ::Type{G} = Graph) where G<:AGraph
    dipole = CompleteGraph(2, G)
    nopole = G(2)
    antannae = crosspath(nopole, k)
    body = crosspath(dipole, k)
    roach = blkdiag(antannae, body)
    add_edge!(roach, nv(antannae)-1, nv(antannae)+1)
    add_edge!(roach, nv(antannae), nv(antannae)+2)
    return roach
end


"""
    CliqueGraph(k, n, G=Graph)

This function generates a graph with `n` `k`-cliques connected circularly by `n` edges.
"""
function CliqueGraph(k::Integer, n::Integer, ::Type{G} = Graph) where G<:AGraph
    g = G(k*n)
    for c=1:n
        for i=(c-1)*k+1:c*k-1, j=i+1:c*k
            add_edge!(g, i, j)
        end
    end
    for i=1:n-1
        add_edge!(g, (i-1)*k+1, i*k+1)
    end
    add_edge!(g, 1, (n-1)*k+1)
    return g
end
