s = BenchmarkGroup()
suite["persistence"] = s

fname, fio = mktemp()
close(fio)
srand(17)
for G in GLIST
    for n in [10000]
        g = G(n, 10n, seed=1)
        s["write","gt","$g"] = @benchmarkable writegraph($(fname*".gt"), $g)
        s["write","net","$g"] = @benchmarkable writegraph($(fname*".net"), $g)
        s["write","gml","$g"] = @benchmarkable writegraph($(fname*".gml"), $g)
        s["write","graphml","$g"] = @benchmarkable writegraph($(fname*".graphml"), $g)
        s["write","gexf","$g"] = @benchmarkable writegraph($(fname*".gexf"), $g)

        s["read","gt","$g"] = @benchmarkable readgraph($(fname*".gt"), $G)
        s["read","net","$g"] = @benchmarkable readgraph($(fname*".net"), $G)
        s["read","gml","$g"] = @benchmarkable readgraph($(fname*".gml"), $G)
        s["read","graphml","$g"] = @benchmarkable readgraph($(fname*".graphml"), $G)
        s["read","gexf","$g"] = @benchmarkable readgraph($(fname*".gexf"), $G)
    end
end
