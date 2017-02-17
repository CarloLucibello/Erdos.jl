"""
    erdos_renyi(n::Int, p::Real, G=Graph; seed=-1)
    erdos_renyi(n::Int, m::Int, G=Graph; seed=-1)

Creates an [Erdős–Rényi](http://en.wikipedia.org/wiki/Erdős–Rényi_model)
random graph of type `G` with `n` vertices.
Edges are added between pairs of vertices with probability `p` in the first method.
In the second method `m` edges are randomly chosen insted.

Undirected graphs are created by default. Directed graphs can be created
passing a directed graph type as last argument (e.g. `DiGraph`)

Note also that Erdős–Rényi graphs may be generated quickly using `erdos_renyi(n, ne)`
or the  `Graph(nv, ne)` constructor, which randomly select `ne` edges among all the potential
edges.
"""
function erdos_renyi{G<:ASimpleGraph}(n::Int, p::Real, ::Type{G} = Graph;
        seed::Int=-1)
    m = is_directed(G) ? n*(n-1) : div(n*(n-1),2)
    if seed >= 0
        # init dsfmt generator without altering GLOBAL_RNG
        Base.dSFMT.dsfmt_gv_init_by_array(MersenneTwister(seed).seed+UInt32(1))
    end
    ne = randbinomial(m, p) # sadly StatsBase doesn't support non-global RNG
    return erdos_renyi(n, m, G; seed=seed)
end

function erdos_renyi{G<:ASimpleGraph}(n::Int, m::Int, ::Type{G} = Graph;
        seed::Int = -1)
    maxe = is_directed(G) ? n * (n-1) : div(n * (n-1), 2)
    @assert(m <= maxe, "Maximum number of edges for this generator is $maxe")
    m > 2/3 * maxe && return complement(erdos_renyi(n, maxe-m, G; seed=seed))

    rng = getRNG(seed)
    g = G(n)
    while ne(g) < m
        source = rand(rng, 1:n)
        dest = rand(rng, 1:n)
        source != dest && add_edge!(g, source, dest)
    end
    return g
end

"""
    watts_strogatz(n, k, β, G=Graph; seed=-1)

Creates a [Watts-Strogatz](https://en.wikipedia.org/wiki/Watts_and_Strogatz_model)
small model random graph with `n` vertices, each with degree `k`. Edges are
randomized per the model based on probability `β`.

Undirected graphs are created by default. Directed graphs can be created
passing a directed graph type as last argument (e.g. `DiGraph`).
"""
function watts_strogatz{G<:ASimpleGraph}(n::Int, k::Int, β::Real, ::Type{G} = Graph;
        seed::Int = -1)
    @assert k < n/2
    g = G(n)
    rng = getRNG(seed)
    for s in 1:n
        for i in 1:(floor(Int, k/2))
            target = ((s + i - 1) % n) + 1
            if rand(rng) > β && !has_edge(g, s, target) # TODO: optimize this based on return of add_edge!
                add_edge!(g, s, target)
            else
                while true
                    d = target
                    while d == target
                        d = rand(rng, 1:n-1)
                        if s < d
                            d += 1
                        end
                    end
                    if s != d
                        add_edge!(g, s, d) && break
                    end
                end
            end
        end
    end
    return g
end

function _suitable{T}(edges::Set{Edge{T}}, potential_edges::Dict{T, T})
    isempty(potential_edges) && return true
    list = keys(potential_edges)
    for s1 in list, s2 in list
        s1 >= s2 && continue
        (Edge{T}(s1, s2) ∉ edges) && return true
    end
    return false
end

_try_creation_rrg{T<:Integer}(n::T, k::T, rng::AbstractRNG) = _try_creation_rrg(n, fill(k,n), rng)

