(f,fio) = mktemp()

# test :graphml
@test writegraph(f, p1, :graphml) == 1
graphml_g = readgraph(joinpath(testdir, "testdata", "grafo1853.13.graphml"), :graphml)
@test nv(graphml_g) == 13
@test ne(graphml_g) == 15

# test :gml
gml1 = readgraph(joinpath(testdir,"testdata", "twographs-10-28.gml"), :gml)
@test nv(gml1) == 10
@test ne(gml1) == 28
@test writegraph(f, gml1, :gml) == 1
gml1a = readgraph(f, :gml)
@test gml1a == gml1

gml1 = readgraph(joinpath(testdir,"testdata", "twounnamedgraphs.gml"), :gml)
@test nv(gml1) == 4
@test ne(gml1) == 6
@test writegraph(f, gml1, :gml) == 1
gml1a = readgraph(f, :gml)
@test gml1a == gml1

# test :dot
g = readgraph(joinpath(testdir, "testdata", "twographs.dot"), :dot)
@test g == CompleteGraph(6)
@test writegraph(f, g, :gml) == 1
ga = readgraph(f, :gml)
@test g == ga

# test :gexf
@test writegraph(f, p1, :gexf) == 1
@test_throws ErrorException readgraph(STDIN, :gexf)

#test :NET
g10 = CompleteGraph(10)
fname,fio = mktemp()
close(fio)
@test writegraph(fname, g10, :NET) == 1
@test readgraph(fname,:NET) == g10
rm(fname)

g10 = PathDiGraph(10)
@test writegraph(fname, g10, :NET) == 1
@test readgraph(fname,:NET) == g10
rm(fname)

g10 = readgraph(joinpath(testdir, "testdata", "kinship.net"), :NET)
@test nv(g10) == 6
@test ne(g10) == 8

using JLD

function write_readback(path::String, g)
    jldfile = jldopen(path, "w")
    jldfile["g"] = g
    close(jldfile)

    jldfile = jldopen(path, "r")
    gs = read(jldfile, "g")
    return gs
end

function testjldio(path::String, g::Graph)
    gs = write_readback(path, g)
    gloaded = Graph(gs)
    @test gloaded == g
end

graphs = [PathGraph(10), CompleteGraph(5), WheelGraph(7)]
for (i,g) in enumerate(graphs)
    path = joinpath(testdir,"testdata", "test.$i.jld")
    testjldio(path, g)
    #delete the file (it gets left on test failure so you could debug it)
    rm(path)
end
