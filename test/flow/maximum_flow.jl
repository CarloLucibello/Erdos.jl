#### Graphs for testing
graphs = [
  # Graph with 8 vertices
  (8,
   [
     (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
     (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
     (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
   ],
   1,8, # source/target
   3,   # answer for default capacity
   28,  # answer for custom capacity
   15,5 # answer for restricted capacity/restriction
  ),

  # Graph with 6 vertices
  (6,
   [
     (1,2,9),(1,3,9),(2,3,10),(2,4,8),(3,4,1),
     (3,5,3),(5,4,8),(4,6,10),(5,6,7)
   ],
   1,6, # source/target
   2,   # answer for default capacity
   12,  # answer for custom capacity
   8,5  # answer for restricted capacity/restriction
  )
]

for (nvertices,flow_edges,s,t,fdefault,fcustom,frestrict,caprestrict) in graphs
    flow_graph = DG(nvertices)
    capacity_matrix = zeros(Int,nvertices,nvertices)
    for e in flow_edges
        u,v,f = e
        add_edge!(flow_graph,u,v)
        capacity_matrix[u,v] = f
    end

    # Test DefaultCapacity
    d = FatGraphs.DefaultCapacity(flow_graph)
    @test typeof(d) <: AbstractMatrix{Int}
    @test d[s,t] == 0
    @test size(d) == (nvertices,nvertices)
    @test typeof(transpose(d)) == FatGraphs.DefaultCapacity{DG}
    @test typeof(ctranspose(d)) == FatGraphs.DefaultCapacity{DG}

    fdef1, Fdef1, labdef1 = maximum_flow(flow_graph,s,t)
    fdef2, Fdef2, labdef2 = maximum_flow(flow_graph,s,t, capacity_matrix)
    # Test all algorithms
    for ALGO in [EdmondsKarpAlgorithm, DinicAlgorithm, BoykovKolmogorovAlgorithm, PushRelabelAlgorithm]
        f, F, lab = maximum_flow(flow_graph,s,t,algorithm=ALGO())
        @test f == fdefault
        @test lab == labdef1

        f, F, lab = maximum_flow(flow_graph,s,t,capacity_matrix,algorithm=ALGO())
        @test f == fcustom
        @test lab == labdef2

        @test maximum_flow(flow_graph,s,t,capacity_matrix,algorithm=ALGO(),restriction=caprestrict)[1] == frestrict
    end
end

n = 30
s = n+1
t = n+2
g = random_regular_digraph(n, 3, DG)
c = spzeros(n+2,n+2)
for e in edges(g)
    c[src(e), dst(e)] = rand()
end
add_vertices!(g, 2)
for i=1:10
    j = rand(1:n)
    add_edge!(g, s, j)
    c[s, j] = rand()

    j = rand(1:n)
    add_edge!(g, j, t)
    c[j, t] = rand()
end

fdef, Fdef, labdef = maximum_flow(g,s,t)
fcustom, Fcustom, labcustom = maximum_flow(g,s,t, c)

enedef, cutdef, labd = minimum_cut(g,s,t)
enecustom, cutcustom, labc = minimum_cut(g,s,t, c)
@test enedef ≈ fdef
@test enecustom ≈ fcustom
@test labd == labdef
@test labc == labcustom
for e in cutcustom
    @test has_edge(g, e)
    @test labc[src(e)] == labc[s]
    @test labc[dst(e)] == labc[t]
end
for e in cutdef
    @test has_edge(g, e)
    @test labd[src(e)] == labd[s]
    @test labd[dst(e)] == labd[t]
end
for ALGO in [EdmondsKarpAlgorithm, DinicAlgorithm, BoykovKolmogorovAlgorithm, PushRelabelAlgorithm]
    f, F, lab = maximum_flow(g,s,t,algorithm=ALGO())
    @test f ≈ fdef
    @test lab == labdef
    f, F, lab = maximum_flow(g,s,t,c,algorithm=ALGO())
    @test f ≈ fcustom
    @test lab == labcustom
end
