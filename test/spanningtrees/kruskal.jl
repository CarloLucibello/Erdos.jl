@testset "$TEST $G" begin

# TODO one commented out test here intermittenlty fails on Travis
g = G(4)
add_edge!(g, 1,2)
add_edge!(g, 1,3)
add_edge!(g, 1,4)
add_edge!(g, 2,1)
add_edge!(g, 2,3)
add_edge!(g, 2,4)
add_edge!(g, 3,1)
add_edge!(g, 3,2)
add_edge!(g, 3,4)
add_edge!(g, 4,1)
add_edge!(g, 4,2)
add_edge!(g, 4,3)

# Creating custom adjacency matrix
distmx = zeros(4,4)

# Populating custom adjacency matrix
distmx[1,2] = 1
distmx[1,3] = 5
distmx[1,4] = 6
distmx[2,1] = 1
distmx[2,3] = 4
distmx[2,4] = 10
distmx[3,1] = 5
distmx[3,2] = 4
distmx[3,4] = 3
distmx[4,1] = 6
distmx[4,2] = 10
distmx[4,3] = 3

# Testing Kruskal's algorithm
mst = minimum_spanning_tree(g, distmx)
vec_mst = Vector{E}()
push!(vec_mst, E(1, 2))
push!(vec_mst, E(3, 4))
push!(vec_mst, E(2, 3))

@test mst == vec_mst

#second test
g = G(8)
add_edge!(g, 2,8)
add_edge!(g, 1,3)
add_edge!(g, 6,8)
add_edge!(g, 1,8)
add_edge!(g, 3,4)
add_edge!(g, 2,4)
add_edge!(g, 2,6)
add_edge!(g, 3,8)
add_edge!(g, 6,5)
add_edge!(g, 2,3)
add_edge!(g, 5,7)
add_edge!(g, 1,7)
add_edge!(g, 4,7)
add_edge!(g, 7,3)
add_edge!(g, 1,5)
add_edge!(g, 5,8)

distmx_sec = zeros(8, 8)
distmx_sec[2,8] = 0.19
distmx_sec[8,2] = 0.19
distmx_sec[1,3] = 0.26
distmx_sec[3,1] = 0.26
distmx_sec[6,8] = 0.28
distmx_sec[8,2] = 0.28
distmx_sec[1,8] = 0.16
distmx_sec[8,1] = 0.16
distmx_sec[3,4] = 0.17
distmx_sec[4,3] = 0.17
distmx_sec[2,4] = 0.29
distmx_sec[4,2] = 0.29
distmx_sec[2,6] = 0.32
distmx_sec[6,2] = 0.32
distmx_sec[3,8] = 0.34
distmx_sec[8,3] = 0.34
distmx_sec[5,6] = 0.35
distmx_sec[6,5] = 0.35
distmx_sec[2,3] = 0.36
distmx_sec[3,2] = 0.36
distmx_sec[5,7] = 0.93
distmx_sec[7,5] = 0.93
distmx_sec[1,7] = 0.58
distmx_sec[7,1] = 0.58
distmx_sec[4,7] = 0.52
distmx_sec[7,4] = 0.52
distmx_sec[3,7] = 0.40
distmx_sec[7,3] = 0.40
distmx_sec[1,5] = 0.38
distmx_sec[5,1] = 0.38
distmx_sec[5,8] = 0.37
distmx_sec[8,5] = 0.37

mst2 = minimum_spanning_tree(g, distmx_sec)
vec2 = Vector{E}()
push!(vec2, E(1, 8))
push!(vec2, E(3, 4))
push!(vec2, E(2, 8))
push!(vec2, E(1, 3))
push!(vec2, E(6, 8))
push!(vec2, E(5, 6))
push!(vec2, E(3, 7))

@test mst2 == vec2


n = 10; m = 20
g = G(n, m)
g = blockdiag(g, g)
d = blockdiag(sparse(rand(n, n)), sparse(rand(n, n)))
d = d + d'
mst = minimum_spanning_tree(g, d)
#@test_skip length(mst) == 2n - 2 #TODO
for e in mst
    @test has_edge(g, e)
    u , v  = src(e), dst(e)
    u , v = u < v ? (u,v) : (v,u)
    @test  1 <= u < v <= 10 || 11 <= u < v <= 20
end

end # testset
