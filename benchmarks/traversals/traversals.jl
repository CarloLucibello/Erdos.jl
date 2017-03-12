s = BenchmarkGroup()
suite["traversals"] = s

g = DiGraph(1000,5000, seed=1)
s["minimum cut"] = @benchmarkable minimum_cut($g)
