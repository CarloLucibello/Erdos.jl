suite["core"] = BenchmarkGroup()

s = BenchmarkGroup()
suite["core"]["edges"] = s
for t in ["fullyconn-1","fullyconn-2","rrg-1","rrg-2"]
    s[t] = BenchmarkGroup()
end


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
        s["fullyconn-1"]["$G-$n"] = @benchmarkable b1($g)
        s["fullyconn-2"]["$G-$n"] = @benchmarkable b2($g)
    end
end

for G in DGLIST
    for n in [100]
        g = CompleteDiGraph(n , G)
        s["fullyconn-1"]["$G-$n"] = @benchmarkable b1($g)
        s["fullyconn-2"]["$G-$n"] = @benchmarkable b2($g)
    end
end


for G in GLIST
    for n in [1000]
        g = random_regular_graph(n, 5, G)
        s["rrg-1"]["$G-$n"] = @benchmarkable b1($g)
        s["rrg-2"]["$G-$n"] = @benchmarkable b2($g)
    end
end

for G in DGLIST
    for n in [1000]
        g = random_regular_digraph(n, 5, G)
        s["rrg-1"]["$G-$n"] = @benchmarkable b1($g)
        s["rrg-2"]["$G-$n"] = @benchmarkable b2($g)
    end
end


s = BenchmarkGroup()
for t in ["fullyconn","rrg"]
    s[t] = BenchmarkGroup()
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
        s["fullyconn"]["$G-$n"] = @benchmarkable b_rem_vert($g, $vs100)
    end
end

for G in DGLIST
    for n in [100]
        g = CompleteDiGraph(n , G)
        s["fullyconn"]["$G-$n"] = @benchmarkable b_rem_vert($g, $vs100)
    end
end

for G in GLIST
    for n in [1000]
        g = random_regular_graph(n, 5, G)
        s["rrg"]["$G-$n"] = @benchmarkable b_rem_vert($g, $vs1000)
    end
end

for G in DGLIST
    for n in [1000]
        g = random_regular_digraph(n, 5, G)
        s["rrg"]["$G-$n"] = @benchmarkable b_rem_vert($g, $vs1000)
    end
end
