s = BenchmarkGroup()
suite["persistence"] = s

fname = joinpath(bench_dir,"data","benchgraph_")
Random.seed!(17)
for G in GLIST
    for n in [100]
        g = G(n, 5n, seed=1)
        s["write","gt","$g"] = @benchmarkable writegraph($(fname*"$n.gt"), $g)
        s["write","net","$g"] = @benchmarkable writegraph($(fname*"$n.net"), $g)
        s["write","gml","$g"] = @benchmarkable writegraph($(fname*"$n.gml"), $g)
        s["write","dot","$g"] = @benchmarkable writegraph($(fname*"$n.dot"), $g)
        s["write","graphml","$g"] = @benchmarkable writegraph($(fname*"$n.graphml"), $g)
        s["write","gexf","$g"] = @benchmarkable writegraph($(fname*"$n.gexf"), $g)

        s["read","gt","$g"] = @benchmarkable readgraph($(fname*"$n.gt"), $G)
        s["read","net","$g"] = @benchmarkable readgraph($(fname*"$n.net"), $G)
        # s["read","gml","$g"] = @benchmarkable readgraph($(fname*"$n.gml"), $G) #SLOW
        # s["read","dot","$g"] = @benchmarkable readgraph($(fname*"$n.dot"), $G) #SLOW
        s["read","graphml","$g"] = @benchmarkable readgraph($(fname*"$n.graphml"), $G)
        s["read","gexf","$g"] = @benchmarkable readgraph($(fname*"$n.gexf"), $G)
    end
end
