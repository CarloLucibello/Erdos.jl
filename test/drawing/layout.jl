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
