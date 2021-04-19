@testset "$TEST $G" begin

if !@isdefined(test_rem_edge)
    function test_rem_edge(g, srcv)
        for dstv in collect(neighbors(g, srcv))
            rem_edge!(g, srcv, dstv)
        end
        @test length(neighbors(g,srcv)) == 0
    end
end

g5 = DG(4)
add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)

g6 = DG(4)
unsafe_add_edge!(g6,1,2); unsafe_add_edge!(g6,2,3);
unsafe_add_edge!(g6,1,3); unsafe_add_edge!(g6,3,4)
@test g6 == g5
rebuild!(g6)
@test g6 == g5

h1 = G(5)
h2 = G(3)
h3 = G()
h4 = DG(7)
h5 = DG()


e1 = E(1,2)
e2 = E(1,3)
e3 = E(1,4)
e4 = E(2,5)
e5 = E(3,5)

g = G(5)
@test add_edge!(g, 1, 2) == (true, edge(g, 1, 2))
for e in [e2,e3,e4,e5]
    @test add_edge!(g, e) == (true, edge(g, src(e), dst(e)))
end

g6 = G(5)
unsafe_add_edge!(g6, 1, 2)
unsafe_add_edge!(g6, e2)
unsafe_add_edge!(g6, e3)
unsafe_add_edge!(g6, e4)
unsafe_add_edge!(g6, e5)
@test g6 == g
rebuild!(g6)
@test g6 == g

h = DG(5)
@test add_edge!(h, 1, 2) == (true, edge(h, 1, 2))
for e in [e2,e3,e4,e5]
    @test add_edge!(h, e) == (true, edge(h, src(e), dst(e)))
end

@test vertices(g) == 1:5
i = 0
for e in edges(g)
    i+=1
end
@test i == 5
@test has_edge(g,3,5)
# @test edges(g) == Set([e1, e2, e3, e4, e5])
# @test Set{E}(edges(g)) == Set([e1, e2, e3, e4, e5])
#
@test degree(g) == [3, 2, 2, 1, 2]
@test in_degree(g) == [3, 2, 2, 1, 2]
@test in_degree(g,1) == 3
@test out_degree(g) == [3, 2, 2, 1, 2]
@test out_degree(g,1) == 3
@test degree(h) == [3, 1, 1, 0, 0]
@test in_degree(h) == [0, 1, 1, 1, 2]
@test in_degree(h,1) == 0
@test out_degree(h) == [3, 1, 1, 0, 0]
@test out_degree(h,1) == 3
@test collect(in_neighbors(h,5)) == adjacency_list(h,:in)[5]  == [2, 3]
@test collect(out_neighbors(h,1)) == adjacency_list(h)[1]  == [2, 3, 4]
@test_throws ErrorException adjacency_list(h, :ciao)
@test_throws MethodError adjacency_list(g, :out)

@test has_edge(g, 1, 2)
@test collect(in_edges(g, 2)) == [e1, reverse(e4)]
@test collect(out_edges(g, 1)) == [e1, e2, e3]
@test collect(out_edges(g, 1)) == collect(edges(g, 1))

@test add_vertex!(g) == nv(g) == 6
@test add_vertices!(g,5) == nv(g) == 11
@test has_vertex(g, 11)
@test ne(g) == 5
@test !is_directed(g)
@test is_directed(h)

@test CompleteGraph(4, G) == CompleteGraph(4, G)
@test CompleteGraph(4, G) != PathGraph(4, G)
@test CompleteDiGraph(4, DG) != PathDiGraph(4, DG)
@test CompleteDiGraph(4, DG) == CompleteDiGraph(4, DG)

@test collect(neighbors(g, 1)) == [2, 3, 4]

@test add_edge!(g, 1, 1) == (true, edge(g, 1, 1))
@test has_self_loops(g)
@test num_self_loops(g) == 1
@test add_edge!(g, 1, 1) == (false, edge(g, 1, 1))
@test rem_edge!(g, 1, 1)
@test !rem_edge!(g, 1, 1)

@test ne(g) == 5
@test rem_edge!(g, 1, 2)
@test ne(g) == 4

@test !rem_edge!(g, 2, 1)
add_edge!(g, 1, 2)
@test ne(g) == 5


@test has_edge(g,2,1)
@test has_edge(g,1,2)
@test rem_edge!(g, 2, 1)
@test add_edge!(h, 1, 1) == (true, edge(g, 1, 1))
@test rem_edge!(h, 1, 1)
@test rem_edge!(h, 1, 2)
@test !rem_edge!(h, 1, 2)
for v in vertices(g)
    test_rem_edge(copy(g),v)
end
for v in vertices(h)
    test_rem_edge(copy(h),v)
end

