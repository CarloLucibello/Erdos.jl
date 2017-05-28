@testset "$TEST $G" begin
f,fio = mktemp()

g = DG(10,0)
@test writegraph(f, g, :gexf) == 1
h = readgraph(f, :gexf, G)
@test g == h

g = G(10,0)
@test writegraph(f, g, :gexf) == 1
ga = readgraph(f, :gexf, G)
@test g == ga

g = G(10,20)
@test writegraph(f, g, :gexf) == 1
ga = readgraph(f, :gexf, G)
@test g == ga

g = DG(10,20)
@test writegraph(f, g, :gexf) == 1
ga = readgraph(f, :gexf, G)
@test g == ga

g = readgraph(:lesmis, G)
h = readgraph(joinpath(testdir, "testdata", "lesmis.gexf"), G)
@test nv(g) == nv(h)
@test ne(g) == ne(h)

if G <: ANetwork
    g = readnetwork(joinpath(testdir, "testdata", "lesmis.gexf"), G)
    @test has_vprop(g, "label")
    vals = [vprop(g,"label")[i] for i=1:nv(g)]
    @test "Valjean" ∈ vals

    @test has_eprop(g, "weight")
    @test valtype(eprop(g, "weight")) <: Float64
    # @test length(eprop(g, "weight")) == ne(g)

    @test has_vprop(g, "size")
    @test has_vprop(g, "position")
    @test has_vprop(g, "color")

    @test writenetwork(f, g, :gexf) == 1
    h = readnetwork(f, :gexf, G)
    @test has_vprop(h, "label")
    vals = [vprop(h,"label")[i] for i=1:nv(g)]
    @test "Valjean" ∈ vals
    @test has_eprop(h, "weight")
    @test valtype(eprop(g, "weight")) <: Float64

end

end #testset
