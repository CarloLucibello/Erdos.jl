if !isdefined(:TestEdge)
type TestEdge <: AEdge
    src::Int
    dst::Int
end
Erdos.src(e::TestEdge) = e.src
Erdos.dst(e::TestEdge) = e.dst
end

@testset "$TEST $G" begin

# EdgeMap matrix
n = 4
m = randn(n, n)
m = (m + m'); m -= Diagonal(m)

g = G(m)
em = EdgeMap(g, m)
@test length(em) == n*n
@test em[TestEdge(1,2)] == em[1,2]
@test values(em) === m
# @test sprint(show, em) == "EdgeMap{Float64}" #TODO

# ConstEdgeMap
em = ConstEdgeMap(g, 1)
@test length(em) == typemax(Int)
em[1,2] = 18
@test em[1,2] == 1
@test size(em) == (typemax(Int),)
@test values(em) == [1]
# @test sprint(show, em) == "EdgeMap{Int64}"

end # testset
