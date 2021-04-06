s = BenchmarkGroup()
suite["centrality"] = s

Random.seed!(1)
for G in DGLIST
    for n in [100, 200]
        g = G(n , 10n, seed=1)
        s["pagerank","$g"] = @benchmarkable pagerank($g)
    end
end

for G in DGLIST
    for n in [50, 100]
        g = G(n , 5n, seed=1)
        s["betweenness_centrality","$g"] = @benchmarkable betweenness_centrality($g)
    end
end
