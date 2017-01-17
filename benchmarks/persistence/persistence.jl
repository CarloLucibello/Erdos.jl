s = BenchmarkGroup()
suite["persistence"] = s

fname, fio = mktemp()
close(fio)
for G in GLIST
    for n in [100_000]
        g = G(n, 10n, seed=1)
        s["write","gt","$G-$n"] = @benchmarkable writegraph($fname, $g, :gt)
        s["write","gml","$G-$n"] = @benchmarkable writegraph($fname, $g, :NET)
        s["write","NET","$G-$n"] = @benchmarkable writegraph($fname, $g, :gml)
    end
end
