# include("../src/FatGraphs.jl")
using FatGraphs
using BenchmarkTools
using Base.Dates
import JLD: load, save
import Glob: glob

TUNE = false
# TUNE = true
LOAD_PARS = true
# LOAD_PARS = false
SAVE_RES = false
# SAVE_RES = false

GROUPS = ["generators","flow"]

function tune_and_savepars!(suite)
    tune!(suite)
    save("parameters/$(Date(now())).jld", "suite", params(suite))
end

function loadpars!(suite)
    files = glob("parameters/*")
    dates = map(x -> Date(split(x, ['.','/'])[2]), files)
    f = "parameters/$(maximum(dates)).jld"
    loadparams!(suite, load(f, "suite"), :evals, :samples)
end

function saveres(res)
    save("results/$(Date(now())).jld", "res", res)
end

function loadres()
    files = glob("results/*")
    dates = map(x -> Date(split(x, ['.','/'])[2]), files)
    f = "results/$(maximum(dates)).jld"
    return load(f, "res")
end

suite = BenchmarkGroup()

### SUITE GENERATORS #########
suite["generators"] = BenchmarkGroup()

n=10; k=3; seed=17
suite["generators"]["rrg1"] = @benchmarkable random_regular_graph($n, $k, seed=$seed)
suite["generators"]["erdos1"] = @benchmarkable erdos_renyi($n, $k, seed=$seed)

n=100; k=3; seed=17
suite["generators"]["rrg2"] = @benchmarkable random_regular_graph($n, $k, seed=$seed)
suite["generators"]["erdos2"] = @benchmarkable erdos_renyi($n, $k, seed=$seed)

n=1000; k=3; seed=17
suite["generators"]["rrg3"] = @benchmarkable random_regular_graph($n, $k, seed=$seed)
suite["generators"]["erdos3"] = @benchmarkable erdos_renyi($n, $k, seed=$seed)

### SUITE FLOW #########
suite["flow"] = BenchmarkGroup()

edgs = [
  (1,2,10),(1,3,5),(1,4,15),(2,3,4),(2,5,9),
  (2,6,15),(3,4,4),(3,6,8),(4,7,16),(5,6,15),
  (5,8,10),(6,7,15),(6,8,10),(7,3,6),(7,8,10)
]

flow_graph = DiGraph(8)
capacity_matrix = zeros(Int,8,8)
for e in edgs
    u,v,f = e
    add_edge!(flow_graph,u,v)
    capacity_matrix[u,v] = f
end

suite["flow"]["push_relabel"] = @benchmarkable maximum_flow($flow_graph, 1, 8
                    , $capacity_matrix, algorithm=PushRelabelAlgorithm())
suite["flow"]["dinic"] = @benchmarkable maximum_flow($flow_graph, 1, 8
                    , $capacity_matrix, algorithm=DinicAlgorithm())

####  TUNING / LOADING / SAVING PARAMS

TUNE && tune_and_savepars!(suite)
LOAD_PARS && loadpars!(suite)

#####  RUNNING ###################
res = run(suite, verbose=true)

#### COMPARISONS ##########
resold = loadres()

has_regressions = false
has_improves = true
for group in GROUPS
    m = median(res[group])
    println(m)
    !haskey(resold, group) && continue

    mold = median(resold[group])
    judgement = judge(m, mold)

    regr = regressions(judgement)
    if length(regr) > 0
        has_regressions = false
        warn("REGRESSIONS FOUND:")
        println(regr)
    end
    improvs = improvements(judgement)
    if length(improvs) > 0
        has_improves = true
        print_with_color(:green, "IMPROVEMENTS FOUND:\n")
        println(improvs)
    end
end

###  SAVING ############
# if SAVE_RES && !has_improves && !has_regressions
# TODO 
SAVE_RES &&  saveres(res)
