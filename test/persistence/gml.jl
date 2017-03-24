@testset "$TEST $G" begin

(f,fio) = mktemp()

p = readgraph(joinpath(testdir,"testdata","tutte.gml"), G)
g = graph(:tutte, G)
@test p == g

gml1 = readgraph(joinpath(testdir,"testdata", "twographs-10-28.gml"), G)
@test nv(gml1) == 10
@test ne(gml1) == 28
@test writegraph(f, gml1, :gml) == 1
gml1a = readgraph(f, :gml, G)
@test gml1a == gml1

gml1 = readgraph(joinpath(testdir,"testdata", "twounnamedgraphs.gml"), G)
@test typeof(gml1) == G
@test nv(gml1) == 4
@test ne(gml1) == 6
@test writegraph(f, gml1, :gml) == 1
gml1a = readgraph(f, :gml, G)
@test gml1a == gml1

g = G(10,0)
@test writegraph(f, g, :gml) == 1
ga = readgraph(f, :gml, G)
@test g == ga

g = G(10,20)
@test writegraph(f, g, :gml) == 1
ga = readgraph(f, :gml, G)
@test g == ga

g = DG(10,20)
@test writegraph(f, g, :gml) == 1
ga = readgraph(f, :gml, G)
@test g == ga

if G <: ANetwork ##################

g = readnetwork(joinpath(testdir, "testdata", "testnet.gml"), G)
writenetwork(f, g, :gml)
h = readnetwork(f, :gml, G)
test_networks_eq(g, h)

for gname in [:lesmis, :karate]
    g = readnetwork(gname, G)
    rem_gprop!(g, "readme") # TODO should strip characters " " in the readme string
    rem_vprop!(g, "pos") # TODO vector attributes not supported
    writenetwork(f, g, :gml)
    h = readnetwork(f, :gml, G)
    test_networks_eq(g, h)
end

end #if network ####################

 end #testset
