@testset "$TEST $G" begin

if G <: ANetwork
## EDGE
g = G(10, 20)
eprop!(g, "label", Int)
m = eprop!(g, "label")

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

eprop!(g, "hi", String)
m = eprop!(g, "hi")
@test valtype(m) == String
@test typeof(m) <: AEdgeMap
e = first(edges(g))
m[e] = "ciao"
@test m[e] == "ciao"

m = EdgeMap(g, String)
eprop!(g, "bye", m)
m2 = eprop!(g, "bye")
@test m === m2
@test eprop_names(g) == ["bye","hi"]

edg = collect(edges(g))
@test eprop(g, edg[1]) == Dict("hi"=>"ciao")
@test eprop(g, edg[2]) == Dict()
eprop(g, "bye")[edg[1]] = "e1"
eprop(g, "bye")[edg[2]] = "e2"
@test eprop(g, edg[1]) == Dict("hi"=>"ciao", "bye"=>"e1")
@test eprop(g, edg[2]) == Dict("bye"=>"e2")

@test has_eprop(g, "bye", edg[1])
@test has_eprop(g, "hi", edg[1])
@test has_eprop(g, "bye", edg[2])
@test !has_eprop(g, "hi", edg[2])

## VERTEX
g = G(3)
add_edge!(g,1,2)
add_edge!(g,2,3)
vprop!(g, "label", [1,2,3])
m = vprop(g, "label")
@test valtype(m) == Int
@test typeof(m) <: AVertexMap
@test vprop(g, "label") === m

rem_vertex!(g, 1)
@test m[1] == 3
@test m[2] == 2

swap_vertices!(g, 1, 2)
@test m[1] == 2
@test m[2] == 3

vprop!(g, "size", Int)
m = vprop(g, "size")
m[1] =  4
@test vprop(g, 1) == Dict("size"=>4, "label"=>2)
@test vprop(g, 2) == Dict("label"=>3)

@test has_vprop(g, "size", 1)
@test has_vprop(g, "label", 1)
@test !has_vprop(g, "size", 2)
@test has_vprop(g, "label", 2)


## GRAPH
g = DG(3, 5)
gprop!(g, "lab", "mygraph")
@test gprop(g, "lab") == "mygraph"
@test gprop_names(g) == ["lab"]
rem_gprop!(g, "lab")
@test gprop_names(g) == []

end

end #testset
