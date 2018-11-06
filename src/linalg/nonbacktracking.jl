import Base: size

"""
    nonbacktracking_matrix(g)
Return a non-backtracking matrix `B` and an edgemap storing the oriented
edges' positions in `B`.
Given two arcs ``A_{i j}` and `A_{k l}` in `g`, the
non-backtraking matrix ``B`` is defined as
``B_{A_{i j}, A_{k l}} = δ_{j k} * (1 - δ_{i l})``
"""
function nonbacktracking_matrix(g::AGraph)
    E = edgetype(g)
    edgeidmap = Dict{E,Int}()
    m = 0
    for e in edges(g)
        m += 1
        edgeidmap[e] = m
    end

    if !is_directed(g)
        for e in edges(g)
            m += 1
            edgeidmap[reverse(e)] = m
        end
    end

    B = zeros(Float64, m, m)

    for (e, u) in edgeidmap
        i, j = src(e), dst(e)
        for e in in_edges(g, i)
            k = src(e)
            k == j && continue
            v = edgeidmap[e]
            B[v, u] = 1
        end
    end

    return B, edgeidmap
end