function _try_creation_rrg{T<:Integer}(n::T, k::Vector{T}, rng::AbstractRNG)
    E = Edge{T}
    edges = Set{E}()
    m = 0
    stubs = zeros(T, sum(k))
    for i=1:n
        for j = 1:k[i]
            m += 1
            stubs[m] = i
        end
    end
    # stubs = vcat([fill(i, k[i]) for i=1:n]...) # slower

    while !isempty(stubs)
        potential_edges =  Dict{T,T}()
        shuffle!(rng, stubs)
        for i in 1:2:length(stubs)
            s1, s2 = stubs[i:i+1]
            if (s1 > s2)
                s1, s2 = s2, s1
            end
            e = E(s1, s2)
            if s1 != s2 && ∉(e, edges)
                push!(edges, e)
            else
                potential_edges[s1] = get(potential_edges, s1, 0) + 1
                potential_edges[s2] = get(potential_edges, s2, 0) + 1
            end
        end

        if !_suitable(edges, potential_edges)
            return Set{E}()
        end

        stubs = Vector{T}()
        for (e, ct) in potential_edges
            append!(stubs, fill(e, ct))
        end
    end
    return edges
end

"""
    barabasi_albert(n, k, G=Graph; seed=-1)
    barabasi_albert(n, n0, k, G=Graph; seed=-1)

Creates a random graph of type `G` with `n` vertices according to [Barabási–Albert model](https://en.wikipedia.org/wiki/Barab%C3%A1si%E2%80%93Albert_model).
It is grown by adding new vertices to an initial graph with `n0` vertices (`n0=k` if not specified).
Each new vertex is attached with `k` edges to `k` different vertices already present in the system by preferential attachment.
The initial graph is empty by default.

Undirected graphs are created by default. Directed graphs can be created
passing a directed graph type as last argument (e.g. `DiGraph`).

See also [`barabasi_albert!`](@ref) for growing a given graph.
"""
barabasi_albert{G<:ASimpleGraph}(n::Int, k::Int, ::Type{G}=Graph; keyargs...) =
    barabasi_albert(n, k, k, G; keyargs...)

function barabasi_albert{G<:ASimpleGraph}(n::Int, n0::Int, k::Int, ::Type{G}=Graph;
        seed::Int = -1)
    g = G(n0)
    barabasi_albert!(g, n, k; seed = seed)
    return g
end

"""
    barabasi_albert!(g, n::Int, k::Int; seed::Int = -1)

Grows the graph `g` according to
[Barabási–Albert](https://en.wikipedia.org/wiki/Barab%C3%A1si%E2%80%93Albert_model)
process into a graph with `n` vertices. At each step a new vertex is attached by
preferential attachment to `k` different vertices already present in the graph.

See also [`barabasi_albert`](@ref).
"""
function barabasi_albert!(g::ASimpleGraph, n::Int, k::Int; seed::Int=-1)
    n0 = nv(g)
    1 <= k <= n0 <= n ||
        throw(ArgumentError("Barabási-Albert model requires 1 <= k <= nv(g) <= n"))
    n0 == n && return g

    # seed random number generator
    seed > 0 && srand(seed)

    add_vertices!(g, n - n0)

    # if initial graph doesn't contain any edges
    # expand it by one vertex and add k edges from this additional node
    if ne(g) == 0
        # expand initial graph
        n0 += 1

        # add edges to k existing nodes
        for target in sample!(collect(1:n0-1), k)
            add_edge!(g, n0, target)
        end
    end

    # vector of weighted nodes (each node is repeated once for each adjacent edge)
    weightedNodes = Vector{Int}(2*(n-n0)*k + 2*ne(g))

    # initialize vector of weighted nodes
    offset = 0
    for e in edges(g)
        weightedNodes[offset+=1] = src(e)
        weightedNodes[offset+=1] = dst(e)
    end

    # array to record if a node is picked
    picked = fill(false, n)

    # vector of targets
    targets = Vector{Int}(k)

    for source in n0+1:n
        # choose k targets from the existing nodes
        # pick uniformly from weightedNodes (preferential attachement)
        i = 0
        while i < k
            target = weightedNodes[rand(1:offset)]
            if !picked[target]
                targets[i+=1] = target
                picked[target] = true
            end
        end

        # add edges to k targets
        for target in targets
            add_edge!(g, source, target)

            weightedNodes[offset+=1] = source
            weightedNodes[offset+=1] = target
            picked[target] = false
        end
    end

    return g
end


