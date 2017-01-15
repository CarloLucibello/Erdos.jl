s = BenchmarkGroup()
suite["generators"] = s

k=3; seed=17
for n in [100,1000], G in GLIST
    s["rrg","$G-$n"] = @benchmarkable random_regular_graph($n, $k, $G, seed=$seed)
    s["erdos","$G-$n"] = @benchmarkable erdos_renyi($n, $k, $G, seed=$seed)
end
