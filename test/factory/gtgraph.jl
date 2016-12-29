g = GTGraph(10)
@test graphtype(g) == GTGraph
@test digraphtype(g) == GTDiGraph
@test edgetype(g) == GTEdge

g = GTDiGraph(10)
@test graphtype(g) == GTGraph
@test digraphtype(g) == GTDiGraph
@test edgetype(g) == GTEdge