@test g == copy(g)
@test !(g === copy(g))
g10 = CompleteGraph(5, G)
@test rem_vertex!(g10, 1)
@test g10 == CompleteGraph(4, G)
@test rem_vertex!(g10, 4)
@test g10 == CompleteGraph(3, G)
@test !rem_vertex!(g10, 9)

g = G(2)
add_edge!(g, 1, 2)
@test rem_edge!(g, 1, 2)
@test !rem_edge!(g, 1, 2)
add_edge!(g, 1, 2)
edgs = collect(edges(g))
@test rem_edge!(g, edgs[1])
@test !rem_edge!(g, edgs[1])

g = CompleteGraph(5, G)
for e in edges(g)
    @test typeof(e) == edgetype(g)
end
edgs = collect(edges(g))
@test rem_edge!(g, edgs[1])
@test ne(g) == 9
@test !rem_edge!(g, edgs[1])
@test ne(g) == 9

g = G(10)
add_edge!(g, 1, 2)
add_edge!(g, 1, 3)
ga = G(10)
add_edge!(ga, 1, 2)
add_edge!(ga, 1, 4)
@test !(ga == g)
@test ga != g

g10 = CompleteDiGraph(5, DG)
for e in edges(g10)
    @test typeof(e) == edgetype(g10)
end
for i=2:5
    @test rem_edge!(g10, 1, i)
    @test ne(g10) == 21-i
end
@test in_degree(g10, 1) == 4
@test out_degree(g10, 1) == 0

g = CompleteDiGraph(5, DG)
@test ne(g) == 20
@test nv(g) == 5
clean_vertex!(g, 1)
@test ne(g) == 12
@test nv(g) == 5
@test in_degree(g, 1) == 0
@test out_degree(g, 1) == 0
for i=2:5
    @test in_degree(g, i) == 3
    @test out_degree(g, i) == 3
end

g10 = CompleteDiGraph(5, DG)
@test rem_vertex!(g10, 1)
@test g10 == CompleteDiGraph(4, DG)
rem_vertex!(g10, 4)
@test g10 == CompleteDiGraph(3, DG)
@test !rem_vertex!(g10, 9)
g10 = PathGraph(5, G)
@test rem_vertex!(g10, 5)
@test g10 == PathGraph(4, G)
@test rem_vertex!(g10, 4)
@test g10 == PathGraph(3, G)

g10 = PathDiGraph(5, DG)
@test rem_vertex!(g10, 5)
@test g10 == PathDiGraph(4, DG)
@test rem_vertex!(g10, 4)
@test g10 == PathDiGraph(3, DG)

g10 = PathDiGraph(5, DG)
@test rem_vertex!(g10, 1)
h10 = PathDiGraph(6, DG)
@test rem_vertex!(h10, 1)
@test rem_vertex!(h10, 1)
@test g10 == h10

g10 = CycleGraph(5, G)
@test rem_vertex!(g10, 5)
@test g10 == PathGraph(4, G)

g10 = PathGraph(3, G)
@test rem_vertex!(g10, 2)
@test g10 == G(2)

g10 = PathGraph(4, G)
@test rem_vertex!(g10, 3)
h10 =G(3)
@test add_edge!(h10,1,2) == (true, edge(h10, 1, 2))
@test g10 == h10

g10 = CompleteGraph(5, G)
@test rem_vertex!(g10, 3)
@test g10 == CompleteGraph(4, G)


s = split("$G",'.')[end]
if G <: ANetwork
    @test sprint(show, h1) == s*"(5, 0) with [] graph, [] vertex, [] edge properties"
else
    @test sprint(show, h1) == s*"(5, 0)"
end

g3 = PathGraph(5, G)
@test graph(digraph(g3)) == g3

@test degree(g3, 1) == 1
# @test neighbors(g3, 3) == [2, 4]
@test density(g3) == 0.4

g = G(5)
@test add_edge!(g, 1, 2) == (true, edge(g, 1, 2))

e2 = E(1,3)
e3 = E(1,4)
e4 = E(2,5)
e5 = E(3,5)

for e in [e2,e3,e4,e5]
    @test add_edge!(g, e) == (true, edge(g, src(e), dst(e)))
end

for i in out_neighbors(g, 1)
    @test typeof(i) == V
end

h = DG(10, 20)
for i=1:10
    u = sort(union(in_neighbors(h,i), out_neighbors(h,i)))
    @test sort(collect(all_neighbors(h, i))) == u
end
for i in out_neighbors(h, 1)
    @test typeof(i) == V
end

h = DG(5)
@test add_edge!(h, 1, 2) == (true, edge(h, 1, 2))
for e in [e2,e3,e4,e5]
    @test add_edge!(h, e) == (true, edge(h, src(e), dst(e)))
