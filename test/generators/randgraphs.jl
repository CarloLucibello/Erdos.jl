@testset "$TEST $G" begin

r1 = G(10,20)
r2 = DG(5,10)
@test typeof(r1) == G
@test typeof(r2) == DG
@test nv(r1) == 10
@test ne(r1) == 20
@test nv(r2) == 5
@test ne(r2) == 10

@test G(10, 20, seed=3) == G(10, 20, seed=3)
@test DG(10, 20, seed=3) == DG(10, 20, seed=3)
@test G(10, 20, seed=3) == erdos_renyi(10, 20, G, seed=3)
@test ne(G(10, 40, seed=3)) == 40
@test ne(DG(10, 80, seed=3)) == 80

er = erdos_renyi(10, 0.5, G)
@test nv(er) == 10
@test ne(er) < 40
@test is_directed(er) == false

er = erdos_renyi(10, 0.5, DG)
@test nv(er) == 10
@test is_directed(er) == true

er = erdos_renyi(10, 0.5, G, seed=17)
@test nv(er) == 10
@test is_directed(er) == false


ws = watts_strogatz(10, 4, 0.2,  G)
@test nv(ws) == 10
@test ne(ws) == 20
@test is_directed(ws) == false

ws = watts_strogatz(10, 4, 0.2, DG)
@test nv(ws) == 10
@test ne(ws) == 20
@test is_directed(ws) == true

ba = barabasi_albert(10, 2,  G)
@test nv(ba) == 10
@test ne(ba) == 16
@test is_directed(ba) == false

ba = barabasi_albert(10, 2, 2,  G)
@test nv(ba) == 10
@test ne(ba) == 16
@test is_directed(ba) == false

ba = barabasi_albert(10, 4, 2, G)
@test nv(ba) == 10
@test ne(ba) == 12
@test is_directed(ba) == false

ba = barabasi_albert!(CompleteGraph(2, G), 10, 2)
@test nv(ba) == 10
@test ne(ba) == 17
@test is_directed(ba) == false

ba = barabasi_albert!(CompleteGraph(2, G), 10, 2)
@test nv(ba) == 10
@test ne(ba) == 17
@test is_directed(ba) == false

ba = barabasi_albert!(CompleteGraph(4, G), 10, 2)
@test nv(ba) == 10
@test ne(ba) == 18
@test is_directed(ba) == false

ba = barabasi_albert(10, 2, DG)
@test nv(ba) == 10
@test ne(ba) == 16
@test is_directed(ba) == true

ba = barabasi_albert(10, 2, 2, DG)
@test nv(ba) == 10
@test ne(ba) == 16
@test is_directed(ba) == true

ba = barabasi_albert(10, 4, 2, DG)
@test nv(ba) == 10
@test ne(ba) == 12
@test is_directed(ba) == true

ba = barabasi_albert!(CompleteDiGraph(2, DG), 10, 2)
@test nv(ba) == 10
@test ne(ba) == 18
@test is_directed(ba) == true

ba = barabasi_albert!(CompleteDiGraph(2, DG), 10, 2)
@test nv(ba) == 10
@test ne(ba) == 18
@test is_directed(ba) == true

ba = barabasi_albert!(CompleteDiGraph(4, DG), 10, 2)
@test nv(ba) == 10
@test ne(ba) == 24
@test is_directed(ba) == true

fm = static_fitness_model(20, rand(10), G)
@test nv(fm) == 10
@test ne(fm) == 20
@test is_directed(fm) == false

fm = static_fitness_model(20, rand(10), rand(10), DG)
@test nv(fm) == 10
@test ne(fm) == 20
@test is_directed(fm) == true

sf = static_scale_free(10, 20, 2.0, G)
@test nv(sf) == 10
@test ne(sf) == 20
@test is_directed(sf) == false

sf = static_scale_free(10, 20, 2.0, 2.0, DG)
@test nv(sf) == 10
@test ne(sf) == 20
@test is_directed(sf) == true

rr = random_regular_graph(5, 0, G)
@test nv(rr) == 5
@test ne(rr) == 0
@test is_directed(rr) == false

rd = random_regular_digraph(10,0)
@test nv(rd) == 10
@test ne(rd) == 0
@test is_directed(rd)

rr = random_regular_graph(6, 3, G, seed=1)
@test nv(rr) == 6
@test ne(rr) == 9
@test is_directed(rr) == false

rr = random_regular_graph(100, 5, G)
@test nv(rr) == 100
@test ne(rr) == 250
@test is_directed(rr) == false
for v in vertices(rr)
    @test degree(rr, v) == 5
end

rr = random_configuration_model(10, repeat([2,4] ,5), G, seed=3)
@test nv(rr) == 10
@test ne(rr) == 15
@test is_directed(rr) == false
num2 = 0; num4 = 0
for v in vertices(rr)
    d = degree(rr, v)
    @test  d == 2 || d == 4
    d == 2 ? num2 += 1 : num4 += 1
end
@test num4 == 5
@test num2 == 5

rr = random_configuration_model(100, zeros(Int,100), G)
@test nv(rr) == 100
@test ne(rr) == 0
@test is_directed(rr) == false

rr = random_configuration_model(3, [2,2,2], G, check_graphical=true)
@test nv(rr) == 3
@test ne(rr) == 3
@test is_directed(rr) == false

rd = random_regular_digraph(100, 4, DG)
@test nv(rd) == 100
@test ne(rd) == 400
@test is_directed(rd)
@test std(out_degree(rd)) == 0

rd = random_regular_digraph(100, 4, DG, dir=:in)
@test nv(rd) == 100
@test ne(rd) == 400
@test is_directed(rd)
@test std(in_degree(rd)) == 0

rr = random_regular_graph(10, 8, G, seed=4)
@test nv(rr) == 10
@test ne(rr) == 40
@test is_directed(rr) == false
for v in vertices(rr)
    @test degree(rr, v) == 8
end

rd = random_regular_digraph(10, 8, DG, dir=:out, seed=4)
@test nv(rd) == 10
@test ne(rd) == 80
@test is_directed(rd)

g = stochastic_block_model(2., 3., [100,100], G)
@test  3.5 < mean(degree(g)) < 6.5
g = stochastic_block_model(3., 4., [100,100,100])
@test  9.5 < mean(degree(g)) < 12.5

end # testset
