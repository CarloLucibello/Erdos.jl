@testset "$TEST $G" begin

g =G(2)
add_edge!(g,1,2)
w = EdgeMap(g, Int)
w[1,2]=500
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 2

g = CompleteGraph(4, G)
w = EdgeMap(g, Int)
w[1,2]=500
w[1,3]=600
w[2,3]=700
w[3,4]=100
w[2,4]=1000
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 2
@test match.mate[2] == 1
@test match.mate[3] == 4
@test match.mate[4] == 3
@test match.weight == 600

g = CompleteGraph(4, G)
w = EdgeMap(g, Int)
w[1, 2]=500
w[1, 3]=400
w[2, 3]=300
w[3, 4]=1000
w[2, 4]=1000
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 3
@test match.mate[2] == 4
@test match.mate[3] == 1
@test match.mate[4] == 2
@test match.weight == 1400

g =CompleteBipartiteGraph(2,2, G)
w = EdgeMap(g, Float64)
w[1,3] = 10
w[1,4] = 19.5
w[2,3] = 9
w[2,4] = 19
match = minimum_weight_perfect_matching(g, w)
@test match.mate[1] == 4
@test match.mate[4] == 1
@test match.mate[2] == 3
@test match.mate[3] == 2
@test match.weight == 28.5

g =CompleteGraph(4, G)
w = EdgeMap(g, Float64)
w[1,3] = 10
w[1,4] = 0.5
w[2,3] = 11
w[2,4] = 2
w[1,2] = 100
match = minimum_weight_perfect_matching(g, w, 50)
@test match.mate[1] == 4
@test match.mate[4] == 1
@test match.mate[2] == 3
@test match.mate[3] == 2
@test match.weight == 11.5

w = (s=sprand(100,100,0.2); s=s+s'; s-Diagonal(s))
g = Graph(w)
match = minimum_weight_perfect_matching(g, EdgeMap(g, w))
for i=1:nv(g)
    j = match.mate[i]
    @test match.mate[j] == i
end

# TEST matching 1D
dist_periodic_bc(a,b,R) = abs(a-b)<0.5*R ? abs(a-b) : R-abs(a-b)

N=100
p=2.
g = CompleteGraph(N)
for r in 1:100
    w = EdgeMap(g, Float64)
    points = sort(rand(N))
    for e in edges(g)
        i, j = src(e), dst(e)
        w[i,j] = dist_periodic_bc(points[i], points[j], 1)^p
    end
    match = minimum_weight_perfect_matching(g, w)
    if p>1
        if match.mate[1]==2
            for i=2:nv(g)
                @test match.mate[i] ==(i - (-1)^i) % (N+1)
            end
        elseif match.mate[1] == N
            for i=2:nv(g)
                @test match.mate[i] == (i + (-1)^i) % N
            end
        end
    elseif p < 0
        for i=1:nv(g)
            @test match.mate[i] == (i + N/2) % N
        end
    end
end

end # testset