end

@test collect(out_edges(h, 3)) == collect(edges(h, 3))
@test length(collect(out_edges(h, 3))) == 1
@test length(collect(in_edges(h, 3))) == 1
@test length(collect(all_edges(h, 3))) == 2

for i=1:5
    u = sort(union(in_neighbors(h,i), out_neighbors(h,i)))
    @test sort(collect(all_neighbors(h, i))) == u
end


@test adjacency_list(g)[1] == collect(out_neighbors(g,1)) ==
    collect(in_neighbors(g,1)) == [2,3,4]

e0 = E(2, 3)
s = split("$DG",'.')[end]
# @test sprint(show, h4) == s*"(7, 0)" #TODO
# @test sprint(show, h5) == s*"(0, 0)"
@test has_edge(g, e1)
@test has_edge(h, e1)
@test !has_edge(g, e0)
@test !has_edge(h, e0)

g4 = PathDiGraph(5, DG)
@test degree(g4, 1) == 1
# @test neighbors(g4, 3) == [4]
@test density(g4) == 0.2


adjmx1 = [0 1 0; 1 0 1; 0 1 0] # graph
adjmx2 = [0 1 0; 1 0 1; 1 1 0] # digraph
a1 = G(adjmx1)
a2 = DG(adjmx2)

@test nv(a1) == 3
@test ne(a1) == 2
@test nv(a2) == 3
@test ne(a2) == 5

badadjmx = [ 0 1 0; 1 0 1]
@test_throws ErrorException G(badadjmx)
@test_throws ErrorException G(sparse(badadjmx))
@test_throws ErrorException DG(badadjmx)
@test_throws ErrorException DG(sparse(badadjmx))

@test add_edge!(g, 100, 100) == (false, edge(g, 100, 100))
@test add_edge!(h, 100, 100) == (false, edge(h, 100, 100))

g = G(sparse(adjmx1))
h = DG(sparse(adjmx1))

@test (nv(g), ne(g)) == (3, 2)
@test (nv(h), ne(h)) == (3, 4)
@test graph(h) == g

@test collect(neighbors(WheelDiGraph(10, DG),2)) ==
    collect(out_neighbors(WheelDiGraph(10, DG),2))
@test collect(out_neighbors(WheelDiGraph(10, DG),2)) == [3]

gg = DG(4)
add_edge!(gg, 1, 2)
add_edge!(gg, 1, 3)

g = reverse(gg)
@test ne(g) == ne(gg)
@test E(2,1) in edges(g)
@test !(E(1,2) in edges(g))
@test E(3,1) in edges(g)
@test !(E(1,3) in edges(g))

reverse!(g)
@test g == gg

g = G(4)
add_edge!(g, 1, 2); add_edge!(g, 3, 4);

swap_vertices!(g, 1, 3)
@test ne(g) == 2
@test has_edge(g, 1, 4)
@test has_edge(g, 3, 2)
@test !has_edge(g, 1, 2)
@test !has_edge(g, 3, 4)

add_edge!(g, 1, 2)
@test ne(g) == 3
swap_vertices!(g, 1, 3)
h = G(4)
add_edge!(h, 1, 2); add_edge!(h, 3, 4); add_edge!(h, 3, 2);
@test g == h

g = DG(4)
add_edge!(g, 1, 2); add_edge!(g, 3, 4);

swap_vertices!(g, 1, 3)
@test ne(g) == 2
@test has_edge(g, 1, 4)
@test has_edge(g, 3, 2)
@test !has_edge(g, 1, 2)
@test !has_edge(g, 3, 4)

add_edge!(g, 1, 2)
swap_vertices!(g, 1, 3)
@test !has_edge(g, 1, 4)
@test has_edge(g, 3, 2)
@test has_edge(g, 1, 2)
@test has_edge(g, 3, 4)
@test !has_edge(g, 2, 3)
@test !has_edge(g, 2, 1)
@test !has_edge(g, 4, 3)

g = G(2)
add_edge!(g, 1, 2); add_edge!(g, 1, 1);
swap_vertices!(g, 1, 2)
@test ne(g) == 2
@test has_edge(g, 1, 2)
@test has_edge(g, 2, 2)
@test !has_edge(g, 1, 1)
add_edge!(g, 1, 1)
@test has_edge(g, 1, 1)
@test ne(g) == 3
swap_vertices!(g, 1, 2)
@test ne(g) == 3
@test has_edge(g, 1, 2)
@test has_edge(g, 2, 2)
@test has_edge(g, 1, 1)

