s = BenchmarkGroup()
suite["shortestpaths"] = s

fname, fio = mktemp()
close(fio)
srand(17)
for G in GLIST
    for n in [10_000]
        g = G(n, 5n, seed=1)
        s["dijkstra","$g"] = @benchmarkable dijkstra_shortest_paths($g, 1)
    end
end
