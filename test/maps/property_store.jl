@testset "$TEST $G" begin

## EDGE
g = Network(10, 20)
m = eprop!(g, "label", Int)

@test valtype(m) == Int
@test typeof(m) <: AEdgeMap
e = first(edges(g))
m[e] = 2
@test m[e] == 2

@test eprop(g, "label") === m
@test_throws ErrorException eprop!(g, "label", Int)

rem_eprop!(g, "label")
@test_throws ErrorException rem_eprop!(g, "label")
@test_throws KeyError eprop(g, "label")

m = eprop!(g, "hi", String)
@test valtype(m) == String
@test typeof(m) <: AEdgeMap
e = first(edges(g))
m[e] = "ciao"
@test m[e] == "ciao"

m = EdgeMap(g, String)
m2 = eprop!(g, "bye", m)
@test m === m2
@test eprop_names(g) == ["bye","hi"]

## VERTEX
g = Network(3)
add_edge!(g,1,2)
add_edge!(g,2,3)
m = vprop!(g, "label", [1,2,3])
@test valtype(m) == Int
@test typeof(m) <: AVertexMap
@test vprop(g, "label") === m

rem_vertex!(g, 1)
@test m[1] == 3
@test m[2] == 2

swap_vertices!(g, 1, 2)
@test m[1] == 2
@test m[2] == 3

## GRAPH
g = DiNetwork(3, 5)
gprop!(g, "lab", "mygraph")
@test gprop(g, "lab") == "mygraph"
@test gprop_names(g) == ["lab"]
rem_gprop!(g, "lab")
@test gprop_names(g) == []

end #testset
