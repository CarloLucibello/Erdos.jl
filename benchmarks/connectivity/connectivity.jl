s = BenchmarkGroup()
suite["connectivity"] = s

srand(1)
for G in GLIST
    for n in [100], d in [2,3]
        g = G(n , 5n, seed=1)
        s["neighborhood d=$d","$G-$n"] = @benchmarkable neighborhood($g, 1, $d)
    end
end
