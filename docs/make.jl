using Documenter
include("../src/Erdos.jl")
using Erdos

makedocs(modules=[Erdos], doctest = true)

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
    repo   = "github.com/CarloLucibello/Erdos.jl.git",
    julia  = "release"
    )
