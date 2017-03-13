@testset "$TEST $G" begin

g = Net(10, 20)
m = add_edge_property!(g, "label", Int)

@test valtype(m) == Int
@test typeof(m) <: AEdgeMap
e = first(edges(g))
m[e] = 2
@test m[e] == 2

@test edge_property(g, "label") === m
@test_throws ErrorException add_edge_property!(g, "label", Int)

rem_edge_property!(g, "label")
@test_throws ErrorException rem_edge_property!(g, "label")
@test_throws KeyError edge_property(g, "label")

m = add_edge_property!(g, "hi", String)
@test valtype(m) == String
@test typeof(m) <: AEdgeMap
e = first(edges(g))
m[e] = "ciao"
@test m[e] == "ciao"

m = EdgeMap(g, String)
m2 = add_edge_property!(g, "bye", m)
@test m === m2
@test edge_properties(g) == ["bye","hi"]

end #testset
