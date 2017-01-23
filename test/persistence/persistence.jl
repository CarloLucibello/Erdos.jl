(f,fio) = mktemp()

p1 = readgraph(joinpath(testdir,"testdata","tutte.gml"),:gml, G)

# test :graphml
@test writegraph(f, p1, :graphml) == 1
graphml_g = readgraph(joinpath(testdir, "testdata", "grafo1853.13.graphml"), :graphml, G)
@test nv(graphml_g) == 13
@test ne(graphml_g) == 15


# test :gml
p = readgraph(joinpath(testdir,"testdata","tutte.gml"),:gml, G)
g = graph(:tutte, G)
@test p == g

gml1 = readgraph(joinpath(testdir,"testdata", "twographs-10-28.gml"), :gml, G)
@test nv(gml1) == 10
@test ne(gml1) == 28
@test writegraph(f, gml1, :gml) == 1
gml1a = readgraph(f, :gml, G)
@test gml1a == gml1

gml1 = readgraph(joinpath(testdir,"testdata", "twounnamedgraphs.gml"), :gml, G)
@test typeof(gml1) == G
@test nv(gml1) == 4
@test ne(gml1) == 6
@test writegraph(f, gml1, :gml) == 1
gml1a = readgraph(f, :gml, G)
@test gml1a == gml1

# test :dot
g = readgraph(joinpath(testdir, "testdata", "twographs.dot"), :dot, G)
@test g == CompleteGraph(6, G)
@test writegraph(f, g, :gml) == 1
ga = readgraph(f, :gml, G)
@test g == ga

# test :gt
fname= joinpath(datasets_dir, "lesmis.gt.gz")
g = readgraph(fname, :gt, G, compressed=true)
@test typeof(g) == G
@test nv(g) == 77
@test ne(g) == 254

@test writegraph(f, g, :gt) == 1
h = readgraph(f, :gt, G)
@test g == h

fname= joinpath(datasets_dir, "serengeti-foodweb.gt.gz")
g = readgraph(fname, :gt, G, compressed=true)
@test typeof(g) == DG
@test nv(g) == 161
@test ne(g) == 592

@test writegraph(f, g, :gt) == 1
h = readgraph(f, :gt, G)
@test g == h

# # TODO celegansneural appears corrupted
# fname= joinpath(datasets_dir, "celegansneural.gt.gz")
# g = readgraph(fname, :gt, G, compressed=true)
# @test typeof(g) == DG
# @test nv(g) == 297
# @test ne(g) == 2359

@test writegraph(f, g, :gt) == 1
h = readgraph(f, :gt, G)
@test g == h

# test :gexf
@test writegraph(f, p1, :gexf) == 1
@test_throws ErrorException readgraph(STDIN, :gexf, G)

#test :NET
g10 = CompleteGraph(10, G)
@test typeof(g10) == G
fname,fio = mktemp()
close(fio)
@test writegraph(fname, g10, :NET) == 1
@test readgraph(fname,:NET, G) == g10
rm(fname)

g10 = PathDiGraph(10, DG)
@test typeof(g10) == DG
@test writegraph(fname, g10, :NET) == 1
@test readgraph(fname,:NET, G) == g10
rm(fname)


g10 = PathDiGraph(10, DG)
@test writegraph(fname, g10, :NET) == 1
@test readgraph(fname,:NET, G) == g10
rm(fname)

@test writegraph(fname, g10, :NET, compress=true) == 1
@test readgraph(fname,:NET, G, compressed=true) == g10
rm(fname)

g10 = readgraph(joinpath(testdir, "testdata", "kinship.net"), :NET, G)
@test nv(g10) == 6
@test ne(g10) == 8
