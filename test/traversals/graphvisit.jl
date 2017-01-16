# stub tests for coverage; disregards output.
if !isdefined(:trivialgraphvisit)
    function trivialgraphvisit(
        g::ASimpleGraph,
        alg::FatGraphs.SimpleGraphVisitAlgorithm,
        sources)

        visitor = TrivialGraphVisitor()
        traverse_graph!(g, alg, sources, visitor)
    end
end

f = IOBuffer()
g6 = graph(:house, G)
@test traverse_graph_withlog(g6, BreadthFirst(), [1;], f) == nothing

@test visited_vertices(g6, BreadthFirst(), [1;]) == [1, 2, 3, 4, 5]

g = G(10, 20)
@test trivialgraphvisit(g, BreadthFirst(), 1) == nothing

# this just exercises some graph visitors
@test traverse_graph!(g, BreadthFirst(), 1, TrivialGraphVisitor()) == nothing
@test traverse_graph!(g, BreadthFirst(), 1, LogGraphVisitor(IOBuffer())) == nothing
