@testset "$TEST $G" begin

g = readgraph(:lesmis, G)
@test typeof(g) == G
@test nv(g) == 77
@test ne(g) == 254
@test has_self_loops(g) == false

g = readgraph(:serengetifoodweb, G)
@test typeof(g) == DG
@test ne(g) == 592
@test nv(g) == 161
@test has_self_loops(g) == true

g = readgraph(:adjnoun, G)
@test nv(g) ==  112
@test ne(g) ==   425
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:as22july06, G)
@test nv(g) == 22963
@test ne(g) ==  48436
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:astroph, G)
@test nv(g) == 16706
@test ne(g) ==  121251
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:celegansneural, G)
@test nv(g) ==  297
# @test ne(g) == 2359
@test ne(g) == 2345 # multiedges?
@test typeof(g) == DG
@test has_self_loops(g) == false

g = readgraph(:condmat, G)
@test nv(g) == 16726
@test ne(g) ==  47594
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:condmat2003, G)
@test nv(g) ==31163
@test ne(g) == 120029
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:condmat2005, G)
@test nv(g) ==40421
@test ne(g) == 175693
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:dolphins, G)
@test nv(g) ==  62
@test ne(g) ==   159
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:emailenron, G)
@test nv(g) == 36692
@test ne(g) ==  183831
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:football, G)
@test nv(g) ==  115
# @test ne(g) == 615 # multiedges?
@test ne(g) ==  613
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:hepth, G)
@test nv(g) == 8361
@test ne(g) ==  15751
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:karate, G)
@test nv(g) ==  34
@test ne(g) ==   78
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:lesmis, G)
@test nv(g) ==  77
@test ne(g) ==   254
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:netscience, G)
@test nv(g) ==  1589
@test ne(g) ==   2742
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:pgpstrong2009, G)
@test nv(g) ==39796
@test ne(g) == 301498
@test typeof(g) == DG
@test has_self_loops(g) == false

g = readgraph(:polblogs, G)
@test nv(g) ==  1490
# @test ne(g) ==  19090
@test ne(g) ==  19025 #multiedges
@test typeof(g) == DG
@test has_self_loops(g) == true

g = readgraph(:polbooks, G)
@test nv(g) ==  105
@test ne(g) ==  441
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:power, G)
@test nv(g) ==  4941
@test ne(g) ==   6594
@test typeof(g) == G
@test has_self_loops(g) == false

g = readgraph(:serengetifoodweb, G)
@test nv(g) ==  161
@test ne(g) ==   592
@test typeof(g) == DG
@test has_self_loops(g) == true

end #testset
