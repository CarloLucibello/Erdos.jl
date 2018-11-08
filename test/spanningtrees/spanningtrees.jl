@testset "$TEST $G" begin

n = 5
g = CompleteGraph(n, G)
@test count_spanning_trees(g) == 125

g = CompleteGraph(3, G)
@test count_spanning_trees(g) == 3

for n=5:10
    n = 5
    g = PathGraph(n, G)
    @test count_spanning_trees(g) == 1
    add_edge!(g, 1, n)
    @test count_spanning_trees(g) == n
end

g = StarGraph(n, G)
@test count_spanning_trees(g) == 1


g = blockdiag(g, g)
#accept only connected graphs
@test_throws AssertionError count_spanning_trees(g)

# count the empty tree as a spanning tree
g = G()
@test count_spanning_trees(g) == 1
g = G(1)
@test count_spanning_trees(g) == 1

end # testset
