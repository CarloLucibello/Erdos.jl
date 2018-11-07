@testset "$TEST $G" begin

g3 = PathDiGraph(3, DG)
complete!(g3)
@test ne(g3) == 4
@test nv(g3) == 3
@test has_edge(g3, 3, 2)
@test has_edge(g3, 2, 1)
@test g3 == complete(PathDiGraph(3, DG))

g3 = PathGraph(5, G)
g4 = PathDiGraph(5, DG)
g5 = DG(4)
add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)

h1 = G(5)
h2 = G(3)
h3 = G()
h4 = DG(7)
h5 = DG()

c3 = complement(g3)
c4 = complement(g4)

@test nv(c3) == 5
@test ne(c3) == 6
@test nv(c4) == 5
@test ne(c4) == 16

g = blockdiag(g3, g3)
@test nv(g) == 10
@test ne(g) == 8

h = PathGraph(2, G)
@test intersect(g3, h) == h

h = PathGraph(4, G)
z = difference(g3, h)
@test nv(z) == 5
@test ne(z) == 1
z = difference(h, g3)
@test nv(z) == 4
@test ne(z) == 0

z = symmetric_difference(h,g3)
@test z == symmetric_difference(g3,h)
@test nv(z) == 5
@test ne(z) == 1

h = G(6)
add_edge!(h, 5, 6)
e = E(5, 6)
z = union(g3, h)
@test has_edge(z, e)
@test z == PathGraph(6, G)

h = DG(6)
add_edge!(h, 5, 6)
e = E(5, 6)
z = union(g4, h)
@test has_edge(z, e)
@test z == PathDiGraph(6, DG)

g10 = CompleteGraph(2, G)
h10 = CompleteGraph(2, G)
z = blockdiag(g10, h10)
@test nv(z) == nv(g10) + nv(h10)
@test ne(z) == ne(g10) + ne(h10)
@test has_edge(z, 1, 2)
@test has_edge(z, 3, 4)
@test !has_edge(z, 1, 3)
@test !has_edge(z, 1, 4)
@test !has_edge(z, 2, 3)
@test !has_edge(z, 2, 4)

g10 = G(2)
h10 = G(2)
z = join(g10, h10)
@test nv(z) == nv(g10) + nv(h10)
@test ne(z) == 4
@test !has_edge(z, 1, 2)
@test !has_edge(z, 3, 4)
@test has_edge(z, 1, 3)
@test has_edge(z, 1, 4)
@test has_edge(z, 2, 3)
@test has_edge(z, 2, 4)

p = PathGraph(10, G)
x = p*ones(10)
@test  x[1]==1.0 && all(x[2:end-1].==2.0) && x[end]==1.0

@test size(p) == (10,10)
@test size(p, 1) == size(p, 2) == 10
@test size(p, 3) == 1


g5 = DG(4)
add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
@test g5 * ones(nv(g5)) == [2.0, 1.0, 1.0, 0.0]
@test sum(g5, 1) ==  [0, 1, 2, 1]
@test sum(g5, 2) ==  [2, 1, 1, 0]
@test sum(g5) == 4
@test sum(p,1) == sum(p,2)
@test_throws ErrorException sum(p,3)

@test sparse(p) == adjacency_matrix(p)
@test eltype(p) == vertextype(p)
@test length(p) == 100
@test ndims(p) == 2
@test issymmetric(p)
@test !issymmetric(g5)

g22 = CompleteGraph(2, G)
h = cartesian_product(g22, g22)
@test nv(h) == 4
@test ne(h)== 4

g22 = CompleteGraph(2, G)
h = tensor_product(g22, g22)
@test nv(h) == 4
@test ne(h) == 1

nx = 20; ny = 21
gg = PathGraph(nx, G)
hh = PathGraph(ny, G)
c = cartesian_product(gg, hh)
g = crosspath(PathGraph(nx, G), ny)
@test g == c

## test subgraphs ##

g = graph(:bull, G)
n = 3
h = g[1:n]
@test nv(h) == n
@test ne(h) == 3

h = g[[1,2,4]]
@test nv(h) == n
@test ne(h) == 2

h = g[[1,5]]
@test nv(h) == 2
@test ne(h) == 0
@test typeof(h) == typeof(g)

g = DG(100,200)
h = g[5:26]
@test nv(h) == 22
@test typeof(h) == typeof(g)
@test_throws ErrorException g[[1,1]]

r = 5:26
h2, vm = subgraph(g, r)
@test h2 == h
@test vm == r
@test h2 == g[r]

sg, vm = subgraph(CompleteGraph(10, G), 5:8)
@test nv(sg) == 4
@test ne(sg) == 6

gg = CompleteGraph(10, G)
r = 5:8
edg = (e for e in edges(gg) if (src(e) ∈ r && dst(e) ∈ r))
sg, vm = subgraph(gg, edg)
@test nv(sg) == 4
@test ne(sg) == 6


@test_throws ErrorException subgraph(CompleteGraph(10, G), [5,5,5])

sg2, vm = subgraph(CompleteGraph(10, G), [5,6,7,8])
@test sg2 == sg
@test vm[4] == 8

gg5 = CompleteGraph(10, G)
elist = [E(1,2),E(2,3),E(3,4),E(4,5),E(5,1)]
sg, vm = subgraph(gg5, elist)
@test sg == CycleGraph(5, G)
@test sort(vm) == [1:5;]


g10 = StarGraph(10, G)
@test egonet(g10, 1, 0) == G(1, 0)
@test egonet(g10, 1, 1) == g10

g1 = CompleteGraph(10, G)
g2 = copy(g1)
@test contract!(g1, 1, 2, 2) == contract!(g2, 1:2)
@test g1 == g2 == CompleteGraph(9, G)

g1 = CompleteDiGraph(10, DG)
g2 = copy(g1)
@test contract!(g1, 1, 2, 2) == contract!(g2, 1:2)
@test g1 == g2 == CompleteDiGraph(9, DG)

if G <: ANetwork
    g = readnetwork(:lesmis, G)

    h, vm = subgraph(g, 1:2)
    @test length(vprop(h)) == 0

    h, vm = subnetwork(g,1:2)
    length(vprop(h)) == 2
    @test  vprop(g, "label")[1] == "Myriel"
    @test  vprop(g, "label")[2] == "Napoleon"
    @test length(eprop(h)) == 1
    @test eprop(h, "value")[1,2] == 1

    elist = collect(edges(g))[1:10]
    h, vm = subnetwork(g, elist)
    @test ne(h) == 10
    for e in elist
        @test src(e) ∈ vm && dst(e) ∈ vm
    end
end


end # testset
