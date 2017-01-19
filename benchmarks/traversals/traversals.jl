s = BenchmarkGroup()
suite["traversals"] = s

g = DiGraph(10_000,100_000, seed=1)
s["minimum cut"] = @benchmarkable minimum_cut($g)
