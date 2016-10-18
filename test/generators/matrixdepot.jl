g = matrixdepot("hilb", G, 4)
@test nv(g) == 4 && ne(g) == 10

g = matrixdepot("baart", DG, 4)
@test nv(g) == 4 && ne(g) == 16

@test_throws ErrorException matrixdepot("baart", G, 4)
