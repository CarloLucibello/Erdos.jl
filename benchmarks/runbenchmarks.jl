include("../src/FatGraphs.jl")
using FatGraphs
using BenchmarkTools
using Base.Dates
import JLD: load, save

TUNE = false
LOAD_PARS = true
SAVE_RES = false

bench_dir = Base.source_dir()

### ADD BENCHMARKS  ###############
suite = BenchmarkGroup()
GLIST = [Graph{Int64}, GTGraph]
DGLIST = [DiGraph{Int64}, GTDiGraph]
GROUPS = [
            "core",
            "generators",
            # "flow",
            "centrality",
            # "dismantling",
            "connectivity"
         ]

# GROUPS = ["core"]
for group in GROUPS
    include("$group/$group.jl")
end

####  TUNING / LOADING / SAVING PARAMS

function tune_and_savepars!(suite)
    tune!(suite)
    path = joinpath(bench_dir,"parameters","$(Date(now())).jld")
    save(path, "suite", params(suite))
end

function loadpars!(suite)
    path = joinpath(bench_dir, "parameters")
    files = readdir(path)
    dates = map(x -> Date(split(x, ['.'])[1]), files)
    f = joinpath(bench_dir, "parameters","$(maximum(dates)).jld")
    loadparams!(suite, load(f, "suite"), :evals, :samples)
end

function saveres(res)
    path = joinpath(bench_dir,"results","$(Date(now())).jld")
    save(path, "res", res)
end

function loadres()
    path = joinpath(bench_dir, "results")
    files = readdir(path)
    dates = map(x -> Date(split(x, ['.'])[1]), files)
    f = joinpath(bench_dir, "results","$(maximum(dates)).jld")
    return load(f, "res")
end

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
        print_with_color(:light_red, "REGRESSIONS FOUND:\n")
        println(regr)
        print_with_color(:light_red, "****************\n")
    end
    improvs = improvements(judgement)
    if length(improvs) > 0
        has_improves = true
        print_with_color(:green, "IMPROVEMENTS FOUND:\n")
        println(improvs)
        print_with_color(:green, "****************\n")
    end
end

###  SAVING ############
# if SAVE_RES && !has_improves && !has_regressions
println()
if SAVE_RES
    saveres(res)
    println("Results saved!")
else
    println("Results not saved. Save the with `saveres(res)`")
end

"""
example: myjudge("core", "edges")
"""
function myjudge(names::String...)
    s = res
    sold = resold
    for n in names
        s = s[n]
        sold = sold[n]
    end
    return judge(median(s),median(sold))
end
