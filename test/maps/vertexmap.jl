@testset "$TEST $G" begin

vm = ConstVertexMap(0)
@test typeof(vm) <: AVertexMap
@test get(vm, 1, 1) == 0
@test get(vm, -1, 1) == 0
vm[1] = 1
@test vm[1] == 0
@test haskey(vm, 1)
@test haskey(vm, -1)
@test length(vm) == typemax(Int)

g = G()
vm = VertexMap(g, rand(1:10,10))
@test typeof(vm) <: AVertexMap
@test haskey(vm, 2)
@test !haskey(vm, -1)
@test valtype(vm) == Int
@test get(vm, 1, -100) != -100
@test length(Vector(vm)) == 0

g = G(10,20)
v = rand(10)
vm = VertexMap(g, v)
@test Vector(vm) == v

vm = VertexMap(g, Float64)
@test valtype(vm) == Float64
@test typeof(vm) <: AVertexMap

vm[1] = 2.
@test vm[1] == 2
@test haskey(vm, 1)
@test !haskey(vm, 2)
@test get(vm, -1, -100) == -100

vm2 = deepcopy(vm)
@test vm2 == vm

# @test sprint(show, vm) == "VertexMap: $(vm.data)"

g = G(10,20)
m = VertexMap(g, i -> i^2)
@test typeof(m.data) == Vector{V}
@test length(m.data) == 10
@test length(m) == 10
for i=1:10
    @test m[i] == i^2
end

m = VertexMap(g, i -> rand(2))
@test typeof(m.data) == Vector{Vector{Float64}}
@test length(m.data) == length(m) == nv(g)
@test  eltype(m) == valtype(m) == eltype(m.data) == Vector{Float64}

end # testset
