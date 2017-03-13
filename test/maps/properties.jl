@testset "$TEST $G" begin

g = Net(10, 20)
m = add_edge_property!(g, "label", Int)

@test valtype(m) == Int
@test typeof(m) <: AEdgeMap
e = first(edges(g))
m[e] = 2
@test m[e] == 2

@test get_edge_property(g, "label") === m
@test_throws ErrorException add_edge_property!(g, "label", Int)

rem_edge_property!(g, "label")
@test_throws ErrorException rem_edge_property!(g, "label")
@test_throws KeyError get_edge_property(g, "label")

m = add_edge_property!(g, "hi", String)
@test valtype(m) == String
@test typeof(m) <: AEdgeMap
e = first(edges(g))
m[e] = "ciao"
@test m[e] == "ciao"

end #testset
