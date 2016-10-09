@test length(collect(edges(Graph()))) == 0

ga = Graph(10,20; seed=1)
gb = Graph(10,20; seed=1)

@test length(collect(edges(ga))) == 20
@test collect(edges(ga)) == collect(edges(gb))
for e in edges(ga)
    @test has_edge(ga, e)
end
@test length(unique(collect(edges(ga)))) == 20

ga = DiGraph(10,20; seed=1)
gb = DiGraph(10,20; seed=1)

@test length(collect(edges(ga))) == 20
@test collect(edges(ga)) == collect(edges(gb))
for e in edges(ga)
    @test has_edge(ga, e)
end
@test length(unique(collect(edges(ga)))) == 20


ga = Graph(10)
add_edge!(ga, 3, 2)
add_edge!(ga, 3, 10)
add_edge!(ga, 5, 10)
add_edge!(ga, 10, 3)

eit = edges(ga)
# es = start(eit)
#
# @test es.s == 2
# @test es.di == 1

@test [e for e in eit] == [Edge(2, 3), Edge(3, 10), Edge(5,10)]

ga = DiGraph(10)
add_edge!(ga, 3, 2)
add_edge!(ga, 3, 10)
add_edge!(ga, 5, 10)
add_edge!(ga, 10, 3)

eit = edges(ga)
# es = start(eit)
#
# @test es.s == 3
# @test es.di == 1

@test [e for e in eit] == [Edge(3, 2), Edge(3, 10), Edge(5,10), Edge(10,3)]

g = CompleteGraph(10)
@test collect(edges(g,1:3)) == collect(edges(g,[1:3;]))
@test length(collect(edges(g, 1:3))) == 3
@test length(collect(edges(g, 1:0))) == 0


g = CompleteDiGraph(10)
@test collect(edges(g,1:3)) == collect(edges(g,[1:3;]))
@test length(collect(edges(g, 1:3))) == 6
@test length(collect(edges(g, 1:0))) == 0
