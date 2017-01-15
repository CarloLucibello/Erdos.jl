s = BenchmarkGroup()
suite["core"] = s

function b_edgeiter(g::ASimpleGraph)
    i = 0
    for e in edges(g)
        i += 1
    end
    return i
end

for G in GLIST
    for n in [100]
        g = CompleteGraph(n, G)
        s["edges","edge iter","fullyconn","$G-$n"] = @benchmarkable b_edgeiter($g)
    end
end

for G in DGLIST
    for n in [100]
        g = CompleteDiGraph(n , G)
        s["edges","edge iter","fullyconn","$G-$n"] = @benchmarkable b_edgeiter($g)
    end
end


for G in GLIST
    for n in [1000]
        g = random_regular_graph(n, 5, G)
        s["edges","edge iter","rrg","$G-$n"] = @benchmarkable b_edgeiter($g)
    end
end

for G in DGLIST
    for n in [1000]
        g = random_regular_digraph(n, 5, G)
        s["edges","edge iter","rrg","$G-$n"] = @benchmarkable b_edgeiter($g)
    end
end

function b_rem_vert(g::ASimpleGraph, vs)
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
        s["vertex","rem vert","fullyconn","$G-$n"] = @benchmarkable b_rem_vert($g, $vs100)
    end
end

for G in DGLIST
    for n in [100]
        g = CompleteDiGraph(n , G)
        s["vertex","rem vert","fullyconn","$G-$n"] = @benchmarkable b_rem_vert($g, $vs100)
    end
end

for G in GLIST
    for n in [1000]
        g = random_regular_graph(n, 5, G)
        s["vertex","rem vert","rrg","$G-$n"] = @benchmarkable b_rem_vert($g, $vs1000)
    end
end

for G in DGLIST
    for n in [1000]
        g = random_regular_digraph(n, 5, G)
        s["vertex","rem vert","rrg","$G-$n"] = @benchmarkable b_rem_vert($g, $vs1000)
    end
end
