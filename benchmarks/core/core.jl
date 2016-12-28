suite["core"] = BenchmarkGroup()

s = BenchmarkGroup()
suite["core"]["edges"] = s

function b1(g::ASimpleGraph)
    i = 0
    for e in edges(g)
        i += 1
    end
    return i
end

function b2(g::ASimpleGraph)
    i = 0
    for e in out_edges(g, 1)
        i += 1
    end
    return i
end

for G in GLIST
    for n in [100]
        g = CompleteGraph(n, G)
        s["fullyconn-$G-$n-1"] = @benchmarkable b1($g)
        s["fullyconn-$G-$n-2"] = @benchmarkable b2($g)
    end
end

for G in DGLIST
    for n in [100]
        g = CompleteDiGraph(n , G)
        s["fullyconn-$G-$n-1"] = @benchmarkable b1($g)
        s["fullyconn-$G-$n-2"] = @benchmarkable b2($g)
    end
end


for G in GLIST
    for n in [1000]
        g = random_regular_graph(n, 5, G)
        s["rrg-$G-$n-1"] = @benchmarkable b1($g)
        s["rrg-$G-$n-2"] = @benchmarkable b2($g)
    end
end

for G in DGLIST
    for n in [1000]
        g = random_regular_digraph(n, 5, G)
        s["rrg-$G-$n-1"] = @benchmarkable b1($g)
        s["rrg-$G-$n-2"] = @benchmarkable b2($g)
    end
end
