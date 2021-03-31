if !@isdefined(TestINet)
    struct TestINet <: ANetwork; end
    struct TestIDiNet <: ADiNetwork; end
    struct TestIIdxEdge <: AIndexedEdge; end
end

@testset "$TEST $G" begin

g = TestINet()
h = TestIDiNet()
e = TestIIdxEdge()

@test_throws ErrorException idx(e)

if G<: ANetwork

g = G(10, 20)
m = ones(10,10)
add_edge_property!(g, "rand", m)
em = eprop(g, "rand")
@test typeof(em) <: EdgeMap
@test em.data === m
@test eprop(g, "rand")[1,1] == 1

m = fill(2, 10)
add_vertex_property!(g, "rand", m)
vm = vprop(g, "rand")
@test typeof(vm) <: VertexMap
@test vm.data === m
@test vprop(g, "rand")[1] == 2

g = G(10, 20)
eprop!(g, "E", EdgeMap(g, e -> rand()))
vprop!(g, "V", VertexMap(g, v -> rand()))
eprop!(g, "E1", e -> rand())
vprop!(g, "V1", v -> rand())

e = first(edges(g))
@test eprop(g, e)["E"] == eprop(g, e, "E")
@test vprop(g, 1)["V"] == vprop(g, 1, "V")

@test eprop(g, src(e), dst(e))["E"] == eprop(g, e, "E")
@test eprop(g, src(e), dst(e))["E"] == eprop(g, src(e), dst(e), "E")

end #if

end # testset
