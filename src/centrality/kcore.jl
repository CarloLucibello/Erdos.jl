"""
    cores(g)

Returns a vector `deg` such that if `deg[v]=k` then the vertex `v`
belongs to the `k`-core of `g` and not to the `k+1`-core.

See also [`kcore`](@ref).
"""
function cores(g::AGraph)
    n = nv(g)
    deg = degree(g)
    md = maximum(deg)
    bin = zeros(Int, md+1)
    for v=1:n
        bin[deg[v]+1] += 1
    end

    start = 1;
    for d=1:md+1
        num = bin[d]
        bin[d] = start
        start += num
    end
    #now bin[d+1] contains the position in vert of the first v with degree d

    #sort array vert according to degree and track their position in pos
    pos = zeros(Int, n)
    vert = zeros(Int, n)
    for v=1:n
        pos[v] = bin[deg[v]+1]
        vert[pos[v]] = v
        bin[deg[v]+1] += 1
    end

    # bring back bin to stating positions
    for d=md+1:-1:2
        bin[d] = bin[d-1]
    end
    bin[1] = 1

    #the main part of the algorithm
    for i=1:n
        v = vert[i]
        for u in neighbors(g, v)
            if deg[u] > deg[v] #move u one bin left
                du = deg[u]
                pu = pos[u]
                pw = bin[du+1]
                w = vert[pw]
                if u != w
                    pos[u], pos[w] = pw, pu
                    vert[pu], vert[pw] = w, u
                end
                bin[du+1] += 1
                deg[u] -= 1
            end
        end
    end
    return deg
end

"""
    kcore(g, k) -> (gnew, vmap)

Returns the `k`-core  of `g` along with a vertex map associating the mutated vertex
indexes to the old ones (as in [`rem_vertices!`](@ref)).

See also [`cores`](@ref)
"""
function kcore(g::AGraph, k::Integer)
    #TODO use subgraph
    gnew = copy(g)
    vmap = rem_vertices!(gnew, findall(d -> d < k, cores(g)))
    return gnew, vmap
end
