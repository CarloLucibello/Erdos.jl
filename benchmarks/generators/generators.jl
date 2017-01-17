s = BenchmarkGroup()
suite["generators"] = s

k=3; seed=17
for n in [100,1000], G in GLIST
    g = random_regular_graph(n, k, G, seed=seed)
    s["rrg","$g"] = @benchmarkable random_regular_graph($n, $k, $G, seed=$seed)

    g = erdos_renyi(n, k*n, G, seed=seed)
    s["erdos","$g"] = @benchmarkable erdos_renyi($n, $(k*n), $G, seed=$seed)
end
