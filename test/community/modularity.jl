@testset "$TEST $G" begin

n = 10
m = n*(n-1)/2
c = ones(Int, n)
g = CompleteGraph(n, G)
@test  modularity(g, c) == 0
#
g = G(n)
@test modularity(g, c) == 0

end # testset
