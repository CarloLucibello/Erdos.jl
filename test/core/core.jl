e1 = Edge(1,2)
e2 = Edge(1,3)
e3 = Edge(1,4)
e4 = Edge(2,5)
e5 = Edge(3,5)

g = Graph(5)
@test add_edge!(g, 1, 2)
@test add_edge!(g, e2)
@test add_edge!(g, e3)
@test add_edge!(g, e4)
@test add_edge!(g, e5)


h = DiGraph(5)
@test add_edge!(h, 1, 2)
@test add_edge!(h, e2)
@test add_edge!(h, e3)
@test add_edge!(h, e4)
@test add_edge!(h, e5)

@test vertices(g) == 1:5
i = 0
for e in edges(g)
    i+=1
end
@test i == 5
@test has_edge(g,3,5)
# @test edges(g) == Set([e1, e2, e3, e4, e5])
# @test Set{Edge}(edges(g)) == Set([e1, e2, e3, e4, e5])

@test degree(g) == [3, 2, 2, 1, 2]
@test indegree(g) == [3, 2, 2, 1, 2]
@test indegree(g,1) == 3
@test outdegree(g) == [3, 2, 2, 1, 2]
@test outdegree(g,1) == 3
@test degree(h) == [3, 1, 1, 0, 0]
@test indegree(h) == [0, 1, 1, 1, 2]
@test indegree(h,1) == 0
@test outdegree(h) == [3, 1, 1, 0, 0]
@test outdegree(h,1) == 3
@test in_neighbors(h,5) == in_adjlist(h)[5]  == [2, 3]
@test out_neighbors(h,1) == out_adjlist(h)[1]  == [2, 3, 4]

@test p1 == g2
@test issubset(h2, h1)

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

@test δ(g) == δin(g) == δout(g) == 0
@test Δ(g) == Δout(g) == 3
@test Δin(h) == 2
@test δ(h) == δout(h)
@test δin(h) == 0
@test δout(h) == 0
@test CompleteGraph(4) == CompleteGraph(4)
@test CompleteGraph(4) != PathGraph(4)
@test CompleteDiGraph(4) != PathDiGraph(4)
@test CompleteDiGraph(4) == CompleteDiGraph(4)

@test degree_histogram(CompleteDiGraph(10)).weights == [10]
@test degree_histogram(CompleteGraph(10)).weights == [10]

@test neighbors(g, 1) == [2, 3, 4]
@test common_neighbors(g, 2, 3) == [1, 5]
@test common_neighbors(h, 2, 3) == common_outneighbors(h, 2, 3)
@test common_inneighbors(h, 2, 3) == [1]
@test common_outneighbors(h, 2, 3) == [5]

@test add_edge!(g, 1, 1)
@test has_self_loops(g)
@test num_self_loops(g) == 1
@test !add_edge!(g, 1, 1)
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
@test add_edge!(h, 1, 1)
@test rem_edge!(h, 1, 1)
@test rem_edge!(h, 1, 2)
@test !rem_edge!(h, 1, 2)

function test_rem_edge(g, srcv)
    srcv = 2
    for dstv in collect(neighbors(g, srcv))
        rem_edge!(g, srcv, dstv)
    end
    @test length(neighbors(g,srcv)) == 0
end
for v in vertices(g)
    test_rem_edge(copy(g),v)
end
for v in vertices(h)
    test_rem_edge(copy(h),v)
end

@test g == copy(g)
@test !(g === copy(g))
g10 = CompleteGraph(5)
@test rem_vertex!(g10, 1)
@test g10 == CompleteGraph(4)
@test rem_vertex!(g10, 4)
@test g10 == CompleteGraph(3)
@test !rem_vertex!(g10, 9)

g10 = CompleteDiGraph(5)
@test rem_vertex!(g10, 1)
@test g10 == CompleteDiGraph(4)
rem_vertex!(g10, 4)
@test g10 == CompleteDiGraph(3)
@test !rem_vertex!(g10, 9)
g10 = PathGraph(5)
@test rem_vertex!(g10, 5)
@test g10 == PathGraph(4)
@test rem_vertex!(g10, 4)
@test g10 == PathGraph(3)

