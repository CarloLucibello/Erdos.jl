using Documenter
include("../src/FatGraphs.jl")
using FatGraphs

#TODO use joinpath
root, dir, files = first(walkdir("../src/"))
nsrc = length(dir)
root, dir, files = first(walkdir("src/"))
ndocs = length(files)

# index is equal to the README for the time being
cp(normpath(@__FILE__, "../../README.md"), normpath(@__FILE__, "../src/index.md"); remove_destination=true)

# same for contributing and license
cp(normpath(@__FILE__, "../../LICENSE.md"), normpath(@__FILE__, "../src/license.md"); remove_destination=true)

makedocs(modules=[FatGraphs], doctest = false)


deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
    repo   = "github.com/CarloLucibello/FatGraphs.jl.git"
#    julia  = "release"

)

rm(normpath(@__FILE__, "../src/index.md"))
rm(normpath(@__FILE__, "../src/license.md"))
