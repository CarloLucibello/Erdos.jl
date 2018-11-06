@testset "$TEST $G" begin

g5 = DG(4)
add_edge!(g5,1,2); add_edge!(g5,2,3); add_edge!(g5,1,3); add_edge!(g5,3,4)
z = dfs_tree(g5, 1)

@test ne(z) == 3
@test nv(z) == 4
@test !has_edge(z, 1, 3)

@test topological_sort_by_dfs(g5) == [1, 2, 3, 4]

# TODO add back
# @test !has_cycles(g5)
# @test is_tree(g5)

# g = DG(3)
# add_edge!(g,1,2); add_edge!(g,2,3); add_edge!(g,3,1)
# @test has_cycles(g)
# @test !is_tree(g)

# g = G(4)
# add_edge!(g,1,2); add_edge!(g,2,3); add_edge!(g,2,4);
# @test !has_cycles(g)
# @test is_tree(g)

# add_edge!(g,1,3);
# @test has_cycles(g)
# @test !is_tree(g)

end # testset
