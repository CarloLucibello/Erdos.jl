@testset "$TEST $G" begin

if !@isdefined(scc_ok)
    function scc_ok(g)
      """Check that all SCC really are strongly connected"""
      scc = strongly_connected_components(g)
      scc_as_subgraphs = map(i -> g[i], scc)
      return all(is_strongly_connected, scc_as_subgraphs)
    end
end

g = G()
cc = connected_components(g)
@test cc == Vector{Int}[]

g = G(1)
cc = connected_components(g)
@test cc == [[1]]

g = G(2)
cc = connected_components(g)
@test cc == [[1],[2]]

g = DG()
cc = strongly_connected_components(g)
@test cc == Vector{Int}[]

g = DG(1)
cc = strongly_connected_components(g)
@test cc == Vector{Int}[Int[1]]


g = PathGraph(4, G)
add_vertices!(g,10)
add_edge!(g,5,6)
add_edge!(g,6,7)
add_edge!(g,8,9)
add_edge!(g,10,9)

@test !is_connected(g)

g6 = graph(:house, G)
@test is_connected(g6)

cc = connected_components(g)
label = zeros(Int, nv(g))
Erdos.connected_components!(label, g)
@test label[1:10] == [1,1,1,1,5,5,5,8,8,8]
import Erdos: components, components_dict
cclab = components_dict(label)
@test cclab[1] == [1,2,3,4]
@test cclab[5] == [5,6,7]
@test cclab[8] == [8,9,10]
@test length(cc) >= 3 && sort(cc[3]) == [8,9,10]

g10 = DG(4)
add_edge!(g10,1,3)
add_edge!(g10,2,4)
@test is_bipartite(g10) == true
add_edge!(g10,1,4)
@test is_bipartite(g10) == true

g10 = DG(20)
for m=1:50
    i = rand(1:10)
    j = rand(11:20)
    if rand() < 0.5
        i, j = j, i
    end
    if !has_edge(g10, i, j)
        add_edge!(g10, i, j)
        @test is_bipartite(g10) == true
    end
end

# graph from https://en.wikipedia.org/wiki/Strongly_connected_component
h = DG(8)
add_edge!(h,1,2); add_edge!(h,2,3); add_edge!(h,2,5);
add_edge!(h,2,6); add_edge!(h,3,4); add_edge!(h,3,7);
add_edge!(h,4,3); add_edge!(h,4,8); add_edge!(h,5,1);
add_edge!(h,5,6); add_edge!(h,6,7); add_edge!(h,7,6);
add_edge!(h,8,4); add_edge!(h,8,7)

@test is_weakly_connected(h)
#TODO
# @test_throws MethodError is_connected(h)

scc = strongly_connected_components(h)
wcc = weakly_connected_components(h)
# @test_throws MethodError connected_components(h)

@test length(scc) == 3 && sort(scc[3]) == [1,2,5]
@test length(wcc) == 1 && length(wcc[1]) == nv(h)

# the two graphs below are isomorphic (exchange 2 <--> 4)
h = DG(4);  add_edge!(h, 1, 4); add_edge!(h, 4, 2); add_edge!(h, 2, 3); add_edge!(h, 1, 3);
h2 = DG(4); add_edge!(h2, 1, 2); add_edge!(h2, 2, 4); add_edge!(h2, 4, 3); add_edge!(h2, 1, 3);
@test scc_ok(h)
@test scc_ok(h2)

h = DG(6)
add_edge!(h,1,3); add_edge!(h,3,4); add_edge!(h,4,2); add_edge!(h,2,1)
add_edge!(h,3,5); add_edge!(h,5,6); add_edge!(h,6,4)

scc = strongly_connected_components(h)

@test length(scc) == 1 && sort(scc[1]) == [1:6;]

# tests from Graphs.jl
h = DG(4)
add_edge!(h,1,2); add_edge!(h,2,3); add_edge!(h,3,1); add_edge!(h,4,1)
scc = strongly_connected_components(h)
@test length(scc) == 2 && sort(scc[1]) == [1:3;] && sort(scc[2]) == [4]

