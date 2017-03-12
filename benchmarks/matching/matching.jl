s = BenchmarkGroup()
suite["matching"] = s

srand(17)
n = 100
p = 0.2
w = (w=sprand(n,n,p); w=w+w'; w-Diagonal(w))
g = Graph(w)
s["match n=$n p=$p"] = @benchmarkable minimum_weight_perfect_matching($g, $(EdgeMap(g, w)))


n = 300
p = 0.1
w = (w=sprand(n,n,p); w=w+w'; w-Diagonal(w))
g = Graph(w)
s["match n=$n p=$p"] = @benchmarkable minimum_weight_perfect_matching($g, $(EdgeMap(g, w)))
