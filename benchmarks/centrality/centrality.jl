suite["centrality"] = BenchmarkGroup()

s = BenchmarkGroup()
suite["centrality"]["pagerank"] = s

for G in DGLIST
    for n in [100, 1000]
        g = DiGraph(n , 10n, seed=1)
        s["$G-$n-1"] = @benchmarkable pagerank($g)
    end
end
