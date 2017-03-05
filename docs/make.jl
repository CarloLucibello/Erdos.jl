using Documenter
include("../src/Erdos.jl")
using Erdos

# Copy the list of features from the README to the
# Getting Started page in docs, to avoid duplication.
if VERSION < v"0.6"
    readme = readlines("../README.md")
    idx_features = findfirst(readme, "## Features\n") + 1
    indexbase = readlines("src/indexbase.md")
    open("src/index.md", "w") do f
        for l in indexbase
            print(f, l)
        end
        for l in readme[idx_features:end]
            print(f, l)
        end
    end
else # chomped in julia 0.6
    readme = readlines("../README.md")
    idx_features = findfirst(readme, "## Features") + 1
    indexbase = readlines("src/indexbase.md")
    open("src/index.md", "w") do f
        for l in indexbase
            println(f, l)
        end
        for l in readme[idx_features:end]
            println(f, l)
        end
    end
end

makedocs(modules=[Erdos], doctest = true)

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
    repo   = "github.com/CarloLucibello/Erdos.jl.git",
    julia  = "0.5"
    )
