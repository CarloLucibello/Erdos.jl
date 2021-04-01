@testset "$TEST $G" begin

f,fio = mktemp()

p1 = readgraph(joinpath(testdir,"testdata","tutte.gml"), G)

writegraph(f, p1, :graphml)
g = readgraph(f, :graphml, G)
@test g == p1
graphml_g = readgraph(joinpath(testdir, "testdata", "grafo1853.13.graphml"), G)
@test nv(graphml_g) == 13
@test ne(graphml_g) == 15

g = G(10,0)
writegraph(f, g, :graphml)
ga = readgraph(f, :graphml, G)
@test g == ga

g = G(10,20)
writegraph(f, g, :graphml)
ga = readgraph(f, :graphml, G)
@test g == ga

g = DG(10,20)
writegraph(f, g, :graphml)
ga = readgraph(f, :graphml, G)
@test g == ga

if G <: ANetwork ##################

g = readnetwork(:lesmis, G)
h = readnetwork(joinpath(testdir, "testdata", "lesmis.graphml.gz"), G)
test_networks_eq(g, h)

for gname in [:lesmis, :karate]
    g = readnetwork(gname, G)
    writenetwork(f, g, :graphml)
    h = readnetwork(f, :graphml, G)
    test_networks_eq(g, h)
end

end #if network ############################

isfile(f) && rm(f)
end #testset