"""
    static_fitness_model(m, fitness, G=Graph; seed=-1)
    static_fitness_model(m, fitness_out, fitness_in, G=DiGraph; seed=-1)

Generates a random graph with `length(fitness)` nodes and `m` edges,
in which the probability of the existence of edge `(i, j)` is proportional
to `fitness[i]*fitness[j]`. Time complexity is O(|V| + |E| log |E|).

In and out fitness have to be supplied for generating directed graphs.

Reference:

* Goh K-I, Kahng B, Kim D: Universal behaviour of load distribution
in scale-free networks. Phys Rev Lett 87(27):278701, 2001.
"""
function static_fitness_model{T<:Real, G<:AGraph}(m::Int, fitness::Vector{T},
        ::Type{G}=Graph; seed::Int=-1)
    @assert(m >= 0, "invalid number of edges")
    n = length(fitness)
    m == 0 && return G(n)
    nodes = 0
    for f in fitness
        # sanity check for the fitness
        f < zero(T) && error("fitness scores must be non-negative")
        f > zero(T) && (nodes += 1)
    end
    # avoid getting into an infinite loop when too many edges are requested
    max_no_of_edges = div(nodes*(nodes-1), 2)
    @assert(m <= max_no_of_edges, "too many edges requested")
    # calculate the cumulative fitness scores
    cum_fitness = cumsum(fitness)
    g = G(n)
    _create_static_fitness_graph!(g, m, cum_fitness, cum_fitness, seed)
    return g
end

function static_fitness_model{T<:Real,S<:Real, G<:ADiGraph}(m::Int, fitness_out::Vector{T},
        fitness_in::Vector{S}, ::Type{G}=DiGraph; seed::Int=-1)
    @assert(m >= 0, "invalid number of edges")
    n = length(fitness_out)
    @assert(length(fitness_in) == n, "fitness_in must have the same size as fitness_out")
    m == 0 && return G(n)
    # avoid getting into an infinite loop when too many edges are requested
    outnodes = innodes = nodes = 0
    @inbounds for i=1:n
        # sanity check for the fitness
        (fitness_out[i] < zero(T) || fitness_in[i] < zero(S)) && error("fitness scores must be non-negative")
        fitness_out[i] > zero(T) && (outnodes += 1)
        fitness_in[i] > zero(S) && (innodes += 1)
        (fitness_out[i] > zero(T) && fitness_in[i] > zero(S)) && (nodes += 1)
    end
    max_no_of_edges = outnodes*innodes - nodes
    @assert(m <= max_no_of_edges, "too many edges requested")
    # calculate the cumulative fitness scores
    cum_fitness_out = cumsum(fitness_out)
    cum_fitness_in = cumsum(fitness_in)
    g = G(n)
    _create_static_fitness_graph!(g, m, cum_fitness_out, cum_fitness_in, seed)
    return g
end

function _create_static_fitness_graph!{T<:Real,S<:Real}(g::ASimpleGraph, m::Int, cum_fitness_out::Vector{T}, cum_fitness_in::Vector{S}, seed::Int)
    rng = getRNG(seed)
    max_out = cum_fitness_out[end]
    max_in = cum_fitness_in[end]
    while m > 0
        source = searchsortedfirst(cum_fitness_out, rand(rng)*max_out)
        target = searchsortedfirst(cum_fitness_in, rand(rng)*max_in)
        # skip if loop edge
        (source == target) && continue
        edge = Edge(source, target)
        # is there already an edge? If so, try again
        add_edge!(g, edge) || continue
        m -= 1
    end
end

"""
    function static_scale_free(n, m, α, G=Graph;
            seed=-1, finite_size_correction=true)

Generates a random graph with `n` vertices, `m` edges and expected power-law
degree distribution with exponent `α`. `finite_size_correction` determines
whether to use the finite size correction proposed by Cho et al.
This generator calls internally the `static_fitness_model function`.
Time complexity is O(|V| + |E| log |E|).

    function static_scale_free(n, m, α_out, α_in, G=DiGraph;
            seed=-1, finite_size_correction=true)

Generates a random digraph

References:

* Goh K-I, Kahng B, Kim D: Universal behaviour of load distribution in scale-free networks. Phys Rev Lett 87(27):278701, 2001.

* Chung F and Lu L: Connected components in a random graph with given degree sequences. Annals of Combinatorics 6, 125-145, 2002.

* Cho YS, Kim JS, Park J, Kahng B, Kim D: Percolation transitions in scale-free networks under the Achlioptas process. Phys Rev Lett 103:135702, 2009.
"""
function static_scale_free{G<:AGraph}(n::Int, m::Int, α::Float64, ::Type{G} = Graph;
        seed::Int=-1, finite_size_correction::Bool=true)
    @assert(n >= 0, "Invalid number of nodes")
    @assert(α >= 2, "out-degree exponent must be >= 2")
    fitness = _construct_fitness(n, α, finite_size_correction)
    static_fitness_model(m, fitness, G, seed=seed)