h = DG(12)
add_edge!(h,1,2); add_edge!(h,2,3); add_edge!(h,2,4); add_edge!(h,2,5);
add_edge!(h,3,6); add_edge!(h,4,5); add_edge!(h,4,7); add_edge!(h,5,2);
add_edge!(h,5,6); add_edge!(h,5,7); add_edge!(h,6,3); add_edge!(h,6,8);
add_edge!(h,7,8); add_edge!(h,7,10); add_edge!(h,8,7); add_edge!(h,9,7);
add_edge!(h,10,9); add_edge!(h,10,11); add_edge!(h,11,12); add_edge!(h,12,10)

scc = strongly_connected_components(h)
@test length(scc) == 4
@test sort(scc[1]) == [7,8,9,10,11,12]
@test sort(scc[2]) == [3, 6]
@test sort(scc[3]) == [2, 4, 5]
@test scc[4] == [1]

# Test examples with self-loops from
# Graph-Theoretic Analysis of Finite Markov Chains by J.P. Jarvis & D. R. Shier

# figure 1 example
fig1 = spzeros(5,5)
fig1[[3,4,9,10,11,13,18,19,22,24]] .= [.5,.4,.1,1.,1.,.2,.3,.2,1.,.3]
fig1 = DG(fig1)
scc_fig1 = Vector[[2,5],[1,3,4]]

# figure 2 example
fig2 = spzeros(5,5)
fig2[[3, 10, 11, 13, 14, 17, 18, 19, 22]] .= 1
fig2 = DG(fig2)

# figure 3 example
fig3 = spzeros(8,8)
fig3[[1,7,9,13,14,15,18,20,23,27,28,31,33,34,37,45,46,49,57,63,64]] .= 1
fig3 = DG(fig3)
scc_fig3 = Vector[[3,4],[2,5,6],[8],[1,7]]
fig3_cond = DG(4);
add_edge!(fig3_cond,4,3); add_edge!(fig3_cond,2,1)
add_edge!(fig3_cond,4,1); add_edge!(fig3_cond,4,2)

# construct a n-number edge ring graph (period = n)
n = 10
n_ring_m = spdiagm(1=>ones(n-1),-n+1=>[1]) 
n_ring = DG(n_ring_m)
n_ring_shortcut = copy(n_ring); add_edge!(n_ring_shortcut,1,4)
@test period(n_ring) == n
@test period(n_ring_shortcut) == 2

# figure 8 example
fig8 = spzeros(6,6)
fig8[[2,10,13,21,24,27,35]] .= 1
fig8 = DG(fig8)

@test Set(strongly_connected_components(fig1)) == Set(scc_fig1)
@test Set(strongly_connected_components(fig3)) == Set(scc_fig3)

@test condensation(fig3) == fig3_cond

@test attracting_components(fig1) == Vector[[2,5]]
@test attracting_components(fig3) == Vector[[3,4],[8]]

g10 = StarGraph(10, G)
@test neighborhood(g10, 1 , 0) == [1]
@test length(neighborhood(g10, 1, 1)) == 10
@test length(neighborhood(g10, 2, 1)) == 2
@test length(neighborhood(g10, 1, 2)) == 10
@test length(neighborhood(g10, 2, 2)) == 10

g10 = StarDiGraph(10, DG)
@test neighborhood(g10, 1 , 0, dir=:out) == [1]
@test length(neighborhood(g10, 1, 1, dir=:out)) == 10
@test length(neighborhood(g10, 2, 1, dir=:out)) == 1
@test length(neighborhood(g10, 1, 2, dir=:out)) == 10
@test length(neighborhood(g10, 2, 2, dir=:out)) == 1
@test neighborhood(g10, 1 , 0, dir=:in) == [1]
@test length(neighborhood(g10, 1, 1, dir=:in)) == 1
@test length(neighborhood(g10, 2, 1, dir=:in)) == 2
@test length(neighborhood(g10, 1, 2, dir=:in)) == 1
@test length(neighborhood(g10, 2, 2, dir=:in)) == 2

@test !is_graphical([1,1,1])
@test is_graphical([2,2,2])
@test is_graphical(fill(3,10))

end # testset
