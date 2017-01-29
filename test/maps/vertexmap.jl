vm = ConstVertexMap(0)
@test typeof(vm) <: AVertexMap
@test get(vm, 1, 1) == 0
@test get(vm, -1, 1) == 0
vm[1] = 1
@test vm[1] == 0
@test hasindex(vm, 1)
@test hasindex(vm, -1)
@test length(vm) == typemax(Int)

vm = rand(1:10,10)
@test typeof(vm) <: AVertexMap
@test hasindex(vm, 1)
@test !hasindex(vm, -1)

vm = Dict{V, Float64}()
@test VertexMap(g, Float64) == vm
@test typeof(vm) <: AVertexMap

vm[1] = 2.
@test hasindex(vm, 1)
@test !hasindex(vm, 2)
