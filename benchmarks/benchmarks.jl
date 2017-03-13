if !isdefined(:Erdos)
    include("../src/Erdos.jl")
    using Erdos
end

using BenchmarkTools
using Base.Dates
import JLD: load, save

BenchmarkTools.DEFAULT_PARAMETERS.seconds = 40.
BenchmarkTools.DEFAULT_PARAMETERS.time_tolerance = 0.05
BenchmarkTools.DEFAULT_PARAMETERS.samples = 50000

VERS = VERSION >= v"0.6dev" ? "v0.6" : "v0.5"
bench_dir = Base.source_dir()
res_dir = joinpath(bench_dir, "results", VERS)
par_dir = joinpath(bench_dir, "parameters")
res_dir5 = joinpath(bench_dir, "results", "v0.5")
res_dir6 = joinpath(bench_dir, "results", "v0.6")

### ADD BENCHMARKS  ###############
suite = BenchmarkGroup()
GLIST = [Graph{Int64}, Net]
DGLIST = [DiGraph{Int64}, DiNet]
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

for group in GROUPS
    include("$group/$group.jl")
end

####  LOADING / SAVING PARAMS
function savepars(suite, groups=GROUPS)
    for group in groups
        d = joinpath(par_dir, group)
        !isdir(d) && mkdir(d)
        path = joinpath(d, "$(Date(now())).jld")
        println("saving $path")
        # BenchmarkTools.save(path, group, params(suite[group]))
        save(path, group, params(suite[group]))
    end
end

function loadpars!(suite, groups=GROUPS)
    for group in groups
        d = joinpath(par_dir,group)
        !isdir(d) && mkdir(d)
        files = readdir(d)
        if length(files) > 0
            dates = map(x -> Date(split(x, ['.'])[1]), files)
            f = joinpath(d, "$(maximum(dates)).jld")
            println("loading $f")
            # loadparams!(suite[group], BenchmarkTools.load(f, group), :evals, :samples)
            loadparams!(suite[group], load(f, group), :evals, :samples)
        end
    end
end

function saveres(res)
    for group in GROUPS
        d = joinpath(res_dir, group)
        !isdir(d) && mkdir(d)
        path = joinpath(d, "$(Date(now())).jld")
        # BenchmarkTools.save(path, group, res[group])
        save(path, group, res[group])
        println("Benchmarks' result saved in $path")
    end
end

loadres(prev::Int=0) = loadres(res_dir, prev)
function loadres(rdir::String, prev::Int=0)
    res = BenchmarkGroup()
    for group in GROUPS
        d = joinpath(rdir, group)
        !isdir(d) && mkdir(d)
        files = readdir(d)
        if length(files) > 0
            dates = sort(map(x -> Date(split(x, ['.'])[1]), files))
            f = joinpath(d, "$(dates[end-prev]).jld")
            # res[group] = BenchmarkTools.load(f, group)
            res[group] = load(f, group)
        end
    end
    return res
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

function runbench()
    res = run(suite, verbose=true)
    return res
end

comparebench(res,prev::Int=0) = comparebench(loadres(prev), res)

function comparebench56()
    comparebench(loadres(res_dir5),loadres(res_dir6))
end

function comparebench(resold, res)
    has_regressions = false
    has_improves = true
    for group in GROUPS
        println("GROUP $group")
        m = median(res[group])
        !haskey(resold, group) && continue
        mold = median(resold[group])
        judgement = judge(m, mold)
        println(m)
        regr = regressions(judgement)
        if length(regr) > 0
            has_regressions = false
            print_with_color(:red, "REGRESSIONS FOUND:\n")
            @show regr
            print_with_color(:red, "******************\n")
        end
        improvs = improvements(judgement)
        if length(improvs) > 0
            has_improves = true
            print_with_color(:green, "IMPROVEMENTS FOUND:\n")
            @show improvs
            print_with_color(:green, "******************\n")
        end
    end
end

loadpars!(suite)

println("Retune the benchmarks and save the parameters with `tune!(suite); savepars(suite)`")
println("Run the benchmarks with `res = runbench()`")
println("Compare to previous results with `comparebench(res)`")
println("Save the results with `saveres(res)`")
