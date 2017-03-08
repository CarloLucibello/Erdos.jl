@testset "$TEST $G" begin

s = Erdos.sample!([1:10;], 3)
@test length(s) == 3
for  e in s
    @test 1 <= e <= 10
end

s = Erdos.sample!([1:10;], 6, exclude=[1,2])
@test length(s) == 6
for  e in s
    @test 3 <= e <= 10
end

@test Erdos.nth((i for i in 11:21), 2) == 12
@test_throws BoundsError Erdos.nth((i for i in 1:10), 11)

end # testset
