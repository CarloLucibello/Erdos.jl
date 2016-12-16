suite["generators"] = BenchmarkGroup()

n=10; k=3; seed=17
suite["generators"]["rrg1"] = @benchmarkable random_regular_graph($n, $k, seed=$seed)
suite["generators"]["erdos1"] = @benchmarkable erdos_renyi($n, $k, seed=$seed)

n=100; k=3; seed=17
suite["generators"]["rrg2"] = @benchmarkable random_regular_graph($n, $k, seed=$seed)
suite["generators"]["erdos2"] = @benchmarkable erdos_renyi($n, $k, seed=$seed)

n=1000; k=3; seed=17
suite["generators"]["rrg3"] = @benchmarkable random_regular_graph($n, $k, seed=$seed)
suite["generators"]["erdos3"] = @benchmarkable erdos_renyi($n, $k, seed=$seed)
