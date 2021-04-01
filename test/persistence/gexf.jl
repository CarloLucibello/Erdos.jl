@testset "$TEST $G" begin

f, fio = mktemp()

g = G(10,0)
writegraph(f, g, :gexf)
ga = readgraph(f, :gexf, G)
@test g == ga

g = G(10,20)
writegraph(f, g, :gexf)
ga = readgraph(f, :gexf, G)
@test g == ga

g = DG(10,20)
writegraph(f, g, :gexf)
ga = readgraph(f, :gexf, G)
@test g == ga

if G <: ANetwork ##################

g = readnetwork(joinpath(testdir, "testdata", "lesmis.gexf"), G)
writenetwork(f, g, :gexf)
h = readnetwork(f, :gexf, G)
test_networks_eq(g, h)

for gname in [:lesmis, :karate]
    g = readnetwork(gname, G)
    rem_gprop!(g, "readme") # TODO should strip characters " " in the readme string
    rem_gprop!(g, "description")
    rem_vprop!(g, "pos") # TODO vector attributes not supported
    writenetwork(f, g, :gexf)
    h = readnetwork(f, :gexf, G)
    test_networks_eq(g, h)
end

end #if network ####################

isfile(f) && rm(f)
 end #testset
