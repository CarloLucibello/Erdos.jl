s = BenchmarkGroup()
suite["centrality"] = s

srand(1)
for G in DGLIST
    for n in [100, 1000]
        g = G(n , 10n, seed=1)
        s["pagerank","$G-$n"] = @benchmarkable pagerank($g)
    end
end
