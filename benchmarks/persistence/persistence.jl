s = BenchmarkGroup()
suite["persistence"] = s

fname, fio = mktemp()
close(fio)
srand(17)
for G in GLIST
    for n in [100_000]
        g = G(n, 10n, seed=1)
        s["write","gt","$g"] = @benchmarkable writegraph($fname, $g, :gt)
        s["write","gml","$g"] = @benchmarkable writegraph($fname, $g, :net)
        s["write","net","$g"] = @benchmarkable writegraph($fname, $g, :gml)
    end
end
