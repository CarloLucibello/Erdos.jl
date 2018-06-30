s = BenchmarkGroup()
suite["flow"] = s

edgs = [
  (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
  (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
  (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
]

flow_graph = DiGraph(8)
capacity_matrix = zeros(Int,8,8)
for e in edgs
    u,v,f = e
    add_edge!(flow_graph,u,v)
    capacity_matrix[u,v] = f
end

s["push_relabel","$flow_graph"] = @benchmarkable maximum_flow($flow_graph, 1, 8
                    , $capacity_matrix, algorithm=PushRelabelAlgorithm())
s["dinic","$flow_graph"] = @benchmarkable maximum_flow($flow_graph, 1, 8
                    , $capacity_matrix, algorithm=DinicAlgorithm())

s["boykov","$flow_graph"] = @benchmarkable maximum_flow($flow_graph, 1, 8
                    , $capacity_matrix, algorithm=BoykovKolmogorovAlgorithm())

# from LittleScienceTools.RFIM
srand(17)
N = 200
g = random_regular_graph(N, 3, seed=1)
h = randn(N)
J = 1.

function net_capacity(g::AGraph, h::Vector{T}, J::AbstractFloat) where T
    N = nv(g)
    dg = digraph(g)
    add_vertices!(dg, 2)
    source = N+1
    target = N+2
    for i=1:N
        if h[i] > 0
            add_edge!(dg, source, i)
            add_edge!(dg, i, source)
        else
            add_edge!(dg, i, target)
            add_edge!(dg, target, i)
        end
    end

    c = spzeros(N+2, N+2)
    for i=1:N
        neigs = neighbors(dg, i)
        for j in neigs
            if j <= N
                c[i,j] = J
            elseif j == target
                c[i,j] = abs(h[i])
            end

        end
    end
    for j in neighbors(dg, source)
        c[source,j] = abs(h[j])
    end

    return dg, c
end

dg, c = net_capacity(g, h, J)

s["push_relabel","$dg"] = @benchmarkable maximum_flow($dg, $(N+1), $(N+2)
                    , $c, algorithm=PushRelabelAlgorithm())
s["dinic","$dg"] = @benchmarkable maximum_flow($dg, $(N+1), $(N+2)
                    , $c, algorithm=DinicAlgorithm())
s["boykov","$dg"] = @benchmarkable maximum_flow($dg, $(N+1),$(N+2)
                    , $c, algorithm=BoykovKolmogorovAlgorithm())
