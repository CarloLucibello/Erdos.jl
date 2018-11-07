@testset "$TEST $G" begin

##################################################################
#
#   Maximal cliques of undirected graph
#   Derived from Graphs.jl: https://github.com/julialang/Graphs.jl
#
##################################################################

if !@isdefined(setofsets)
    function setofsets(array_of_arrays)
        Set(map(Set, array_of_arrays))
    end

    function test_cliques(graph, expected)
        # Make test results insensitive to ordering
        setofsets(maximal_cliques(graph)) == setofsets(expected)
    end
end

g = G(3)
add_edge!(g, 1, 2)
@test test_cliques(g, Array[[1,2], [3]])
add_edge!(g, 2, 3)
@test test_cliques(g, Array[[1,2], [2,3]])

# Test for "pivotdonenbrs not defined" bug
h = G(6)
add_edge!(h, 1, 2)
add_edge!(h, 1, 3)
add_edge!(h, 1, 4)
add_edge!(h, 2, 5)
add_edge!(h, 2, 6)
add_edge!(h, 3, 4)
add_edge!(h, 3, 6)
add_edge!(h, 5, 6)

@test maximal_cliques(h) != []

# test for extra cliques bug

h = G(7)
add_edge!(h,1,3)
add_edge!(h,2,6)
add_edge!(h,3,5)
add_edge!(h,3,6)
add_edge!(h,4,5)
add_edge!(h,4,7)
add_edge!(h,5,7)
@test test_cliques(h, Array[[7,4,5], [2,6], [3,5], [3,6], [3,1]])

end # testset
