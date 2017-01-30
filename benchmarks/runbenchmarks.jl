include("../src/FatGraphs.jl")
using FatGraphs
using BenchmarkTools
using Base.Dates
import JLD: load, save

TUNE = false
SAVE_RES = false
RUN_BENCH = true

VERS = VERSION >= v"0.6dev" ? "v0.6" : "v0.5"
bench_dir = Base.source_dir()
res_dir = joinpath(bench_dir, "results", VERS)
par_dir = joinpath(bench_dir, "parameters", VERS)

### ADD BENCHMARKS  ###############
suite = BenchmarkGroup()
GLIST = [Graph{Int64}, GTGraph]
DGLIST = [DiGraph{Int64}, GTDiGraph]
GROUPS = [
            "core",
            "generators",
            "flow",
            "centrality",
            "dismantling",
            "connectivity",
            "persistence",
            "shortestpaths",
            "traversals",
            "matching"
         ]

# GROUPS = ["core"]
for group in GROUPS
    include("$group/$group.jl")
end

####  LOADING / SAVING PARAMS
function savepars(suite)
    for group in GROUPS
        d = joinpath(par_dir, group)
        !isdir(d) && mkdir(d)
        path = joinpath(d, "$(Date(now())).jld")
        save(path, group, params(suite[group]))
    end
end

function loadpars!(suite)
    for group in GROUPS
        d = joinpath(par_dir,group)
        !isdir(d) && mkdir(d)
        files = readdir(d)
        if length(files) > 0
            dates = map(x -> Date(split(x, ['.'])[1]), files)
            f = joinpath(d, "$(maximum(dates)).jld")
            loadparams!(suite[group], load(f, group), :evals, :samples)
        end
    end
end

function saveres(res)
    for group in GROUPS
        d = joinpath(res_dir, group)
        !isdir(d) && mkdir(d)
        path = joinpath(d, "$(Date(now())).jld")
        save(path, group, res[group])
    end
end

function loadres()
    res = BenchmarkGroup()
    for group in GROUPS
        d = joinpath(res_dir, group)
        !isdir(d) && mkdir(d)
        files = readdir(d)
        if length(files) > 0
            dates = map(x -> Date(split(x, ['.'])[1]), files)
            f = joinpath(d, "$(maximum(dates)).jld")
            res[group] = load(f, group)
        end
    end
    return res
end

TUNE && (tune!(suite); savepars(suite))
loadpars!(suite)


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

if RUN_BENCH
#####  RUNNING ###################
    res = run(suite, verbose=true)

    #### COMPARISONS ##########
    resold = loadres()

    has_regressions = false
    has_improves = true
    for group in GROUPS
        println("GROUP $group")
        m = median(res[group])
        println(m)
        !haskey(resold, group) && continue

        mold = median(resold[group])
        judgement = judge(m, mold)

        regr = regressions(judgement)
        if length(regr) > 0
            has_regressions = false
            print_with_color(:red, "REGRESSIONS FOUND:\n")
            println(regr)
            print_with_color(:red, "******************\n")
        end
        improvs = improvements(judgement)
        if length(improvs) > 0
            has_improves = true
            print_with_color(:green, "IMPROVEMENTS FOUND:\n")
            println(improvs)
            print_with_color(:green, "******************\n")
        end
    end

    ###  SAVING ############
    # if SAVE_RES && !has_improves && !has_regressions
    println()
    if SAVE_RES
        saveres(res)
        println("Results saved!")
    else
        println("Results not saved. Save them with `saveres(res)`")
    end
end


println("Retune the benchmarks and save the parameters with `tune!(suite); savepars(suite)`")
