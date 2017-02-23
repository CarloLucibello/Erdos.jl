using Erdos
using MatrixDepot
using Base.Profile

"""Find the largest connected component of graph and return it as a vector of indices."""
function symmetrize(A)
    println("Symmetrizing ")
    tic()
    if !issymmetric(A)
        println(STDERR, "the matrix is not symmetric using A+A'")
        A = A + A'
    end
    if isa(A, Base.LinAlg.Symmetric)
        A.data.nzval = abs(A.data.nzval)
    else
        A.nzval = abs(A.nzval)
    end
    #= spA = abs(sparse(A)) =#
    toc()
    return A
end

function loadmat(matname)
    println("Reading MTX of $matname")
    tic()
    A = matrixdepot(matname, :read)
    A = symmetrize(A)
    tic()
    g = Graph(A)
    return g
end

names = ["Newman/football" , "Newman/cond-mat-2003", "SNAP/amazon0302","SNAP/roadNet-CA"]
sucesses = []
failures = []
for matname in names
    println("Working on $matname")
    g = loadmat(matname)
    println("Finding Components")
    visitor = Erdos.TreeBFSVisitorVector(zeros(Int, nv(g)))
    label = zeros(Int, nv(g))
    @time label = Erdos.connected_components!(label, g)
    @time components = Erdos.connected_components!(visitor, g)
    fill!(visitor.tree, 0)
    @time Erdos.bfs_tree!(visitor, g, 1)
    @show length(components)
    #=
    @time components_slow = Erdos.connected_components(g)
    @assert length(components) == length(components_slow)
    =#
end
