g = graph(:diamond, G)
@test nv(g) == 4 && ne(g) == 5
@test typeof(g) == G

g = graph(:bull, G)
@test nv(g) == 5 && ne(g) == 5

g = graph(:chvatal, G)
@test nv(g) == 12 && ne(g) == 24

g = graph(:cubical, G)
@test nv(g) == 8 && ne(g) == 12

g = graph(:desargues, G)
@test nv(g) == 20 && ne(g) == 30

g = graph(:dodecahedral, G)
@test nv(g) == 20 && ne(g) == 30

g = graph(:frucht, G)
@test nv(g) == 20 && ne(g) == 18

g = graph(:heawood, G)
@test nv(g) == 14 && ne(g) == 21

g = graph(:house, G)
@test nv(g) == 5 && ne(g) == 6

g = graph(:housex, G)
@test nv(g) == 5 && ne(g) == 8

g = graph(:icosahedral, G)
@test nv(g) == 12 && ne(g) == 30

g = graph(:krackhardtkite, G)
@test nv(g) == 10 && ne(g) == 18

g = graph(:moebiuskantor, G)
@test nv(g) == 16 && ne(g) == 24

g = graph(:octahedral, G)
@test nv(g) == 6 && ne(g) == 12

g = graph(:pappus, G)
@test nv(g) == 18 && ne(g) == 27

g = graph(:petersen, G)
@test nv(g) == 10 && ne(g) == 15

g = graph(:sedgewickmaze, G)
@test nv(g) == 8 && ne(g) == 10

g = graph(:tetrahedral, G)
@test nv(g) == 4 && ne(g) == 6

g = graph(:truncatedcube, G)
@test nv(g) == 24 && ne(g) == 36

g = graph(:truncatedtetrahedron, G)
@test nv(g) == 12 && ne(g) == 18 && !is_directed(g)

g = digraph(:truncatedtetrahedron, DG)
@test nv(g) == 12 && ne(g) == 18 && is_directed(g)
@test typeof(g) == DG


g = graph(:tutte, G)
@test nv(g) == 46 && ne(g) == 69

@test_throws ErrorException g = graph(:nonexistent, G)
