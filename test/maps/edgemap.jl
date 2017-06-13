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
@test valtype(em) == Float64
# @test sprint(show, em) == "EdgeMap{Float64}" #TODO

d = [1 0 1;
     1 0 2;
     3 0 0]
g = G(d, upper=true)
m = EdgeMap(g, d)
@test m[1,2] == m[2,1] == 0
@test m[1,3] == m[3,1] == 1
@test m[1,1] == 1
@test m[2,2] == 0
m[3, 1] = -1
@test m[1,3] == m[3,1] == -1
@test d[1,3] == -1
@test d[3,1] == 3

d = [1 0 1;
     1 0 2;
     3 0 0]
g = DG(d)
m = EdgeMap(g, d)
@test m[1,2] != m[2,1]
@test m[1,3] != m[3,1]
@test m[1,1] == 1
@test m[2,2] == 0
m[3, 1] = -1
@test m[1,3]  == 1
@test m[3,1]  == -1
@test d[1,3] == 1
@test d[3,1] == -1

# ConstEdgeMap
em = ConstEdgeMap(g, 1)
@test valtype(em) == Int
@test length(em) == typemax(Int)
# @test_throws ErrorException em[1,2] = 18 #TODO
# @test_throws ErrorException em[Edge(1,2)] = 18
# @test_throws ErrorException em[E(1,2)] = 18
em[1,2] = 18
em[Edge(1,2)] = 18
em[E(1,2)] = 18

@test em[1,2] == 1
@test size(em) == (typemax(Int),)
@test values(em) == [1]
# @test sprint(show, em) == "EdgeMap{Int64}"

n = 10
g = G(n)
add_edge!(g, 1, 2)
add_edge!(g, 2, 3)

MAPS_LIST = [  EdgeMap(g, Int), EdgeMap(g, spzeros(Int, n, n)), EdgeMap(g, zeros(Int, n, n)),
            EdgeMap(g, Dict{Edge{Int}, Int}()), EdgeMap(g, Dict{E, Int}()) ]
E <: IndexedEdge && append!(MAPS_LIST, [EdgeMap(g, zeros(Int, ne(g))), EdgeMap(g, Dict{Int,Int}())])

for m in MAPS_LIST
    for (k, e)  in enumerate(edges(g))
        i, j = src(e), dst(e)
        m[e] = k
        @test k == m[e]
        @test k == m[i, j]
        @test get(m, e, -1) == k
        @test haskey(m, e)
        @test haskey(m, i, j)
    end
    m[1,2] = 10
    @test m[1,2] == 10
    @test sprint(show, m) == "EdgeMap: $(m.data)"
    if typeof(m.data) <: AbstractMatrix
        @test haskey(m, 3, 4)
    else
        @test !haskey(m, 3, 4)
    end
    @test !haskey(m, 100,100)
end

end # testset
