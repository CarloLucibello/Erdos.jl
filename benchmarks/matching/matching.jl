s = BenchmarkGroup()
suite["matching"] = s

srand(17)
w = (w=sprand(100,100,0.2); w=w+w'; w-Diagonal(w))
g = Graph(w)
s["match n=100 p=0.2"] = @benchmarkable minimum_weight_perfect_matching($g, $(EdgeMap(g, w)))

w = (w=sprand(1000,1000,0.1); w=w+w'; w-Diagonal(w))
g = Graph(w)
s["match n=1000 p=0.1"] = @benchmarkable minimum_weight_perfect_matching($g, $(EdgeMap(g, w)))
