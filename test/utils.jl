s = FatGraphs.sample!([1:10;], 3)
@test length(s) == 3
for  e in s
    @test 1 <= e <= 10
end

s = FatGraphs.sample!([1:10;], 6, exclude=[1,2])
@test length(s) == 6
for  e in s
    @test 3 <= e <= 10
end

@test FatGraphs.nth((i for i in 11:21), 2) == 12
@test_throws BoundsError FatGraphs.nth((i for i in 1:10), 11)
