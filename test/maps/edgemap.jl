if !isdefined(:TestEdge)
mutable struct TestEdge <: AEdge
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

@test get(m, edge(g, 1, 2), -100) == 0

m = EdgeMap(g, sparse(d))
@test values(m) == nonzeros(sparse(d))
@test get(m, edge(g, 1, 2), -100) == 0

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
    # @test sprint(show, m) == "EdgeMap: $(m.data)"
    if typeof(m.data) <: AbstractMatrix
        @test haskey(m, 3, 4)
    else
        @test !haskey(m, 3, 4)
    end
    @test !haskey(m, 100,100)
end

g = G(10,10)
m = EdgeMap(g, rand(10,10))
adj = adjacency_list(g)
madj = edgemap2adjlist(m)
@test length(madj) == length(adj)
for i=1:nv(g)
    @test length(madj[i]) == length(adj[i])
    for (k, j) in enumerate(adj[i])
        @test madj[i][k] == m[i, j]
    end
end

g = G(10,20)
emap = EdgeMap(g, rand(10,20))
m = Matrix(emap)
@test typeof(m) == Matrix{Float64}
sp = sparse(emap)
@test typeof(sp) <: SparseMatrixCSC{Float64}

@test size(m) == size(sp) == (nv(g), nv(g))
@test countnz(m) == countnz(sp) == 2ne(g)

for e in edges(g)
    u, v = src(e), dst(e)
    @test m[u,v] == m[v,u] == sp[u, v] == sp[v, u] == emap[e]
end

@test size(emap) == (nv(g), nv(g))
@test size(emap, 1) == nv(g)
@test size(emap, 2) == nv(g)
@test_throws ErrorException size(emap, 3)

g = DG(10,20)
emap = EdgeMap(g, rand(10,20))
m = Matrix(emap)
@test typeof(m) == Matrix{Float64}
sp = sparse(emap)
@test typeof(sp) <: SparseMatrixCSC{Float64}

@test size(m) == size(sp) == (nv(g), nv(g))
@test countnz(m) == countnz(sp) == ne(g)

for e in edges(g)
    u, v = src(e), dst(e)
    @test m[u,v] == sp[u, v] == emap[e]
end

@test size(emap) == (nv(g), nv(g))

g = G(10,20)
m = EdgeMap(g, e -> src(e) + dst(e))
if E <: IndexedEdge
    @test typeof(m.data) == Vector{V}
else
    @test typeof(m.data) == Dict{E, V}
end
for e in edges(g)
    @test m[e] == src(e) + dst(e)
end


end # testset
