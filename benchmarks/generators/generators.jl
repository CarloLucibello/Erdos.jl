s = BenchmarkGroup()
suite["generators"] = s

srand(17)
k=3; seed=17
for n in [100,500], G in GLIST
    g = random_regular_graph(n, k, G, seed=seed)
    s["rrg","$g"] = @benchmarkable random_regular_graph($n, $k, $G, seed=$seed)

    g = erdos_renyi(n, k*n, G, seed=seed)
    s["erdos","$g"] = @benchmarkable erdos_renyi($n, $(k*n), $G, seed=$seed)
end

for n in [20,100], G in GLIST
    g = CompleteGraph(n, G)
    s["complete","$g"] = @benchmarkable CompleteGraph($n, $G)

    g = CompleteDiGraph(n, digraphtype(G))
    s["complete","$g"] = @benchmarkable CompleteDiGraph($n, $(digraphtype(G)))
end
