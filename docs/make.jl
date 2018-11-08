using Documenter
using Erdos

# Copy the list of features from the README to the
# Getting Started page in docs, to avoid duplication.
readme = readlines("README.md", chomp=false)
indexbase = readlines("docs/src/indexbase.md", chomp=false)
idx_features = findfirst(readme, "## Features\n") + 1
open("docs/src/index.md", "w") do f
    for l in indexbase
        println(f, l)
    end
    for l in readme[idx_features:end]
        println(f, l)
    end
end

cp("datasets/README.md","docs/src/datasets.md", force=true)

makedocs(modules=[Erdos], doctest = true)

deploydocs(
    deps = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
    repo   = "github.com/CarloLucibello/Erdos.jl.git",
    julia  = "0.6"
    )
