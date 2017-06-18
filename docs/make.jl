using Documenter
include("../src/Erdos.jl")
using Erdos

# Copy the list of features from the README to the
# Getting Started page in docs, to avoid duplication.
if VERSION < v"0.6"
    readme = readlines("../README.md")
    indexbase = readlines("src/indexbase.md")
else
    readme = readlines("../README.md", chomp=false)
    indexbase = readlines("src/indexbase.md", chomp=false)
end
idx_features = findfirst(readme, "## Features") + 1
open("src/index.md", "w") do f
    for l in indexbase
        println(f, l)
    end
    for l in readme[idx_features:end]
        println(f, l)
    end
end

cp("../datasets/README.md","src/datasets.md", remove_destination=true)

makedocs(modules=[Erdos], doctest = true)

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
    repo   = "github.com/CarloLucibello/Erdos.jl.git",
    julia  = "0.6"
    )
