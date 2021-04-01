@testset "$TEST $G" begin

f,fio = mktemp()

p1 = readgraph(joinpath(testdir,"testdata","tutte.gml"), G)

@test_throws ErrorException writegraph("file1.ciao", G())
@test_throws ErrorException readgraph("file.ciao", G)
if G <: ANetwork
    @test_throws ErrorException writenetwork("file2.ciao", G())
    @test_throws ErrorException readnetwork("file.ciao", G)
end
@test_throws ErrorException Erdos.NI() # not implemented fallback

# test :gml
p = readgraph(joinpath(testdir,"testdata","tutte.gml"), G)
g = graph(:tutte, G)
@test p == g

gml1 = readgraph(joinpath(testdir,"testdata", "twographs-10-28.gml"), G)
@test nv(gml1) == 10
@test ne(gml1) == 28
writegraph(f, gml1, :gml)
gml1a = readgraph(f, :gml, G)
@test gml1a == gml1

gml1 = readgraph(joinpath(testdir,"testdata", "twounnamedgraphs.gml"), G)
@test typeof(gml1) == G
@test nv(gml1) == 4
@test ne(gml1) == 6
writegraph(f, gml1, :gml)
gml1a = readgraph(f, :gml, G)
@test gml1a == gml1

g = G(10,0)
writegraph(f, g, :gml)
ga = readgraph(f, :gml, G)
@test g == ga

g = G(10,20)
writegraph(f, g, :gml) == 1
ga = readgraph(f, :gml, G)
@test g == ga

g = DG(10,20)
writegraph(f, g, :gml)
ga = readgraph(f, :gml, G)
@test g == ga

# test :dot
# g = readgraph(joinpath(testdir, "testdata", "twographs.dot"), G)
# @test g == CompleteGraph(6, G)
writegraph(f, g, :dot)
# ga = readgraph(f, :dot, G)
# @test g == ga

g = G(10,0)
writegraph(f, g, :dot)
# ga = readgraph(f, :dot, G)
# @test g == ga

g = G(10,20)
writegraph(f, g, :dot)
# ga = readgraph(f, :dot, G)
# @test g == ga

g = DG(10,20)
writegraph(f, g, :dot)
# ga = readgraph(f, :dot, G)
# @test g == ga

#test :net
g10 = CompleteGraph(10, G)
@test typeof(g10) == G

writegraph(f, g10, :net)
@test readgraph(f,:net, G) == g10
@test_throws ErrorException readgraph(f, G)

g10 = PathDiGraph(10, DG)
@test typeof(g10) == DG
writegraph(f, g10, :net)
@test readgraph(f,:net, G) == g10

g10 = PathDiGraph(10, DG)
writegraph(f, g10, :net)
@test readgraph(f,:net, G) == g10

writegraph(f, g10, :net, compress=true)
@test readgraph(f,:net, G, compressed=true) == g10

fname = joinpath(f * ".net.gz")
writegraph(fname, g10)
@test readgraph(fname, G) == g10
rm(fname)

g10 = readgraph(joinpath(testdir, "testdata", "kinship.net"), G)
@test nv(g10) == 6
@test ne(g10) == 8

g = G(10,0)
writegraph(f, g, :net)
ga = readgraph(f, :net, G)
@test g == ga

g = G(10,20)
writegraph(f, g, :net)
ga = readgraph(f, :net, G)
@test g == ga

g = DG(10,20)
writegraph(f, g, :net)
ga = readgraph(f, :net, G)
@test g == ga

isfile(f) && rm(f)
 end #testset
