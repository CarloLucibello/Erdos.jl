@testset "$TEST $G" begin

@test length(collect(edges(G()))) == 0

ga = G(10,20; seed=1)
gb = G(10,20; seed=1)

@test length(collect(edges(ga))) == 20
@test collect(edges(ga)) == collect(edges(gb))
for e in edges(ga)
    @test has_edge(ga, e)
end
@test length(unique(collect(edges(ga)))) == 20

ga = erdos_renyi(10,20, G; seed=1)
gb = erdos_renyi(10,20, DG; seed=1)

@test length(collect(edges(ga))) == length(edges(ga)) == ne(ga)
@test length(collect(edges(gb))) == length(edges(gb)) == ne(gb)

for e in edges(ga)
    @test has_edge(ga, e)
end
@test length(unique(collect(edges(ga)))) == 20


ga = G(10)
add_edge!(ga, 3, 2)
add_edge!(ga, 3, 10)
add_edge!(ga, 5, 10)
add_edge!(ga, 10, 3)

eit = edges(ga)
@test Base.IteratorSize(typeof(eit)) == Base.HasLength()
i = 0
for e in eit
    @test src(e) <= dst(e)
    i += 1
end
@test i == ne(ga)

@test [e for e in eit] == [E(2, 3), E(3, 10), E(5,10)]

ga = DG(10)
add_edge!(ga, 3, 2)
add_edge!(ga, 3, 10)
add_edge!(ga, 5, 10)
add_edge!(ga, 10, 3)

eit = edges(ga)

@test [e for e in eit] == [E(3, 2), E(3, 10), E(5,10), E(10,3)]
@test collect(eit) == [e for e in eit]
# g = CompleteGraph(10)
# @test collect(edges(g,1:3)) == collect(edges(g,[1:3;]))
# @test length(collect(edges(g, 1:3))) == 3
# @test length(collect(edges(g, 1:0))) == 0
#
#
# g = CompleteDiGraph(10)
# @test collect(edges(g,1:3)) == collect(edges(g,[1:3;]))
# @test length(collect(edges(g, 1:3))) == 6
# @test length(collect(edges(g, 1:0))) == 0

end # testset