end

function static_scale_free{G<:ADiGraph}(n::Int, m::Int, α_out::Float64, α_in::Float64, ::Type{G} = DiGraph;
        seed::Int=-1, finite_size_correction::Bool=true)
    @assert(n >= 0, "Invalid number of nodes")
    @assert(α_out >= 2, "out-degree exponent must be >= 2")
    @assert(α_in >= 2, "in-degree exponent must be >= 2")
    # construct the fitness
    fitness_out = _construct_fitness(n, α_out, finite_size_correction)
    fitness_in = _construct_fitness(n, α_in, finite_size_correction)
    # eliminate correlation
    shuffle!(fitness_in)
    static_fitness_model(m, fitness_out, fitness_in, G, seed=seed)
end

function _construct_fitness(n::Int, α::Float64, finite_size_correction::Bool)
    α = -1/(α-1)
    fitness = zeros(n)
    j = float(n)
    if finite_size_correction && α < -0.5
        # See the Cho et al paper, first page first column + footnote 7
        j += n^(1+1/2α) * (10sqrt(2)*(1+α)) ^ (-1/α) - 1
    end
    j = max(j, n)
    @inbounds for i=1:n
        fitness[i] = j ^ α
        j -= 1
    end
    return fitness
end

"""
    random_regular_graph(n::Int, k::Int; seed=-1)

Creates a random undirected
[regular graph](https://en.wikipedia.org/wiki/Regular_graph) with `n` vertices,
each with degree `k`.

For undirected graphs, allocates an array of `nk` `Int`s, and takes
approximately ``nk^2`` time. For ``k > n/2``, generates a graph of degree
`n-k-1` and returns its complement.
"""
function random_regular_graph{G<:AGraph}(n::Int, k::Int, ::Type{G}=Graph;
        seed::Int=-1)
    @assert(iseven(n*k), "n * k must be even")
    @assert(0 <= k < n, "the 0 <= k < n inequality must be satisfied")
    if k == 0
        return G(n)
    end
    if (k > n/2) && iseven(n * (n-k-1))
        return complement(random_regular_graph(n, n-k-1, G, seed=seed))
    end

    rng = getRNG(seed)

    T = vertextype(G)
    edges = _try_creation_rrg(T(n), T(k), rng)
    while isempty(edges)
        edges = _try_creation_rrg(T(n), T(k), rng)
    end
    g = G(n)
    for edge in edges
        add_edge!(g, edge)
    end

    return g
end


"""
    random_configuration_model(n::Int, k::Vector{Int}; seed=-1, check_graphical=false)

Creates a random undirected graph according to the [configuraton model]
(http://tuvalu.santafe.edu/~aaronc/courses/5352/fall2013/csci5352_2013_L11.pdf).
It contains `n` vertices, the vertex `i` having degree `k[i]`.

Defining `c = mean(k)`, it allocates an array of `nc` `Int`s, and takes
approximately ``nc^2`` time.


If `check_graphical=true` makes sure that `k` is a graphical sequence (see `is_graphical`).
"""
function random_configuration_model{G<:AGraph}(n::Int, k::Vector{Int}, ::Type{G}=Graph;
        seed::Int=-1, check_graphical::Bool=false)
    @assert(n == length(k), "a degree sequence of length n has to be provided")
    m = sum(k)
    @assert(iseven(m), "sum(k) must be even")
    @assert(all(0 .<= k .< n), "the 0 <= k[i] < n inequality must be satisfied")
    if check_graphical
        is_graphical(k) || error("Degree sequence non graphical")
    end
    rng = getRNG(seed)

    edges = _try_creation_rrg(n, k, rng)
    while m > 0 && isempty(edges)
        edges = _try_creation_rrg(n, k, rng)
    end

    g = G(n)
    for edge in edges
        add_edge!(g, edge)
    end

    return g
