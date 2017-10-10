if !isdefined(:TestINet)
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

g = G(10,20)
m = ones(10,10)
em = add_edge_property!(g, "rand", m)
@test typeof(em) <: EdgeMap
@test em.data === m
@test eprop(g, "rand")[1,1] == 1

m = fill(2, 10)
vm = add_vertex_property!(g, "rand", m)
@test typeof(vm) <: VertexMap
@test vm.data === m
@test vprop(g, "rand")[1] == 2

end #if

end # testset
