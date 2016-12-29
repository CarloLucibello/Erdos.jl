e1 = E(1,2)
re1 = E(2,1)
@test e1.src == src(e1) == 1
@test e1.dst == dst(e1) == 2
@test reverse(e1) == re1

e5 = E(3,5)

@test is_ordered(e5)
@test !is_ordered(reverse(e5))