g = DG(3)
add_edge!(g, 1, 2); add_edge!(g, 1, 1); add_edge!(g, 3, 1)
swap_vertices!(g, 1, 2)
@test ne(g) == 3
@test !has_edge(g, 1, 2)
@test has_edge(g, 2, 1)
@test has_edge(g, 2, 2)
@test !has_edge(g, 1, 1)
@test has_edge(g, 3, 2)
@test !has_edge(g, 3, 1)
@test !has_edge(g, 1, 3)
@test !has_edge(g, 2, 3)
add_edge!(g, 1, 1)
swap_vertices!(g, 1, 2)
@test ne(g) == 4
@test has_edge(g, 1, 2)
@test !has_edge(g, 2, 1)
@test has_edge(g, 2, 2)
@test has_edge(g, 1, 1)
@test !has_edge(g, 3, 2)
@test has_edge(g, 3, 1)
@test !has_edge(g, 1, 3)
@test !has_edge(g, 2, 3)

g = WheelGraph(10, G)
@test degree(g, 1) == 9
@test degree(g, 10) == 3
swap_vertices!(g, 1, 10)
@test degree(g, 1) == 3
@test degree(g, 10) == 9

g = CompleteGraph(10, G)
vmap = rem_vertices!(g, 6:10)
@test g == CompleteGraph(5, G)
@test typeof(vmap) <: AVertexMap
@test length(vmap) == 0

g = CompleteGraph(10, G)
vmap = rem_vertices!(g, 1:5)
@test g == CompleteGraph(5, G)
@test typeof(vmap) <: AVertexMap
@test length(vmap) ==  5
for v=1:5
    @test vmap[v] == v + 5
end

g = G(10, 20)
g2 = copy(g)
vmap = rem_vertices!(g, 6:10)
for v=10:-1:6
    rem_vertex!(g2, v)
end
@test g == g2
@test typeof(vmap) <: AVertexMap
@test length(vmap) == 0

g = DG(10, 20)
g2 = copy(g)
vmap = rem_vertices!(g, 1:5)
for v=5:-1:1
    rem_vertex!(g2, v)
end
@test g == g2
@test typeof(vmap) <: AVertexMap
@test length(vmap) ==  5
for v=1:5
    @test vmap[v] == v + 5
end


g1 = G(10, 30)
g2 = copy(g1)
@test rem_vertices!(g1, 1, 2, 2) == rem_vertices!(g2, 1, 2)
@test g1 == g2

g = G(10,20)
h = copy(g)
pop_vertex!(g)
rem_vertex!(h, 10)
@test g == h

g = DG(10,20)
h = copy(g)
pop_vertex!(g)
rem_vertex!(h, 10)
@test g == h

A = [1 2 0;
    -1 0 1;
     3  1 2]
g = G(A)
@test nv(g) == 3
@test ne(g) == 5
g = G(A, upper=true)
@test ne(g) == 4
@test !has_edge(g, 1, 3)
@test !has_edge(g, 2, 2)
@test has_edge(g, 1, 1)
@test !has_edge(g, 15, 1)
g = G(A, upper=true, selfedges=false)
@test ne(g) == 2
@test !has_edge(g, 1, 3)
@test !has_edge(g, 2, 2)
@test !has_edge(g, 1, 1)
@test !has_edge(g, 3, 3)
g = G(A, upper=false, selfedges=false)
@test ne(g) == 3
@test has_edge(g, 1, 3)
@test !has_edge(g, 2, 2)
@test !has_edge(g, 1, 1)
@test !has_edge(g, 3, 3)

g = DG(A)
@test nv(g) == 3
@test ne(g) == 7
@test has_edge(g, 1, 1)
@test !has_edge(g, 2, 2)
@test has_edge(g, 3, 3)
@test !has_edge(g, 15, 1)

g = DG(A, selfedges=false)
@test ne(g) == 5
@test !has_edge(g, 1, 1)
@test !has_edge(g, 2, 2)
@test !has_edge(g, 3, 3)

@testset "constructors Net from Net" begin
    g = G(5, 10)
    g2 = G(g)
    @test g == g2
        
    g = DG(5, 10)
    g2 = DG(g)
    @test g == g2

    if G <: ANetwork
        g = G(5, 10)
        vprop!(g, "a", v -> 1)
        eprop!(g, "a", e -> 2)
        gprop!(g, "a", "ciao")
        g2 = G(g)
        @test gprop(g2, "a") == gprop(g, "a")
        @test has_vprop(g2, "a")
        @test has_eprop(g2, "a")
        
        g = DG(5, 10)
        vprop!(g, "a", v -> 1)
        eprop!(g, "a", e -> 2)
        gprop!(g, "a", "ciao")
        g2 = DG(g)
        @test gprop(g2, "a") == gprop(g, "a")
        @test has_vprop(g2, "a")
        @test has_eprop(g2, "a")
    end
end

end #testset
