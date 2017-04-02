@testset "$TEST $G" begin

f, fio = mktemp()


g = G(10,20)
gpath = joinpath(testdir,"testdata","gtest.gt.gz")
writegraph(gpath, g)
h = readgraph(gpath, :gt, G, compressed=true)
@test h == g
h = readgraph(gpath, G)
@test h == g
if G <: ANetwork
    vprop!(g, "w", rand(nv(g)))
    writenetwork(gpath, g)
    h = readnetwork(gpath, :gt, G, compressed=true)
    test_networks_eq(h, g)
    h = readnetwork(gpath, G)
    test_networks_eq(h, g)
end
rm(gpath)

g = DG(10,20)
gpath = joinpath(testdir,"testdata","gtest.gt.gz")
writegraph(gpath, g)
h = readgraph(gpath, :gt, G, compressed=true)
@test h == g
h = readgraph(gpath, G)
@test h == g
if G <: ANetwork
    vprop!(g, "w", rand(nv(g)))
    eprop!(g, "w", EdgeMap(g, rand(ne(g)))) #TODO

    writenetwork(gpath, g)
    h = readnetwork(gpath, :gt, G, compressed=true)
    test_networks_eq(h, g)
    h = readnetwork(gpath, G)
    test_networks_eq(h, g)
end
rm(gpath)

g = readgraph(:lesmis, G)
@test typeof(g) == G
@test nv(g) == 77
@test ne(g) == 254

@test writegraph(f, g, :gt) == 1
h = readgraph(f, :gt, G)
@test g == h

g = readgraph(:serengetifoodweb, G)
@test typeof(g) == DG
@test nv(g) == 161
@test ne(g) == 592

@test writegraph(f, g, :gt) == 1
h = readgraph(f, :gt, G)
@test g == h


g = G(10,0)
@test writegraph(f, g, :gt) == 1
ga = readgraph(f, :gt, G)
@test g == ga

g = G(10,20)
@test writegraph(f, g, :gt) == 1
ga = readgraph(f, :gt, G)
@test g == ga

g = DG(10,20)
@test writegraph(f, g, :gt) == 1
ga = readgraph(f, :gt, G)
@test g == ga

if G <: ANetwork ##############################

g = readnetwork(:karate, G)
@test sort(gprop_names(g)) == ["description","readme"]
@test sort(vprop_names(g)) == ["pos"]
@test sort(eprop_names(g)) == []

writenetwork(f, g, :gt)
h = readnetwork(f, :gt, G)
@test h == g
@test h.props == g.props

g = readnetwork(:lesmis)
@test sort(gprop_names(g)) == ["description","readme"]
@test sort(vprop_names(g)) == ["label","pos"]
@test sort(eprop_names(g)) == ["value"]

writenetwork(f, g, :gt)
h = readnetwork(f, :gt, G)
@test h == g
# @test h.props == g.props #dataset graphs' edges index can change
writenetwork(f, h, :gt)
h2 = readnetwork(f, :gt, G)
@test h == h2
@test h.props == h2.props

end #if network ####################


isfile(f) && rm(f)
 end #testset