end

"""
    random_regular_digraph(n::Int, k::Int; dir::Symbol=:out, seed=-1)

Creates a random directed
[regular graph](https://en.wikipedia.org/wiki/Regular_graph) with `n` vertices,
each with degree `k`. The degree (in or out) can be
specified using `dir=:in` or `dir=:out`. The default is `dir=:out`.

For directed graphs, allocates an ``n \times n`` sparse matrix of boolean as an
adjacency matrix and uses that to generate the directed graph.
"""
function random_regular_digraph{G<:ADiGraph}(n::Int, k::Int, ::Type{G}=DiGraph;
        dir::Symbol=:out, seed::Int=-1)
    #TODO remove the function sample from StatsBase for one allowing the use
    # of a local rng
    @assert(0 <= k < n, "the 0 <= k < n inequality must be satisfied")

    if k == 0
        return G(n)
    end
    if (k > n/2) && iseven(n * (n-k-1))
        return complement(random_regular_digraph(n, n-k-1, G, dir=dir, seed=seed))
    end
    rng = getRNG(seed)
    cs = collect(2:n)
    i = 1
    I = Vector{Int}(n*k)
    J = Vector{Int}(n*k)
    V = fill(true, n*k)
    for r in 1:n
        l = (r-1)*k+1 : r*k
        I[l] = r
        J[l] = sample!(rng, cs, k, exclude = r)
    end

    if dir == :out
        return G(sparse(I, J, V, n, n))
    else
        return G(sparse(I, J, V, n, n)')
    end
end

"""
    stochastic_block_model(c::Matrix{Float64}, n::Vector{Int}; seed::Int = -1)
    stochastic_block_model(cin::Float64, coff::Float64, n::Vector{Int}; seed::Int = -1)

Returns a Graph generated according to the Stochastic Block Model (SBM).

`c[a,b]` : Mean number of neighbors of a vertex in block `a` belonging to block `b`.
           Only the upper triangular part is considered, since the lower traingular is
           determined by ``c[b,a] = c[a,b] * n[a]/n[b]``.
`n[a]` : Number of vertices in block `a`

The second form samples from a SBM with `c[a,a]=cin`, and `c[a,b]=coff`.

For a dynamic version of the SBM see the `StochasticBlockModel` type and
related functions.
"""
function stochastic_block_model{T<:Real, G<:AGraph}(c::Matrix{T}, n::Vector{Int},
        ::Type{G}=Graph; seed::Int = -1)
    @assert size(c,1) == length(n)
    @assert size(c,2) == length(n)
    # init dsfmt generator without altering GLOBAL_RNG
    seed > 0 && Base.dSFMT.dsfmt_gv_init_by_array(MersenneTwister(seed).seed+1)
    rng =  seed > 0 ? MersenneTwister(seed) : MersenneTwister()

    N = sum(n)
    K = length(n)
    nedg = zeros(Int,K, K)
    g = G(N)
    cum = [sum(n[1:a]) for a=0:K]
    for a=1:K
        ra = cum[a]+1:cum[a+1]
        for b=a:K
            @assert a==b? c[a,b] <= n[b]-1 : c[a,b] <= n[b]   "Mean degree cannot be greater than available neighbors in the block."

            m = a==b ? div(n[a]*(n[a]-1),2) : n[a]*n[b]
            p = a==b ? n[a]*c[a,b] / (2m) : n[a]*c[a,b]/m
            nedg = randbinomial(m, p)
            rb = cum[b]+1:cum[b+1]
            i=0
            while i < nedg
                source = rand(rng, ra)
                dest = rand(rng, rb)
                if source != dest
                    if add_edge!(g, source, dest)
                        i += 1
                    end
                end
            end
        end
    end
    return g
end

function stochastic_block_model{T<:Real, G<:AGraph}(cint::T, cext::T, n::Vector{Int},
        ::Type{G}=Graph; seed::Int=-1)
    K = length(n)
    c = [ifelse(a==b, cint, cext) for a=1:K,b=1:K]
    stochastic_block_model(c, n, G, seed=seed)
end
