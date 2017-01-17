s = BenchmarkGroup()
suite["dismantling"] = s

srand(1)
for G in GLIST
    for n in [100]
        l = 2
        g = G(n , 5n, seed=1)
        s["ci l=$l","$g"] = @benchmarkable dismantle_ci($g, $l, $(n÷4))
    end
end
