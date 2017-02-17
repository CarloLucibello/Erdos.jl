using Documenter
include("../src/FatGraphs.jl")
using FatGraphs

makedocs(modules=[FatGraphs], doctest = true)

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
    repo   = "github.com/CarloLucibello/FatGraphs.jl.git"
#    julia  = "release"
    )
