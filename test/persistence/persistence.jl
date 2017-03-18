@testset "$TEST $G" begin

(f,fio) = mktemp()

p1 = readgraph(joinpath(testdir,"testdata","tutte.gml"), G)

@test_throws ErrorException writegraph("file.ciao", G())
@test_throws ErrorException writenetwork("file.ciao", G())

# test :gml
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

# test :dot
g = readgraph(joinpath(testdir, "testdata", "twographs.dot"), G)
@test g == CompleteGraph(6, G)
@test writegraph(f, g, :dot) == 1
ga = readgraph(f, :dot, G)
@test g == ga

g = G(10,0)
@test writegraph(f, g, :dot) == 1
ga = readgraph(f, :dot, G)
@test g == ga

g = G(10,20)
@test writegraph(f, g, :dot) == 1
ga = readgraph(f, :dot, G)
@test g == ga

g = DG(10,20)
@test writegraph(f, g, :dot) == 1
ga = readgraph(f, :dot, G)
@test g == ga

# test :gexf
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

#test :net
g10 = CompleteGraph(10, G)
@test typeof(g10) == G

fname,fio = mktemp()
close(fio)
@test writegraph(fname, g10, :net) == 1
@test readgraph(fname,:net, G) == g10
@test_throws ErrorException readgraph(fname, G)
rm(fname)

g10 = PathDiGraph(10, DG)
@test typeof(g10) == DG
@test writegraph(fname, g10, :net) == 1
@test readgraph(fname,:net, G) == g10
rm(fname)

g10 = PathDiGraph(10, DG)
@test writegraph(fname, g10, :net) == 1
@test readgraph(fname,:net, G) == g10
rm(fname)

@test writegraph(fname, g10, :net, compress=true) == 1
@test readgraph(fname,:net, G, compressed=true) == g10
rm(fname)

fname = joinpath(fname * ".net.gz")
@test writegraph(fname, g10) == 1
@test readgraph(fname, G) == g10
rm(fname)

g10 = readgraph(joinpath(testdir, "testdata", "kinship.net"), G)
@test nv(g10) == 6
@test ne(g10) == 8

g = G(10,0)
@test writegraph(f, g, :net) == 1
ga = readgraph(f, :net, G)
@test g == ga

g = G(10,20)
@test writegraph(f, g, :net) == 1
ga = readgraph(f, :net, G)
@test g == ga

g = DG(10,20)
@test writegraph(f, g, :net) == 1
ga = readgraph(f, :net, G)
@test g == ga

 end #testset
