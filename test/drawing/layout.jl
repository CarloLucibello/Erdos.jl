@testset "spring_layout" begin
    g = G(10, 20)
    x, y = spring_layout(g, maxiters=20, inittemp=10, 
                        x0=rand(10), y0=rand(10),
                        k = 1/ 3)
    
    @test all(-1 .<= x .<= 1)
    @test all(-1 .<= y .<= 1)                     
end

@testset "circular_layout" begin
    g = G(10, 20)
    x, y = circular_layout(g)
    
    @test all(-1 .<= x .<= 1)
    @test all(-1 .<= y .<= 1)                     
end

@testset "shell_layout" begin
    g = G(10, 20)
    nlist = [[1], [2,3,4,5], [6,7,8,9,10]]
    x, y = shell_layout(g, nlist)
    @test x[1] == 0
    @test y[1] == 0
    @test x[2:5].^2 .+ y[2:5].^2 ≈ ones(4)
    @test x[6:10].^2 .+ y[6:10].^2 ≈ fill(4, 5)

    nlist = [[1,2,3,4,5], [6,7,8,9,10]]
    x, y = shell_layout(g, nlist)
    @test x[1:5].^2 .+ y[1:5].^2 ≈ ones(5)
    @test x[6:10].^2 .+ y[6:10].^2 ≈ fill(4, 5)

end
