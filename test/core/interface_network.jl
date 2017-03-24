if !isdefined(:TestINet)
    type TestINet <: ANetwork; end
    type TestIDiNet <: ADiNetwork; end
    type TestIIdxEdge <: AIndexedEdge; end
end

@testset "$TEST $G" begin

g = TestINet()
h = TestIDiNet()
e = TestIIdxEdge()

@test_throws ErrorException idx(e)

#TODO
end # testset
