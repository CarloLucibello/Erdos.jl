g = G(10)
h = DG(10)
@test edge(g, 1, 2) != nothing
@test edge(h, 1, 2) != nothing
@test neighbors(g, 1) != nothing
@test in_neighbors(h, 1) != nothing
@test out_neighbors(h, 1) != nothing
@test graph(g) != nothing
@test graph(h) != nothing
@test digraph(g) != nothing
@test digraph(h) != nothing

if !isdefined(:TestGraph)
    type TestGraph <: AGraph; end
    type TestDiGraph <: ADiGraph; end
end
g = TestGraph()
h = TestDiGraph()

@test nv(g) == nothing
@test nv(h) == nothing
@test neighbors(g, 1) == nothing
@test edge(g, 1, 2) == nothing
@test edge(h, 1, 2) == nothing
@test neighbors(g, 1) == nothing
@test in_neighbors(h, 1) == nothing
@test out_neighbors(h, 1) == nothing
@test graphtype(h) == nothing
@test digraphtype(g) == nothing
@test edgetype(g) == nothing
@test pop_vertex!(g) == nothing
