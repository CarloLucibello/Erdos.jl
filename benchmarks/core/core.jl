s = BenchmarkGroup()
suite["core"] = s

function b_edgeiter(g::AGraphOrDiGraph)
    i = 0
    for e in edges(g)
        i += 1
    end
    return i
end

for G in GLIST
    for n in [100]
        g = CompleteGraph(n, G)
        s["edges","edge iter","fullyconn","$g"] = @benchmarkable b_edgeiter($g)
    end
end

for G in DGLIST
    for n in [100]
        g = CompleteDiGraph(n , G)
        s["edges","edge iter","fullyconn","$g"] = @benchmarkable b_edgeiter($g)
    end
end


for G in GLIST
    for n in [1000]
        g = random_regular_graph(n, 5, G)
        s["edges","edge iter","rrg","$g"] = @benchmarkable b_edgeiter($g)
    end
end

for G in DGLIST
    for n in [1000]
        g = random_regular_digraph(n, 5, G)
        s["edges","edge iter","rrg","$g"] = @benchmarkable b_edgeiter($g)
    end
end

function b_rem_vert(g::AGraphOrDiGraph, vs)
    for v in vs
        rem_vertex!(g, v)
    end
end

srand(17)
n=100
vs100 = [rand(1:n-i+1) for i=1:n÷4]
n=1000
vs1000 = [rand(1:n-i+1) for i=1:n÷4]
for G in GLIST
    for n in [100]
        g = CompleteGraph(n, G)
        s["vertex","rem vert","fullyconn","$g"] = @benchmarkable b_rem_vert($g, $vs100)
    end
end

for G in DGLIST
    for n in [100]
        g = CompleteDiGraph(n , G)
        s["vertex","rem vert","fullyconn","$g"] = @benchmarkable b_rem_vert($g, $vs100)
    end
end

for G in GLIST
    for n in [1000]
        g = random_regular_graph(n, 5, G)
        s["vertex","rem vert","rrg","$g"] = @benchmarkable b_rem_vert($g, $vs1000)
    end
end

for G in DGLIST
    for n in [1000]
        g = random_regular_digraph(n, 5, G)
        s["vertex","rem vert","rrg","$g"] = @benchmarkable b_rem_vert($g, $vs1000)
    end
end
