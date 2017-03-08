@testset "$TEST $G" begin

if !isdefined(:readcentrality)
    function readcentrality(f::AbstractString)
        f = open(f,"r")
        c = Vector{Float64}()
        while !eof(f)
            line = chomp(readline(f))
            push!(c, float(line))
        end
        return c
    end
end


g = readgraph(joinpath(testdir,"testdata","graph-50-500.gml"),:gml)

c = readcentrality(joinpath(testdir,"testdata","graph-50-500-bc.txt"))
z = betweenness_centrality(g)

@test map(Float32, z) == map(Float32, c)

y = betweenness_centrality(g, endpoints=true, normalize=false)
@test round.(y[1:3],4) ==
    round.([122.10760591498584, 159.0072453120582, 176.39547945994505], 4)
x = betweenness_centrality(g; approx=3)
@test length(x) == 50

# self loops
s2 = DG(3)
add_edge!(s2,1,2); add_edge!(s2,2,3); add_edge!(s2,3,3)
s1 = graph(s2)

@test betweenness_centrality(s1) == [0, 1, 0]
@test betweenness_centrality(s2) == [0, 0.5, 0]

g = G(2)
add_edge!(g,1,2)
z = betweenness_centrality(g; normalize=true)
@test z[1] == z[2] == 0.0


g3 = PathGraph(5, G)
z = betweenness_centrality(g3; normalize=false)
@test z[1] == z[5] == 0.0

end # testset
