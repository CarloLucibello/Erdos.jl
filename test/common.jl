
NumTypes = Union{Number, Vector{Float32}, Vector{Float64}} # TODO use where T<>:Number in 0.6

#TODO add to Erdos api
function test_networks_eq(g::ANetOrDiNet, h::ANetOrDiNet)
    @test h == g

    @test sort(gprop_names(h)) == sort(gprop_names(g))
    @test sort(vprop_names(h)) == sort(vprop_names(g))
    @test sort(eprop_names(h)) == sort(eprop_names(g))

    for (pname, ph) in gprops(h)
        @test has_gprop(g, pname)
        # @test typeof(ph) == typeof(gprop(g, pname))
        if  typeof(ph) <: NumTypes
            @test ph ≈ gprop(g, pname)
        else
            @test ph == gprop(g, pname)
        end
    end

    for (pname, ph) in vprops(h)
        @test has_vprop(g, pname)
        pg = vprop(g, pname)
        # @test valtype(pg) == valtype(ph)
        for i=1:nv(g)
            @test  hasindex(ph, i) == hasindex(pg, i)
            hasindex(ph, i) || continue
            if valtype(ph) <: NumTypes
                @test ph[i] ≈ pg[i]
            else
                @test ph[i] == pg[i]
            end
        end
    end

    for (pname, ph) in eprops(h)
        @test has_eprop(g, pname)
        pg = eprop(g, pname)
        # @test valtype(pg) == valtype(ph)
        for e in edges(h)
            i, j = src(e), dst(e)
            @test  haskey(ph, e) == haskey(pg, i, j)
            haskey(ph, e) || continue
            if valtype(ph) <: NumTypes
                @test ph[e] ≈ pg[i,j]
            else
                @test ph[e] == pg[i,j]
            end
        end
    end
end
