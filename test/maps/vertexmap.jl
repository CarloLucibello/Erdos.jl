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

@test sprint(show, vm) == "VertexMap: $(vm.data)"

end # testset
