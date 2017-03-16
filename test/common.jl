#TODO add to Erdos api
function test_networks_eq(g::ANetOrDiNet, h::ANetOrDiNet)
    @test h == g

    @test sort(gprop_names(h)) == sort(gprop_names(g))
    @test sort(vprop_names(h)) == sort(vprop_names(g))
    @test sort(eprop_names(h)) == sort(eprop_names(g))

    for (pname, p) in gprops(h)
        @test p == gprop(g, pname)
    end

    for (pname, p) in vprops(h)
        vh = [p[i] for i=1:nv(g)]
        vg = vprop(g, pname)
        if valtype(p) <: Union{AbstractFloat,Vector{Float64}}  #TODO use where T <: AbstractFloat
            if VERSION < v"0.6dev"
                @test all(isapprox.(vh, vg))
            else
                @test vh ≈ vg
            end
        else
            @test vh == vg
        end
    end

    for (pname, p) in eprops(h)
        vh = [p[e] for e in edges(h)]
        vg = [eprop(g, pname)[src(e), dst(e)] for e in edges(h)] # edge indexes in g could be different
        if valtype(p) <: Union{AbstractFloat,Vector{Float64}}  #TODO use where T <: AbstractFloat
            if VERSION < v"0.6dev"
                @test all(isapprox.(vh, vg))
            else
                @test vh ≈ vg
            end
        else
            @test vh == vg
        end
    end
end
