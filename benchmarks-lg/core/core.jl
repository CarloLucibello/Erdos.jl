suite["core"] = BenchmarkGroup()

s = BenchmarkGroup()
suite["core"]["edges"] = s

function b1(g)
    i = 0
    for e in edges(g)
        i += 1
    end
    return i
end

for G in GLIST
    for n in [10,100]
        g = CompleteGraph(n)
        s["fullyconn-$G-$n"] = @benchmarkable b1($g)
    end
end

for G in DGLIST
    for n in [10,100]
        g = CompleteDiGraph(n)
        s["fullyconn-$G-$n"] = @benchmarkable b1($g)
    end
end