g10 = PathDiGraph(5)
@test rem_vertex!(g10, 5)
@test g10 == PathDiGraph(4)
@test rem_vertex!(g10, 4)
@test g10 == PathDiGraph(3)

g10 = PathDiGraph(5)
@test rem_vertex!(g10, 1)
h10 = PathDiGraph(6)
@test rem_vertex!(h10, 1)
@test rem_vertex!(h10, 1)
@test g10 == h10

g10 = CycleGraph(5)
@test rem_vertex!(g10, 5)
@test g10 == PathGraph(4)

g10 = PathGraph(3)
@test rem_vertex!(g10, 2)
@test g10 == Graph(2)

g10 = PathGraph(4)
@test rem_vertex!(g10, 3)
h10 =Graph(3)
@test add_edge!(h10,1,2)
@test g10 == h10

g10 = CompleteGraph(5)
@test rem_vertex!(g10, 3)
@test g10 == CompleteGraph(4)

@test sprint(show, h1) == "{5, 0} undirected graph"
@test sprint(show, h3) == "empty undirected graph"

@test graph(digraph(g3)) == g3

@test degree(g3, 1) == 1
# @test neighbors(g3, 3) == [2, 4]
@test density(g3) == 0.4

g = Graph(5)
@test add_edge!(g, 1, 2)

e2 = Edge(1,3)
e3 = Edge(1,4)
e4 = Edge(2,5)
e5 = Edge(3,5)


@test add_edge!(g, e2)
@test add_edge!(g, e3)
@test add_edge!(g, e4)
@test add_edge!(g, e5)

h = DG(10, 20)
for i=1:10
    u = sort(union(in_neighbors(h,i), out_neighbors(h,i)))
    @test sort(collect(all_neighbors(h, i))) == u
end

h = DiGraph(5)
@test add_edge!(h, 1, 2)
@test add_edge!(h, e2)
@test add_edge!(h, e3)
@test add_edge!(h, e4)
@test add_edge!(h, e5)

for i=1:5
    u = sort(union(in_neighbors(h,i), out_neighbors(h,i)))
    @test sort(collect(all_neighbors(h, i))) == u
end


@test adjlist(g)[1] == out_neighbors(g,1) ==
    in_adjlist(g)[1] == in_neighbors(g,1) ==
    adjlist(g)[1] == [2,3,4]

@test sprint(show, h4) == "{7, 0} directed graph"
@test sprint(show, h5) == "empty directed graph"
@test has_edge(g, e1)
@test has_edge(h, e1)
@test !has_edge(g, e0)
@test !has_edge(h, e0)

@test degree(g4, 1) == 1
# @test neighbors(g4, 3) == [4]
@test density(g4) == 0.2

@test nv(a1) == 3
@test ne(a1) == 2
@test nv(a2) == 3
@test ne(a2) == 5

badadjmx = [ 0 1 0; 1 0 1]
@test_throws ErrorException Graph(badadjmx)
@test_throws ErrorException Graph(sparse(badadjmx))
@test_throws ErrorException DiGraph(badadjmx)
@test_throws ErrorException DiGraph(sparse(badadjmx))
@test_throws ErrorException Graph([1 0; 1 1])


@test !add_edge!(g, 100, 100)
@test !add_edge!(h, 100, 100)

@test_throws ErrorException Graph(sparse(adjmx2))

g = Graph(sparse(adjmx1))
h = DiGraph(sparse(adjmx1))

@test (nv(g), ne(g)) == (3, 2)
@test (nv(h), ne(h)) == (3, 4)
@test graph(h) == g



@test neighbors(WheelDiGraph(10),2) == out_neighbors(WheelDiGraph(10),2)
@test out_neighbors(WheelDiGraph(10),2) == [3]
