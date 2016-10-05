#tests for the concrete types Graph and DiGraph
gg = DiGraph(4)
add_edge!(gg, 1, 2)
add_edge!(gg, 1, 3)

g = reverse(gg)
@test ne(g) == ne(gg)
@test Edge(2,1) in edges(g)
@test !(Edge(1,2) in edges(g))
@test Edge(3,1) in edges(g)
@test !(Edge(1,3) in edges(g))

reverse!(g)
@test g == gg
